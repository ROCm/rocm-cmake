# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

cmake_minimum_required(VERSION 3.5...3.31.0)
project(fortranconfigcheck NONE)

find_package(${PKG} REQUIRED)

if(EXPECT_FORTRAN)
    if(NOT TARGET ${BASE}_fortran)
        message(FATAL_ERROR "find_package(${PKG}) did not load ${BASE}-fortran.")
    endif()
    if(NOT ${BASE}_FORTRAN_DIR STREQUAL EXPECT_FORTRAN_DIR)
        message(FATAL_ERROR "${BASE}-fortran loaded from ${${BASE}_FORTRAN_DIR}, not ${EXPECT_FORTRAN_DIR}.")
    endif()
elseif(TARGET ${BASE}_fortran)
    message(FATAL_ERROR "find_package(${PKG}) loaded ${BASE}-fortran.")
endif()

if(NOT "${${BASE}_FORTRAN_FOUND}" STREQUAL "${EXPECT_FORTRAN_FOUND}")
    message(FATAL_ERROR "${BASE}_FORTRAN_FOUND is '${${BASE}_FORTRAN_FOUND}', not '${EXPECT_FORTRAN_FOUND}'.")
endif()
