# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(_ROCMVersionDLL_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

define_property(
    TARGET PROPERTY DLL_FILE_VERSION
    BRIEF_DOCS "This target property records the version of the generated DLL file."
    FULL_DOCS "The value stored in this property will be set as the FileVersion property of the DLL."
)

set(ROCM_DLL_VERSION "$ENV{ROCM_DLL_VERSION}" CACHE STRING "The version to add to DLLs by default.")
set(ROCM_DLL_FILE_VERSION "$ENV{ROCM_DLL_FILE_VERSION}" CACHE STRING "The version of the file to attach to DLLs.")
set(ROCM_DLL_PRODUCT_VERSION "$ENV{ROCM_DLL_PRODUCT_VERSION}" CACHE STRING "The version of the product to attach to DLLs.")
mark_as_advanced(ROCM_DLL_VERSION ROCM_DLL_FILE_VERSION ROCM_DLL_PRODUCT_VERSION)

function(rocm_version_dll TARGET)
    if(WIN32)
        # Get file version
        if(ROCM_DLL_FILE_VERSION STREQUAL "" AND ROCM_DLL_VERSION STREQUAL "")
            get_property(DLL_FILE_VERSION TARGET ${TARGET} PROPERTY DLL_FILE_VERSION)
            if(DLL_FILE_VERSION STREQUAL "")
                get_property(DLL_FILE_VERSION TARGET ${TARGET} PROPERTY VERSION)
            endif()
        elseif(ROCM_DLL_FILE_VERSION STREQUAL "")
            set(DLL_FILE_VERSION "${ROCM_DLL_VERSION}")
        else()
            set(DLL_FILE_VERSION "${ROCM_DLL_FILE_VERSION}")
        endif()
        # Get product version
        if(ROCM_DLL_PRODUCT_VERSION STREQUAL "" AND ROCM_DLL_VERSION STREQUAL "")
            set(DLL_PRODUCT_VERSION "${${PROJECT_NAME}_VERSION}")
        elseif(ROCM_DLL_PRODUCT_VERSION STREQUAL "")
            set(DLL_PRODUCT_VERSION "${ROCM_DLL_VERSION}")
        else()
            set(DLL_PRODUCT_VERSION "${ROCM_DLL_PRODUCT_VERSION}")
        endif()
        if(DLL_FILE_VERSION STREQUAL "" OR DLL_PRODUCT_VERSION STREQUAL "")
            return()
        endif()

        string(REPLACE "." "," DLL_FILE_VERSION_COMMA "${DLL_FILE_VERSION}")
        string(REPLACE "." "," DLL_PRODUCT_VERSION_COMMA "${DLL_PRODUCT_VERSION}")
        configure_file(
            ${_ROCMVersionDLL_LIST_DIR}/version.rc.in
            ${CMAKE_CURRENT_BINARY_DIR}/version_${TARGET}.rc
            @ONLY
        )
        set_property(TARGET ${TARGET} APPEND PROPERTY SOURCES "${CMAKE_CURRENT_BINARY_DIR}/version_${TARGET}.rc")
    endif()
endfunction()
