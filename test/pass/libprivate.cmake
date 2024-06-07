# ######################################################################################################################
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(
    ${TEST_DIR}/libprivate
    CMAKE_ARGS -DROCM_SYMLINK_LIBS=OFF -DROCM_PREFIX=rocm
    TARGETS package)
test_expect_file(${PREFIX}/lib/libprivate/include/simpleprivate.h)
test_expect_file(${PREFIX}/lib/libprivate/lib/libsimple_private.a)
install_dir(${TEST_DIR}/libprivate)
