# ######################################################################################################################
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(
    ${TEST_DIR}/libprivate
    CMAKE_ARGS -DROCM_SYMLINK_LIBS=OFF -DROCM_PREFIX=rocm
    TARGETS package)
# The static library file name depends on the toolchain (e.g. simple_private.lib
# for cl/clang++ vs libsimple_private.a for gcc), which the harness relays as
# ROCM_STATIC_LIBRARY_PREFIX/SUFFIX. The install layout is platform-based (flat on
# windows, nested under lib/libprivate elsewhere).
set(_private_lib ${ROCM_STATIC_LIBRARY_PREFIX}simple_private${ROCM_STATIC_LIBRARY_SUFFIX})
if(WIN32)
    test_expect_file(${PREFIX}/include/simpleprivate.h)
    test_expect_file(${PREFIX}/lib/${_private_lib})
else()
    test_expect_file(${PREFIX}/lib/libprivate/include/simpleprivate.h)
    test_expect_file(${PREFIX}/lib/libprivate/lib/${_private_lib})
endif()
install_dir(${TEST_DIR}/libprivate)
