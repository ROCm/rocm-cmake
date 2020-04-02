################################################################################
# Copyright (C) 2020 Advanced Micro Devices, Inc.
################################################################################


cmake_minimum_required (VERSION 2.8)
project(simplez)

find_package(ROCM)
find_package(PkgConfig)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)

pkg_check_modules(ZLIB REQUIRED IMPORTED_TARGET zlib)

rocm_setup_version(VERSION VERSION 1.0.0)

add_library(simplez main.cpp)
target_link_libraries(simplez PRIVATE PkgConfig::ZLIB)

rocm_install_targets(TARGETS simplez INCLUDE include)
rocm_export_targets(TARGETS simplez STATIC_DEPENDS PKG_CONFIG ZLIB zlib)

