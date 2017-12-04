################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

include(CMakeParseArguments)
include(ProcessorCount)
include(ROCMAnalyzers)

find_program(CPPCHECK_EXE 
    NAMES 
        cppcheck
    PATHS
        /opt/rocm/bin
)

ProcessorCount(CPPCHECK_JOBS)

macro(rocm_enable_cppcheck)
    set(options FORCE)
    set(oneValueArgs)
    set(multiValueArgs CHECKS SUPPRESS DEFINE UNDEFINE INCLUDE SOURCES)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    string(REPLACE ";" "," CPPCHECK_CHECKS "${PARSE_CHECKS}")
    string(REPLACE ";" "\n" CPPCHECK_SUPPRESS "${PARSE_SUPPRESS};*:/usr/*")
    file(WRITE ${CMAKE_BINARY_DIR}/cppcheck-supressions "${CPPCHECK_SUPPRESS}")
    set(CPPCHECK_DEFINES)
    foreach(DEF ${PARSE_DEFINE})
        list(APPEND CPPCHECK_DEFINES -D ${DEF})
    endforeach()

    set(CPPCHECK_UNDEFINES)
    foreach(DEF ${PARSE_UNDEFINE})
        list(APPEND CPPCHECK_UNDEFINES -U ${DEF})
    endforeach()

    set(CPPCHECK_INCLUDES)
    foreach(INC ${PARSE_INCLUDE})
        list(APPEND CPPCHECK_INCLUDES -include=${INC})
    endforeach()

    # set(CPPCHECK_FORCE "--project=${CMAKE_BINARY_DIR}/compile_commands.json")
    set(CPPCHECK_FORCE)
    if(PARSE_FORCE)
        set(CPPCHECK_FORCE --force)
    endif()

    set(CPPCHECK_COMMAND 
        ${CPPCHECK_EXE}
        -q
        # --report-progress
        ${CPPCHECK_FORCE}
        --platform=native
        --template='{file}:{line}: {severity}[{id}]: {message}'
        --error-exitcode=1
        -j ${CPPCHECK_JOBS}
        ${CPPCHECK_DEFINES}
        ${CPPCHECK_UNDEFINES}
        ${CPPCHECK_INCLUDES}
        "--enable=${CPPCHECK_CHECKS}"
        "--suppressions-list=${CMAKE_BINARY_DIR}/cppcheck-supressions"
        ${PARSE_SOURCES}
    )

    add_custom_target(cppcheck
        COMMAND ${CPPCHECK_COMMAND}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "cppcheck: Running cppcheck..."
    )
    rocm_mark_as_analyzer(cppcheck)
endmacro()


