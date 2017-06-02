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
    LDCONFIG)
else()
rocm_create_package(
    NAME simple 
    MAINTAINER "Amd amd@amd.com"
    LDCONFIG)
endif()

rocm_setup_version(VERSION 1.0.0)

add_library(simple simple.cpp)

if(ROCM_PREFIX)
    rocm_install_targets(TARGETS simple INCLUDE include PREFIX ${ROCM_PREFIX})
    rocm_export_targets(TARGETS simple INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake PREFIX ${ROCM_PREFIX})
    rocm_install_symlink_subdir(${ROCM_PREFIX})
else()
    rocm_install_targets(TARGETS simple INCLUDE include)
    rocm_export_targets(TARGETS simple INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake)
endif()
