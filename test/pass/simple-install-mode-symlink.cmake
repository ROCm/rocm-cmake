# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(ENV{CMAKE_INSTALL_MODE} "SYMLINK")
install_dir(
    ${TEST_DIR}/libsimple
    CMAKE_ARGS
    TARGETS package)
test_expect_file(${PREFIX}/include/simple.h)

install_dir(${TEST_DIR}/libbasic)
