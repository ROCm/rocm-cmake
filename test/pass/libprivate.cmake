# ######################################################################################################################
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(
    ${TEST_DIR}/libprivate
    CMAKE_ARGS -DROCM_SYMLINK_LIBS=OFF -DROCM_PREFIX=rocm
    TARGETS package)
if(WIN32)
    if(ROCM_CMAKE_GENERATOR MATCHES "Ninja")
        test_expect_file(${PREFIX}/include/simpleprivate.h)
        test_expect_file(${PREFIX}/lib/simple_private.a)
    else()
        test_expect_file(${PREFIX}/include/simpleprivate.h)
        test_expect_file(${PREFIX}/lib/simple_private.lib)
    endif()
else()
    test_expect_file(${PREFIX}/lib/libprivate/include/simpleprivate.h)
    test_expect_file(${PREFIX}/lib/libprivate/lib/libsimple_private.a)
endif()
install_dir(${TEST_DIR}/libprivate)
