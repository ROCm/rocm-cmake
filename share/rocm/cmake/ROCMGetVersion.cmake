
macro(rocm_set_parent VAR)
    set(${VAR} ${ARGN} PARENT_SCOPE)
    set(${VAR} ${ARGN})
endmacro()

function(rocm_get_version)
    set(options)
    set(oneValueArgs VERSION)
    set(multiValueArgs)

    cmake_parse_arguments(DEFAULT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(VERSION ${DEFAULT_VERSION})

    find_program(GIT NAMES git)

    if(GIT)
        execute_process(COMMAND git describe --dirty --long --match [0-9]*
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        OUTPUT_VARIABLE GIT_TAG_VERSION
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE RESULT)
        if(${RESULT} EQUAL 0)
            set(VERSION ${GIT_TAG_VERSION})
        endif()
    endif()
    rocm_set_parent(TAGGED_VERSION ${VERSION})

endfunction()
