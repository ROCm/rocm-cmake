# ######################################################################################################################
# Copyright (C) 2020 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libsimple CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On)
test_check_package(
    NAME simple
    HEADER simple.h
    TARGET simple)
install_dir(${TEST_DIR}/libbasic CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On)
test_check_package(
    NAME basic
    HEADER basic.h
    TARGET basic)
