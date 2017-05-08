
cmake_minimum_required (VERSION 2.8)
project(basic)

find_package(ROCM)
find_package(simple)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)

rocm_setup_version(VERSION 1.0.0)

add_library(basic main.cpp)
target_link_libraries(basic simple)

rocm_install_targets(TARGETS basic)
rocm_export_targets(TARGETS basic)

