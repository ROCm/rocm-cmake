# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libwrapper CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On)
test_check_package(
    NAME wrapper
    HEADER wrapper.h
    TARGET wrapper)
test_check_package(
    NAME wrapper
    HEADER wrapper/wrapper.h
    TARGET wrapper
)
