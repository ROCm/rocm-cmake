# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

get_filename_component(_new_rocmcmakebuildtools_path "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(_new_rocmcmakebuildtools_path "${_new_rocmcmakebuildtools_path}" DIRECTORY)
# two directories up is sufficient for windows search, but linux search requires the share directory
get_filename_component(_new_rocmcmakebuildtools_path_linux "${_new_rocmcmakebuildtools_path}" DIRECTORY)

include(CMakeFindDependencyMacro)

find_dependency(
    ROCmCMakeBuildTools
    HINTS
        "${_new_rocmcmakebuildtools_path}"
        "${_new_rocmcmakebuildtools_path_linux}")

unset(_new_rocmcmakebuildtools_path)
unset(_new_rocmcmakebuildtools_path_linux)
