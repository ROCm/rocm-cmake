# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

get_filename_component(_new_rocmcmakebuildtools_path "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(_new_rocmcmakebuildtools_path "${_new_rocmcmakebuildtools_path}" DIRECTORY)
# two directories up is sufficient for windows search, but linux search requires the share directory
get_filename_component(_new_rocmcmakebuildtools_path_linux "${_new_rocmcmakebuildtools_path}" DIRECTORY)

if (${${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED})
    set(_required_arg REQUIRED)
endif()
if (${${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIET})
    set(_quiet_arg QUIET)
endif()
if (${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION_RANGE})
    set(_version_args ${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION_RANGE})
elseif(${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION})
    set(_version_args ${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION})
    if (${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION_EXACT})
        set(_version_args ${_version_args} EXACT)
    endif()
endif()

find_package(
    ROCmCMakeBuildTools
    ${_version_args}
    ${_required_arg}
    ${_quiet_arg}
    HINTS
        "${_new_rocmcmakebuildtools_path}"
        "${_new_rocmcmakebuildtools_path_linux}")
set(ROCM_FOUND ${ROCmCMakeBuildTools_FOUND})
