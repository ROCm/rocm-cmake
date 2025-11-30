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

# Workaround clangTooling issue: https://github.com/llvm/llvm-project/issues/100909
add_compile_options(-Wno-unused-command-line-argument)

rocm_setup_version(VERSION 1.0.0)

configure_file(simple2.cpp.in simple.cpp)
configure_file(simple_with_a_ridiculously_long_filename_in_order_to_test_long_filenames_in_clang_tidy_cmake.cpp.in simple_with_a_ridiculously_long_filename_in_order_to_test_long_filenames_in_clang_tidy_cmake.cpp)

add_library(simple simple.cpp ${CMAKE_CURRENT_BINARY_DIR}/simple_with_a_ridiculously_long_filename_in_order_to_test_long_filenames_in_clang_tidy_cmake.cpp ${CMAKE_CURRENT_BINARY_DIR}/simple.cpp)
rocm_install_targets(TARGETS simple INCLUDE include)


rocm_clang_tidy_check(simple)
