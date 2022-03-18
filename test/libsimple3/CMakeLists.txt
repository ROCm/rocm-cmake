################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 3.5)
project(simple)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)
include(ROCMCreatePackage)

rocm_setup_version(VERSION 1.0.0)

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

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

add_library(simple3 simple3.cpp)
rocm_set_soversion(simple3 1.1.2)

add_executable(simple-main main.cpp)
target_link_libraries(simple-main simple3)

rocm_install(TARGETS simple3 INCLUDE include)
rocm_export_targets(TARGETS simple3 INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake)
rocm_install(TARGETS simple-main COMPONENT runnable)
option(EXPORT_RUNNABLE "Export the executable simple-main." ON)
if(EXPORT_RUNNABLE)
    rocm_export_targets(TARGETS simple-main COMPONENT runnable)
endif()
