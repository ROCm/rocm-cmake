# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

cmake_minimum_required(VERSION 3.5...3.31.0)
project(fortranconfigcheck NONE)

find_package(${PKG} REQUIRED)

if(EXPECT_FORTRAN)
    if(NOT TARGET simple_fortran OR NOT simple_FORTRAN_FOUND)
        message(FATAL_ERROR "find_package(${PKG}) did not load simple-fortran.")
    endif()
    if(NOT simple_FORTRAN_DIR STREQUAL EXPECT_FORTRAN_DIR)
        message(FATAL_ERROR "simple-fortran loaded from ${simple_FORTRAN_DIR}, not ${EXPECT_FORTRAN_DIR}.")
    endif()
elseif(TARGET simple_fortran OR DEFINED simple_FORTRAN_FOUND)
    message(FATAL_ERROR "find_package(${PKG}) loaded a simple-fortran that is not installed.")
endif()
