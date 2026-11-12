# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(ENV{CMAKE_INSTALL_MODE} "SYMLINK")
install_dir(
    ${TEST_DIR}/libsimple
    CMAKE_ARGS -DROCM_PREFIX=simple
    TARGETS package)
test_expect_file(${PREFIX}/include/simple.h)
if(NOT WIN32)
    test_expect_file(${PREFIX}/simple/include/simple.h)
endif()
install_dir(${TEST_DIR}/libbasic)
