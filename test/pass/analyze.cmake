# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/analyze TARGETS analyze analyze)

install_dir(
    ${TEST_DIR}/analyze
    CMAKE_ARGS -DCLANG_TIDY_CACHE_SIZE=0
    TARGETS analyze analyze)
