# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

message(NOTICE
    "Use of find_package(ROCM) is deprecated, please switch to find_package(ROCmCMakeBuildTools)."
)
find_package(ROCmCMakeBuildTools HINTS "${CMAKE_CURRENT_LIST_DIR}")
