# ######################################################################################################################
# Copyright (C) 2021-2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

include(CheckCXXCompilerFlag)
include(CMakeParseArguments)

function(rocm_check_target_ids VARIABLE)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs TARGETS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_UNPARSED_ARGUMENTS)
        message(
            FATAL_ERROR
                "Unknown keywords given to rocm_check_target_ids(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    foreach(_target_id ${PARSE_TARGETS})
        _rocm_sanitize_target_id("${_target_id}" _result_var)
        set(_result_var "COMPILER_HAS_TARGET_ID_${_result_var}")
        check_cxx_compiler_flag("-xhip --offload-arch=${_target_id}" "${_result_var}")
        if(${_result_var})
            list(APPEND _supported_target_ids "${_target_id}")
        endif()
    endforeach()
    set(${VARIABLE} "${_supported_target_ids}" PARENT_SCOPE)
endfunction()

function(_rocm_sanitize_target_id TARGET_ID VARIABLE)
    # CMake defines a preprocessor macro with this value, so it must be a valid C identifier
    # Handle + and - for xnack and sramecc so that e.g. xnack+ and xnack- doesn't get folded to
    # the same string by MAKE_C_IDENTIFIER
    string(REPLACE "_" "__"   TARGET_ID "${TARGET_ID}")
    string(REPLACE "+" "_on"  TARGET_ID "${TARGET_ID}")
    string(REPLACE "-" "_off" TARGET_ID "${TARGET_ID}")
    string(MAKE_C_IDENTIFIER "${TARGET_ID}" TARGET_ID)
    set(${VARIABLE} "${TARGET_ID}" PARENT_SCOPE)
endfunction()
