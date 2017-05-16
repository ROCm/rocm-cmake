
macro(rocm_set_parent VAR)
    set(${VAR} ${ARGN} PARENT_SCOPE)
    set(${VAR} ${ARGN})
endmacro()

function(rocm_get_version OUTPUT_VERSION)
    set(options)
    set(oneValueArgs VERSION DIRECTORY)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(_version ${PARSE_VERSION})

    set(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    if(PARSE_DIRECTORY)
        set(DIRECTORY ${PARSE_DIRECTORY})
    endif()

    find_program(GIT NAMES git)

    if(GIT)
        execute_process(COMMAND git describe --dirty --long --match [0-9]*
                        WORKING_DIRECTORY ${DIRECTORY}
                        OUTPUT_VARIABLE GIT_TAG_VERSION
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE RESULT)
        if(${RESULT} EQUAL 0)
            set(_version ${GIT_TAG_VERSION})
        endif()
    endif()
    rocm_set_parent(${OUTPUT_VERSION} ${_version})

endfunction()

function(rocm_setup_version)
    set(options NO_GIT_TAG_VERSION)
    set(oneValueArgs VERSION)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(TOUPPER ${PROJECT_NAME} PREFIX)

    if(PARSE_PREFIX)
        set(PREFIX ${PARSE_PREFIX})
    endif()

    if(PARSE_VERSION)
        if(NO_GIT_TAG_VERSION)
            set(PACKAGE_VERSION ${PARSE_VERSION})
        else()
            rocm_get_version(PACKAGE_VERSION VERSION ${PARSE_VERSION})
        endif()
        rocm_set_parent(PROJECT_VERSION ${PACKAGE_VERSION})
        rocm_set_parent(${PROJECT_NAME}_VERSION ${PROJECT_VERSION})
        string(REGEX REPLACE "^([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" _version_MAJOR "${PROJECT_VERSION}")
        string(REGEX REPLACE "^[0-9]+\\.([0-9]+)\\.[0-9]+.*" "\\1" _version_MINOR "${PROJECT_VERSION}")
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" _version_PATCH "${PROJECT_VERSION}")
        foreach(level MAJOR MINOR PATCH)
            rocm_set_parent(${PROJECT_NAME}_VERSION_${level} ${_version_${level}})
            rocm_set_parent(PROJECT_VERSION_${level} ${_version_${level}})
        endforeach()
    endif()

endfunction()
