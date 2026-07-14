################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
################################################################################

cmake_minimum_required(VERSION 3.5...3.31.0)
project(rocmdefer NONE)

find_package(ROCmCMakeBuildTools)

include(ROCMUtilities)

add_subdirectory(sub)
