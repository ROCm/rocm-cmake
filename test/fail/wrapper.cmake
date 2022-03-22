# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

if(NOT MSVC)
    install_dir(${TEST_DIR}/libwrapper
        CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On -DERR_ON_WARN=ON)
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
else()
    # Disable this test on MSVC as we can't emit compiler warnings.
    test_expect_eq(1 2)
endif()
