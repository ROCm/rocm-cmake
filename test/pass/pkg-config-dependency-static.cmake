################################################################################
# Copyright (C) 2020 Advanced Micro Devices, Inc.
################################################################################

install_dir(${TEST_DIR}/libsimplez CMAKE_ARGS -DBUILD_SHARED_LIBS=Off)
test_check_package(NAME simplez HEADER simplez.h TARGET simplez)
