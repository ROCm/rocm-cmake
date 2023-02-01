################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 3.5)
project(simple CXX)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)
include(ROCMCreatePackage)
include(ROCMTest)

rocm_setup_version(VERSION 1.0.0)

rocm_enable_test_package()

rocm_create_package(
    NAME simple 
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

add_library(simple simple.cpp)
rocm_set_soversion(simple 1.1.2)

add_executable(simple-main main.cpp)
target_link_libraries(simple-main simple)

rocm_install_targets(TARGETS simple simple-main INCLUDE include)
rocm_export_targets(TARGETS simple)

rocm_test_link_libraries(simple)
rocm_add_test_executable(simple-test test.cpp)
rocm_test_headers(HEADERS include/simple.h)
rocm_test_install_ctest(NAME simple)