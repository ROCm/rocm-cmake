################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

cmake_minimum_required (VERSION 2.8) # TODO: Should probably be 3.0

set(CMAKE_INSTALL_PREFIX "/opt/rocm" CACHE PATH "")

project(rocm-cmake)

install(DIRECTORY share DESTINATION .)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/share/rocm/cmake)
include(ROCMCreatePackage)
include(ROCMSetupVersion)

rocm_setup_version(VERSION 0.2)

rocm_create_package(
    NAME rocm-cmake
    MAINTAINER "Paul Fultz II pfultz@amd.com"
)

enable_testing()
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C ${CMAKE_CFG_INTDIR})
add_subdirectory(test)
