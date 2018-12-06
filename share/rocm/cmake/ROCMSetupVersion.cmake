################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

find_program(GIT NAMES git)

macro(rocm_set_parent VAR)
    set(${VAR} ${ARGN} PARENT_SCOPE)
    set(${VAR} ${ARGN})
endmacro()

function(rocm_git_remote_refs REFS REMOTE DIRECTORY)
    set(_refs)
    execute_process(COMMAND ${GIT} ls-remote ${REMOTE}
        WORKING_DIRECTORY ${DIRECTORY}
        OUTPUT_VARIABLE OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE RESULT
        ERROR_QUIET)
    string(REPLACE "\n" ";" LINES ${OUTPUT})
    foreach(LINE ${LINES})
        separate_arguments(FIELDS UNIX_COMMAND "${LINE}")
        list(GET FIELDS 1 REF)
        if(NOT "${REF}" STREQUAL "HEAD")
            list(APPEND _refs ${REF})
        endif()
    endforeach()
    rocm_set_parent(${REFS} ${_refs})
endfunction()

function(rocm_git_commit_hash COMMIT DIRECTORY)
    execute_process(COMMAND ${GIT} rev-parse HEAD
        WORKING_DIRECTORY ${DIRECTORY}
        OUTPUT_VARIABLE OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE RESULT
        ERROR_QUIET)
    rocm_set_parent(${COMMIT} ${OUTPUT})
endfunction()

function(rocm_git_validate_version OUTPUT DIRECTORY)
    foreach(URL ${ARGN})
        execute_process(COMMAND ${GIT} fetch ${URL}
                    WORKING_DIRECTORY ${DIRECTORY}
                    RESULT_VARIABLE RESULT
                    ERROR_QUIET)
        rocm_git_remote_refs(REFS ${URL} ${DIRECTORY})
        rocm_git_commit_hash(COMMIT ${DIRECTORY})
        foreach(REF ${REFS})
            execute_process(COMMAND ${GIT} for-each-ref ${REF} --contains=${COMMIT}
                WORKING_DIRECTORY ${DIRECTORY}
                OUTPUT_VARIABLE EACH_REF
                OUTPUT_STRIP_TRAILING_WHITESPACE
                RESULT_VARIABLE RESULT
                ERROR_QUIET)
            if(EACH_REF)
                rocm_set_parent(${OUTPUT} 1)
                return()
            endif()
        endforeach()
    endforeach()
    rocm_set_parent(${OUTPUT} 0)
endfunction()

function(rocm_get_version OUTPUT_VERSION)
    set(options)
    set(oneValueArgs VERSION DIRECTORY)
    set(multiValueArgs URL)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(_version ${PARSE_VERSION})

    set(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    if(PARSE_DIRECTORY)
        set(DIRECTORY ${PARSE_DIRECTORY})
    endif()

    if(GIT)
        set(GIT_COMMAND ${GIT} describe --dirty --long --match [0-9]*)
        execute_process(COMMAND ${GIT_COMMAND} 
                        WORKING_DIRECTORY ${DIRECTORY}
                        OUTPUT_VARIABLE GIT_TAG_VERSION
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE RESULT
                        ERROR_QUIET)
        if(${RESULT} EQUAL 0)
            set(_version ${GIT_TAG_VERSION})
        else()
            execute_process(COMMAND ${GIT_COMMAND} --always
                        WORKING_DIRECTORY ${DIRECTORY}
                        OUTPUT_VARIABLE GIT_TAG_VERSION
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE RESULT
                        ERROR_QUIET)
            if(${RESULT} EQUAL 0)
                set(_version ${_version}-${GIT_TAG_VERSION})
                if(PARSE_URL)
                    rocm_git_validate_version(VALID_VERSION ${DIRECTORY} ${PARSE_URL})
                    if(NOT VALID_VERSION)
                        set(_version ${_version}-unofficial)
                    endif()
                endif()
            endif()
        endif()
    endif()
    rocm_set_parent(${OUTPUT_VERSION} ${_version})
endfunction()

function(rocm_version_regex_parse REGEX OUTPUT_VARIABLE INPUT)
    string(REGEX REPLACE ${REGEX} "\\1" OUTPUT "${INPUT}")
    if("${OUTPUT}" STREQUAL "${INPUT}")
        rocm_set_parent(${OUTPUT_VARIABLE} 0)
    else()
        rocm_set_parent(${OUTPUT_VARIABLE} ${OUTPUT})
    endif()
endfunction()

function(rocm_setup_version)
    set(options NO_GIT_TAG_VERSION)
    set(oneValueArgs VERSION)
    set(multiValueArgs URL)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_VERSION)
        # Compensate for missing patch version
        if(PARSE_VERSION MATCHES "^[0-9]+\\.[0-9]+$")
            set(PARSE_VERSION ${PARSE_VERSION}.0)
        endif()
        if(PARSE_NO_GIT_TAG_VERSION)
            set(PACKAGE_VERSION ${PARSE_VERSION})
        else()
            rocm_get_version(PACKAGE_VERSION VERSION ${PARSE_VERSION} URL ${PARSE_URL})
        endif()
        rocm_set_parent(PROJECT_VERSION ${PACKAGE_VERSION})
        rocm_set_parent(${PROJECT_NAME}_VERSION ${PROJECT_VERSION})
        rocm_version_regex_parse("^([0-9]+).*" _version_MAJOR "${PROJECT_VERSION}")
        rocm_version_regex_parse("^[0-9]+\\.([0-9]+).*" _version_MINOR "${PROJECT_VERSION}")
        rocm_version_regex_parse("^[0-9]+\\.[0-9]+\\.([0-9]+).*" _version_PATCH "${PROJECT_VERSION}")
        rocm_version_regex_parse("^[0-9]+\\.[0-9]+\\.[0-9]+[.-](.*)" _version_TWEAK "${PROJECT_VERSION}")
        foreach(level MAJOR MINOR PATCH TWEAK)
            rocm_set_parent(${PROJECT_NAME}_VERSION_${level} ${_version_${level}})
            rocm_set_parent(PROJECT_VERSION_${level} ${_version_${level}})
        endforeach()
    endif()

endfunction()
