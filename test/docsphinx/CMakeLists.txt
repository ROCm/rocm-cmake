################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
################################################################################

cmake_minimum_required (VERSION 3.5)
project(useful LANGUAGES CXX)
# Ideally should be NONE, but GNUInstallDirs detects platform arch using try_compile
# https://stackoverflow.com/questions/43379311/why-does-project-affect-cmakes-opinion-on-cmake-sizeof-void-p

find_package(ROCM)

include(ROCMSphinxDoc)
include(GNUInstallDirs)

rocm_add_sphinx_doc(
  "${CMAKE_CURRENT_SOURCE_DIR}/docs"
  BUILDER html
  OUTPUT_DIR html
  USE_DOXYGEN
)

install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html"
  DESTINATION ${CMAKE_INSTALL_DOCDIR}
)
