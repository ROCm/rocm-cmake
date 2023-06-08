# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

message(INFO
    "Use of find_package(ROCM) is deprecated as of <version>, and will be removed in <version>, "
    "please switch to find_package(ROCmCMakeBuildTools)."
)
find_package(ROCmCMakeBuildTools PATHS .)
