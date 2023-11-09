# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

get_filename_component(_new_rocmcmakebuildtools_path "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(_new_rocmcmakebuildtools_path "${_new_rocmcmakebuildtools_path}" DIRECTORY)
set(ROCmCMakeBuildTools_ROOT "${_new_rocmcmakebuildtools_path}/rocmcmakebuildtools/cmake")

# this should find ROCmCMakeBuildTools using the ROCmCMakeBuildTools variable
cmake_policy(SET CMP0074 NEW)
find_package(ROCmCMakeBuildTools REQUIRED)
