################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 2.8)
project(simple)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)
include(ROCMCreatePackage)

if(ROCM_PREFIX)
rocm_create_package(
    NAME simple 
    PREFIX ${ROCM_PREFIX}
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG)
else()
rocm_create_package(
    NAME simple 
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG)
endif()

rocm_setup_version(VERSION 1.0.0)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

add_library(simple simple.cpp)
rocm_set_soversion(simple 1.1.2)

add_executable(simple-main main.cpp)
target_link_libraries(simple-main simple)

if(ROCM_PREFIX)
    rocm_install_targets(TARGETS simple simple-main INCLUDE include PREFIX ${ROCM_PREFIX})
    rocm_export_targets(TARGETS simple INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake PREFIX ${ROCM_PREFIX})
    rocm_install_symlink_subdir(${ROCM_PREFIX})
else()
    rocm_install_targets(TARGETS simple simple-main INCLUDE include)
    rocm_export_targets(TARGETS simple INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake)
endif()
