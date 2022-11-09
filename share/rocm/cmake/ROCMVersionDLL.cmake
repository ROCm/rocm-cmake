# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(_ROCMVersionDLL_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(rocm_version_dll TARGET)
    if(WIN32)
        if(DEFINED ENV{ROCM_DLL_VERSION} AND NOT "$ENV{ROCM_DLL_VERSION}" STREQUAL "")
            set(ROCM_DLL_VERSION "$ENV{ROCM_DLL_VERSION}" CACHE STRING "The version to put onto compiled DLLs.")
        endif()
        if(ROCM_DLL_VERSION)
            string(REPLACE "." "," ROCM_DLL_VERSION_COMMA "${ROCM_DLL_VERSION}")
            configure_file(${_ROCMVersionDLL_LIST_DIR}/version.rc.in ${CMAKE_CURRENT_BINARY_DIR}/version_${TARGET}.rc @ONLY)
            set_property(TARGET ${TARGET} APPEND PROPERTY SOURCES "${CMAKE_CURRENT_BINARY_DIR}/version_${TARGET}.rc")
        endif()
    endif()
endfunction()