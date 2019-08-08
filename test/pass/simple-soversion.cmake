################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

function(test_expect_realpath PATH EXPECTED_PATH)
    test_exec(COMMAND realpath ${PATH} OUTPUT_VARIABLE REALPATH)
    string(STRIP "${REALPATH}" REALPATH)
    test_expect_eq(${REALPATH} ${EXPECTED_PATH})
endfunction()

install_dir(${TEST_DIR}/libsimple CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On)
if(NOT WIN32 AND NOT APPLE)
    test_expect_file(${PREFIX}/lib/libsimple.so)
    test_expect_file(${PREFIX}/lib/libsimple.so.1)
    test_expect_file(${PREFIX}/lib/libsimple.so.1.1.2)

    test_expect_realpath(${PREFIX}/lib/libsimple.so ${PREFIX}/lib/libsimple.so.1.1.2)
    test_expect_realpath(${PREFIX}/lib/libsimple.so.1 ${PREFIX}/lib/libsimple.so.1.1.2)

    test_exec(COMMAND ldd ${PREFIX}/bin/simple-main OUTPUT_VARIABLE LIBS)
    test_expect_matches("${LIBS}" "libsimple.so.1 =>")
    test_expect_not_matches("${LIBS}" "libsimple.so =>")
    test_expect_not_matches("${LIBS}" "libsimple.so.1.1.2 =>")
endif()
