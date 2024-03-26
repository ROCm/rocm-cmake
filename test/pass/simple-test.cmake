# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libsimpletest TARGETS check install-tests)
test_expect_file(${PREFIX}/libexec/installed-tests/simple/CTestTestfile.cmake)
test_exec(COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure WORKING_DIRECTORY ${PREFIX}/libexec/installed-tests/simple)
