################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

install_dir(${TEST_DIR}/libsimple TARGETS package)
test_check_package(NAME simple HEADER simple.h TARGET simple)
install_dir(${TEST_DIR}/libbasic)
install_dir(${TEST_DIR}/libsimple2 TARGETS package)
test_check_package(NAME simple2 HEADER simple2.h TARGET simple2)
