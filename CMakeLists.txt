################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

cmake_minimum_required (VERSION 3.6)

set(CMAKE_INSTALL_PREFIX "/opt/rocm" CACHE PATH "")

project(rocm-cmake LANGUAGES NONE)

install(DIRECTORY share DESTINATION .)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ROCMConfigVersion.cmake DESTINATION share/rocm/cmake)

set(CPACK_RPM_PACKAGE_LICENSE "MIT")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/share/rocm/cmake)
include(ROCMCreatePackage)
include(ROCMSetupVersion)

rocm_setup_version(VERSION 0.11.0)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/ROCMConfigVersion.cmake
    COMPATIBILITY SameMajorVersion)

rocm_create_package(
    NAME rocm-cmake
    MAINTAINER "Paul Fultz II pfultz@amd.com"
)

set(CONFIGURE_DEPENDS)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
set(CONFIGURE_DEPENDS CONFIGURE_DEPENDS)
endif()
file(GLOB_RECURSE CMAKE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CONFIGURE_DEPENDS} share/*.cmake test/*.cmake)

add_custom_target(analyze COMMAND cmake-lint ${CMAKE_FILES} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_target(format COMMAND cmake-format -i ${CMAKE_FILES} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

enable_testing()
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C ${CMAKE_CFG_INTDIR})
add_subdirectory(test)
add_subdirectory(doc)

