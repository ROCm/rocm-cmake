################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 2.8)
project(basic)

find_package(ROCM)
find_package(simple)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)

rocm_setup_version(VERSION VERSION 1.0.0)

if(NOT PROJECT_VERSION STREQUAL "1.0.0")
    message(SEND_ERROR "Version not the same")
endif()

add_library(basic main.cpp)
target_link_libraries(basic PRIVATE simple)

rocm_install_targets(TARGETS basic INCLUDE include)
rocm_export_targets(TARGETS basic STATIC_DEPENDS simple)

