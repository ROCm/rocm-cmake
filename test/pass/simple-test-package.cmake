# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

configure_dir(${TEST_DIR}/libsimpletest TARGETS package BUILD_DIR_VAR BUILD_DIR)
file(GLOB TEST_PACKAGE ${BUILD_DIR}/*-tests.tar.gz)
list(LENGTH TEST_PACKAGE NTEST_PACKAGE)
test_expect_eq(${NTEST_PACKAGE} 1)
test_exec(COMMAND ${CMAKE_COMMAND} -E tar t ${TEST_PACKAGE})
test_exec(COMMAND ${CMAKE_COMMAND} -E tar x ${TEST_PACKAGE} WORKING_DIRECTORY /)
test_expect_file(${PREFIX}/libexec/installed-tests/simple/CTestTestfile.cmake)
