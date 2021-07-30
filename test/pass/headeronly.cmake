# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libheaderonly TARGETS package)
test_check_package(
    NAME headeronly
    HEADER headeronly.h
    TARGET headeronly)
