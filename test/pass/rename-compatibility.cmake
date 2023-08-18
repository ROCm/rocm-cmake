# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libsimplecompat TARGETS package)
test_check_package(
    NAME simple
    HEADER simple.h
    TARGET simple)
