################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 2.8)
project(simple)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMAnalyzers)
include(ROCMSetupVersion)

rocm_setup_version(VERSION 1.0.0)

add_library(simple simple.cpp)
rocm_install_targets(TARGETS simple INCLUDE include)

include(ROCMClangTidy)
rocm_enable_clang_tidy(
    CHECKS 
        *
    ERRORS
        *
    HEADER_FILTER
        "hpp$"
)
include(ROCMCppCheck)
rocm_enable_cppcheck(
    INCONCLUSIVE
    CHECKS 
        warning
    FORCE
    SUPPRESS 
        unmatchedSuppression
    SOURCES
        simple.cpp
    INCLUDE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

rocm_clang_tidy_check(simple)
