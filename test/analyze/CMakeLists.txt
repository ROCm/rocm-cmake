################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 3.5...3.31.0)
project(simple LANGUAGES CXX)

find_package(ROCmCMakeBuildTools)

include(ROCMInstallTargets)
include(ROCMAnalyzers)
include(ROCMSetupVersion)

include(ROCMClangTidy)
rocm_enable_clang_tidy(
    DEV_WARNINGS_AS_ERRORS
    CHECKS
        *
        -llvmlibc-*
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
    ADDONS
        findcasts
        threadsafety
)

rocm_setup_version(VERSION 1.0.0)

configure_file(simple2.cpp.in simple2.cpp)

add_library(simple simple.cpp ${CMAKE_CURRENT_BINARY_DIR}/simple2.cpp)
rocm_install_targets(TARGETS simple INCLUDE include)


rocm_clang_tidy_check(simple)
