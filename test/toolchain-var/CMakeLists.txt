################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 3.5...3.31.0)
find_package(ROCmCMakeBuildTools)
project(toolchain-var CXX)

if(CHANGE_TOOLCHAIN)
set(CMAKE_CXX_COMPILER gcc)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
endif()

add_library(lib INTERFACE)
