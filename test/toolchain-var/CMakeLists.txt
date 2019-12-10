################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 2.8)
project(toolchain-var)

find_package(ROCM)

set(CMAKE_CXX_COMPILER gcc)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")

add_library(lib INTERFACE)
