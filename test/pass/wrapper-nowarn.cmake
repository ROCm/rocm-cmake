# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libwrapper
    CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On -DERR_ON_WARN=ON
        -DCMAKE_CXX_FLAGS='-DROCM_NO_WRAPPER_HEADER_WARNING')
test_check_package(
    NAME test-wrapper
    HEADER wrapper.h
    TARGET wrapper)
test_check_package(
    NAME test-wrapper
    HEADER wrapper/wrapper.h
    TARGET wrapper
)
test_check_package(
    NAME test-wrapper
    HEADER other.h
    TARGET wrapper)
test_check_package(
    NAME test-wrapper
    HEADER other/other.h
    TARGET wrapper
)
test_check_package(
    NAME test-wrapper
    HEADER other/th/two-letter-dir.h
    TARGET wrapper)
test_check_package(
    NAME test-wrapper
    HEADER th/two-letter-dir.h
    TARGET wrapper
)
