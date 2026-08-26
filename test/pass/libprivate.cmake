# ######################################################################################################################
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(
    ${TEST_DIR}/libprivate
    CMAKE_ARGS -DROCM_SYMLINK_LIBS=OFF -DROCM_PREFIX=rocm
    TARGETS package)
# Library name is toolchain-specific (relayed as ROCM_STATIC_LIBRARY_*); layout is
# platform-based.
set(_private_lib ${ROCM_STATIC_LIBRARY_PREFIX}simple_private${ROCM_STATIC_LIBRARY_SUFFIX})
if(WIN32)
    test_expect_file(${PREFIX}/include/simpleprivate.h)
    test_expect_file(${PREFIX}/lib/${_private_lib})
else()
    test_expect_file(${PREFIX}/lib/libprivate/include/simpleprivate.h)
    test_expect_file(${PREFIX}/lib/libprivate/lib/${_private_lib})
endif()
install_dir(${TEST_DIR}/libprivate)
