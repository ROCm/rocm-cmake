################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 3.5)
project(headeronly LANGUAGES NONE)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)
include(ROCMCreatePackage)

rocm_setup_version(VERSION 1.0.0)

if(ROCM_PREFIX)
rocm_create_package(
    NAME headeronly 
    PREFIX ${ROCM_PREFIX}
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG
    HEADER_ONLY)
else()
rocm_create_package(
    NAME headeronly 
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG
    HEADER_ONLY)
endif()

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

add_library(headeronly INTERFACE)
target_include_directories(headeronly 
    INTERFACE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:headeronly/include/>)

if(ROCM_PREFIX)
    rocm_install_targets(
        TARGETS headeronly 
        INCLUDE include 
        PREFIX ${ROCM_PREFIX})
    rocm_install(
        DIRECTORY
            "include/"
        DESTINATION headeronly/include/
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
        PERMISSIONS OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ
    )
    rocm_export_targets(
        TARGETS headeronly 
        INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake 
        PREFIX ${ROCM_PREFIX})
    rocm_install_symlink_subdir(${ROCM_PREFIX})
else()
    rocm_install_targets(
        TARGETS headeronly
        INCLUDE include)
    rocm_install(
        DIRECTORY
            "include/"
        DESTINATION headeronly/include/
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
        PERMISSIONS OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ
    )
    rocm_export_targets(
        TARGETS headeronly 
        INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake)
endif()
