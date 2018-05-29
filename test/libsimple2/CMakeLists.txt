################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 2.8)
project(simple2)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)
include(ROCMCreatePackage)

find_package(simple)

if(ROCM_PREFIX)
rocm_create_package(
    NAME simple2 
    PREFIX ${ROCM_PREFIX}
    MAINTAINER "Amd amd@amd.com"
    LDCONFIG)
else()
rocm_create_package(
    NAME simple2 
    MAINTAINER "Amd amd@amd.com"
    LDCONFIG)
endif()

rocm_setup_version(VERSION 1.0.0)

add_library(simple2 simple2.cpp)
target_link_libraries(simple2 simple)

if(ROCM_PREFIX)
    rocm_install_targets(TARGETS simple2 INCLUDE include PREFIX ${ROCM_PREFIX})
    rocm_export_targets(TARGETS simple2 INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake PREFIX ${ROCM_PREFIX} DEPENDS PACKAGE simple)
    rocm_install_symlink_subdir(${ROCM_PREFIX})
else()
    rocm_install_targets(TARGETS simple2 INCLUDE include)
    rocm_export_targets(TARGETS simple2 INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake DEPENDS PACKAGE simple)
endif()
