################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

cmake_minimum_required (VERSION 3.5...3.31.0)
project(simple LANGUAGES NONE)

find_package(ROCmCMakeBuildTools)

include(ROCMSetupVersion)
include(ROCMCreatePackage)

rocm_setup_version(VERSION @VERSION@)
message("VERSION: @VERSION@")
message("PROJECT_VERSION: ${PROJECT_VERSION}")

install(CODE "message(\"No install\")")

macro(test_expect_eq X Y)
    if("${X}" STREQUAL "${Y}")
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

rocm_create_package(
    NAME simple
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG)
