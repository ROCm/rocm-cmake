################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 3.5...3.31.0)
project(test-wrapper CXX)

find_package(ROCmCMakeBuildTools)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)
include(ROCMCreatePackage)
include(ROCMHeaderWrapper)

rocm_setup_version(VERSION 1.0.0)

if(ROCM_PREFIX)
rocm_create_package(
    NAME wrapper
    PREFIX ${ROCM_PREFIX}
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG)
else()
rocm_create_package(
    NAME wrapper
    MAINTAINER "Amd amd@amd.com"
    PTH
    LDCONFIG)
endif()

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

option(ERR_ON_WARN "Treat all warnings as errors." OFF)
if(ERR_ON_WARN)
    if(MSVC)
        add_compile_options(/W4 /WX)
    else()
        add_compile_options(-Wall -Wextra -pedantic -Werror)
    endif()
endif()

add_library(wrapper wrapper.cpp)
rocm_set_soversion(wrapper 1.1.2)

add_executable(wrapper-use-wrapper use_wrapper.cpp)
target_link_libraries(wrapper-use-wrapper wrapper)

add_executable(wrapper-use-original use_original.cpp)
target_link_libraries(wrapper-use-original wrapper)

rocm_wrap_header_file(
    wrapper.h
    HEADER_LOCATION include/wrapper
    GUARDS TESTWRAPPER
    WRAPPER_LOCATIONS include
)

rocm_wrap_header_dir(
    "${CMAKE_CURRENT_LIST_DIR}/include/other"
    HEADER_LOCATION include/other
    GUARDS TESTWRAPPER
    WRAPPER_LOCATIONS include
)

rocm_install_targets(TARGETS wrapper wrapper-use-wrapper wrapper-use-original INCLUDE include ${CMAKE_CURRENT_BINARY_DIR}/include)
rocm_export_targets(TARGETS wrapper INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/importtarget.cmake)
