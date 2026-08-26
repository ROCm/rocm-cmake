# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

cmake_minimum_required(VERSION 3.5...3.31.0)
project(versionresource VERSION 1.2.3 LANGUAGES CXX)

find_package(ROCmCMakeBuildTools)

include(ROCMSetupVersion)

add_library(mylib SHARED mylib.cpp)
rocm_add_version_resource(mylib "MyLib" "Test version resource library")

add_executable(myapp myapp.cpp)
target_link_libraries(myapp mylib)
rocm_add_version_resource(myapp "MyApp" "Test version resource application")
