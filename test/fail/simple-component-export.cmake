# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libsimple3 TARGETS package CMAKE_ARGS -DEXPORT_RUNNABLE=OFF)
test_check_package(
    NAME simple
    HEADER simple.h
    TARGET simple3
    CHECK_TARGET simple-main
)
