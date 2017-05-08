
macro(rocm_set_parent VAR)
    set(${VAR} ${ARGN} PARENT_SCOPE)
    set(${VAR} ${ARGN})
endmacro()

function(rocm_setup_version)
    set(options)
    set(oneValueArgs VERSION)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(TOUPPER ${PROJECT_NAME} PREFIX)

    if(PARSE_PREFIX)
        set(PREFIX ${PARSE_PREFIX})
    endif()

    if(PARSE_VERSION)
        rocm_set_parent(PROJECT_VERSION ${PARSE_VERSION})
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
