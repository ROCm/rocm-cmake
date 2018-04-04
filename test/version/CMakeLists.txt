################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

cmake_minimum_required (VERSION 2.8)
project(simple)

find_package(ROCM)

include(ROCMSetupVersion)

rocm_setup_version(VERSION 1.0)

message("PROJECT_VERSION: ${PROJECT_VERSION}")

install(CODE "message(\"No install\")")

macro(test_expect_eq X Y)
    if(${X} EQUAL ${Y} OR ${X} STREQUAL ${Y})
    else()
        message(FATAL_ERROR "EXPECT FAILURE: ${X} != ${Y} ${ARGN}")
    endif()
endmacro()

macro(test_expect_matches X Y)
    if(NOT ${X} MATCHES ${Y})
        message(FATAL_ERROR "EXPECT FAILURE: ${X} != ${Y} ${ARGN}")
    endif()
endmacro()

@CONTENT@
