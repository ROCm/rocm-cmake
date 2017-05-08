
cmake_minimum_required (VERSION 2.8)
project(simple)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)

rocm_setup_version(VERSION 1.0.0)

add_library(simple simple.cpp)

rocm_install_targets(TARGETS simple INCLUDE include)
rocm_export_targets(TARGETS simple)
