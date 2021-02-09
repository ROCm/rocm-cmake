# ######################################################################################################################
# Copyright (C) 2019 Advanced Micro Devices, Inc.
# ######################################################################################################################

if(UNIX)
    configure_dir(${TEST_DIR}/toolchain-var CMAKE_ARGS -DCHANGE_TOOLCHAIN=On)
else()
    message(FATAL_ERROR "Skipped on windows")
endif()
