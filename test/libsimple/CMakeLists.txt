
cmake_minimum_required (VERSION 2.8)
project(simple)

find_package(ROCM)

include(ROCMInstallTargets)
include(ROCMPackageConfigHelpers)
include(ROCMSetupVersion)
include(ROCMInstallSymlinks)

rocm_setup_version(VERSION 1.0.0)

add_library(simple simple.cpp)

if(ROCM_PREFIX)
    rocm_install_targets(TARGETS simple INCLUDE include PREFIX ${ROCM_PREFIX})
    rocm_export_targets(TARGETS simple PREFIX ${ROCM_PREFIX})
    rocm_install_symlink_subdir(${ROCM_PREFIX})
else()
    rocm_install_targets(TARGETS simple INCLUDE include)
    rocm_export_targets(TARGETS simple)
endif()
