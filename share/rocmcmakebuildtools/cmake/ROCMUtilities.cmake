# ######################################################################################################################
# Copyright (C) 2021 Advanced Micro Devices, Inc.
# ######################################################################################################################

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12.0")
    # pretty much just a wrapper around string JOIN
    function(rocm_join_if_set glue inout_variable)
        string(JOIN "${glue}" to_set_parent ${${inout_variable}} ${ARGN})
        set(${inout_variable} "${to_set_parent}" PARENT_SCOPE)
    endfunction()
else()
    # cmake < 3.12 doesn't have string JOIN
    function(rocm_join_if_set glue inout_variable)
        set(accumulator "${${inout_variable}}")
        set(tglue ${glue})
        if(accumulator STREQUAL "")
            set(tglue "")       # No glue needed if initially unset
        endif()
        foreach(ITEM IN LISTS ARGN)
            string(CONCAT accumulator "${accumulator}" "${tglue}" "${ITEM}")
            set(tglue ${glue})  # Always need glue after the first concatenate
        endforeach()
        set(${inout_variable} "${accumulator}" PARENT_SCOPE)
    endfunction()
endif()

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18.0")
    macro(rocm_eval_code CODE)
        cmake_language(EVAL CODE "${CODE}")
    endmacro()
else()
    macro(rocm_eval_code CODE)
        file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/rocm_eval.cmake "${CODE}")
        include(${CMAKE_CURRENT_BINARY_DIR}/rocm_eval.cmake)
        # Deleting an include()d file makes Ninja loop on manifest regeneration
        # ("build.ninja still dirty after 100 tries"), so keep it for Ninja.
        if(NOT CMAKE_GENERATOR MATCHES "Ninja")
            file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/rocm_eval.cmake)
        endif()
    endmacro()
endif()

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.19.0")
    macro(rocm_defer FNAME)
        cmake_language(DEFER DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} CALL ${FNAME}())
    endmacro()
else()
    macro(rocm_defer FNAME)
        function(rocm_defer_private_${FNAME}_hook VARIABLE ACCESS CURRENT_LIST_FILE STACK)
            if (NOT STACK)
                rocm_eval_code("${FNAME}()")
            endif()
        endfunction()
        variable_watch(CMAKE_BACKWARDS_COMPATIBILITY rocm_defer_private_${FNAME}_hook)
    endmacro()
endif()

function(rocm_test_property_names OUTPUT)
    set(${OUTPUT}
        ATTACHED_FILES
        ATTACHED_FILES_ON_FAIL
        COST
        DEPENDS
        DISABLED
        ENVIRONMENT
        ENVIRONMENT_MODIFICATION
        FAIL_REGULAR_EXPRESSION
        FIXTURES_CLEANUP
        FIXTURES_REQUIRED
        FIXTURES_SETUP
        LABELS
        MEASUREMENT
        PASS_REGULAR_EXPRESSION
        PROCESSOR_AFFINITY
        PROCESSORS
        REQUIRED_FILES
        RESOURCE_GROUPS
        RESOURCE_LOCK
        RUN_SERIAL
        SKIP_REGULAR_EXPRESSION
        SKIP_RETURN_CODE
        TIMEOUT
        TIMEOUT_AFTER_MATCH
        WILL_FAIL
        WORKING_DIRECTORY
        PARENT_SCOPE)
endfunction()

# Stashes the local tests' properties into directory-keyed globals so they can
# be read from another scope before cmake 3.28. Runs in the test's own scope.
function(rocm_test_collect_local_test_props)
    rocm_test_property_names(props)
    get_property(tests DIRECTORY PROPERTY TESTS)
    foreach(test IN LISTS tests)
        foreach(prop IN LISTS props)
            get_test_property(${test} ${prop} val)
            if(NOT val STREQUAL "NOTFOUND")
                set_property(GLOBAL PROPERTY "_rocm_test_prop|${CMAKE_CURRENT_SOURCE_DIR}|${test}|${prop}" "${val}")
            endif()
        endforeach()
    endforeach()
endfunction()

# Schedules the collector once per directory (only needed before cmake 3.28).
function(rocm_auto_register_test_props)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.28.0")
        return()
    endif()
    get_property(scheduled DIRECTORY PROPERTY _rocm_test_props_collector_scheduled)
    if(NOT scheduled)
        set_property(DIRECTORY PROPERTY _rocm_test_props_collector_scheduled TRUE)
        rocm_defer(rocm_test_collect_local_test_props)
    endif()
endfunction()

# get_test_property that also reads across directory scopes: built-in DIRECTORY
# support on cmake 3.28+, otherwise the value rocm_test_collect_local_test_props
# stashed for that directory.
function(rocm_get_test_property)
    cmake_parse_arguments(ARG "" "DIRECTORY" "" ${ARGN})
    list(LENGTH ARG_UNPARSED_ARGUMENTS _n)
    if(NOT _n EQUAL 3)
        message(FATAL_ERROR "rocm_get_test_property: expected <test> <property> [DIRECTORY <dir>] <out-var>")
    endif()
    list(GET ARG_UNPARSED_ARGUMENTS 0 _test)
    list(GET ARG_UNPARSED_ARGUMENTS 1 _prop)
    list(GET ARG_UNPARSED_ARGUMENTS 2 _out)
    if(DEFINED ARG_DIRECTORY)
        get_filename_component(_dir "${ARG_DIRECTORY}" ABSOLUTE)
    else()
        set(_dir ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    if(_dir STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        get_test_property(${_test} ${_prop} _val)
    elseif(CMAKE_VERSION VERSION_GREATER_EQUAL "3.28.0")
        get_property(_val TEST ${_test} DIRECTORY "${_dir}" PROPERTY ${_prop})
    else()
        get_property(_val GLOBAL PROPERTY "_rocm_test_prop|${_dir}|${_test}|${_prop}")
    endif()
    set(${_out} "${_val}" PARENT_SCOPE)
endfunction()

function(rocm_find_program_version PROGRAM)
    set(options QUIET REQUIRED)
    set(oneValueArgs GREATER GREATER_EQUAL LESS LESS_EQUAL EQUAL OUTPUT_VARIABLE)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT DEFINED PARSE_OUTPUT_VARIABLE)
        set(PARSE_OUTPUT_VARIABLE "${PROGRAM}_VERSION")
    endif()

    execute_process(
        COMMAND ${PROGRAM} --version
        RESULT_VARIABLE PROC_RESULT
        OUTPUT_VARIABLE EVAL_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT PROC_RESULT EQUAL "0")
        set(${PARSE_OUTPUT_VARIABLE} "0.0.0" PARENT_SCOPE)
        set(${PARSE_OUTPUT_VARIABLE}_OK FALSE PARENT_SCOPE)
        if(PARSE_REQUIRED)
            message(FATAL_ERROR "Could not determine the version of required program ${PROGRAM}.")
        elseif(NOT PARSE_QUIET)
            message(WARNING "Could not determine the version of program ${PROGRAM}.")
        endif()
    else()
        string(REGEX MATCH "[0-9]+(\\.[^ \t\r\n]+)*" PROGRAM_VERSION "${EVAL_RESULT}")
        set(${PARSE_OUTPUT_VARIABLE} "${PROGRAM_VERSION}" PARENT_SCOPE)
        set(${PARSE_OUTPUT_VARIABLE}_OK TRUE PARENT_SCOPE)
        foreach(COMP GREATER GREATER_EQUAL LESS LESS_EQUAL EQUAL)
            if(DEFINED PARSE_${COMP} AND NOT PROGRAM_VERSION VERSION_${COMP} PARSE_${COMP})
                set(${PARSE_OUTPUT_VARIABLE}_OK FALSE PARENT_SCOPE)
            endif()
        endforeach()
    endif()
endfunction()

function(rocm_set_os_id OS_ID)
    set(_os_id "unknown")
    if(EXISTS "/etc/os-release")
        rocm_read_os_release(_os_id "ID")
    endif()
    set(${OS_ID}
        ${_os_id}
        PARENT_SCOPE)
    set(os_id_out ${OS_ID}_${_os_id})
    set(${os_id_out}
        TRUE
        PARENT_SCOPE)
endfunction()

function(rocm_read_os_release OUTPUT KEYVALUE)
    # finds the line with the keyvalue
    if(EXISTS "/etc/os-release")
        file(STRINGS /etc/os-release _keyvalue_line REGEX "^${KEYVALUE}=")
    endif()

    # remove keyvalue=
    string(REGEX REPLACE "^${KEYVALUE}=\"?(.*)" "\\1" _output "${_keyvalue_line}")

    # remove trailing quote
    string(REGEX REPLACE "\"$" "" _output "${_output}")
    set(${OUTPUT}
        ${_output}
        PARENT_SCOPE)
endfunction()
