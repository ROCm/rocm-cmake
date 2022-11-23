# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(test_expect_version PATH KIND EXPECTED_VERSION)
    test_exec(COMMAND powershell -command "(GET-ITEM ${PATH}).VersionInfo.${KIND}" OUTPUT_VARIABLE TEST_VERSION)
    string(STRIP "${TEST_VERSION}" TEST_VERSION)
    test_expect_eq("${TEST_VERSION}" "${EXPECTED_VERSION}")
endfunction()

install_dir(${TEST_DIR}/libsimple CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On)
if(WIN32)
    test_expect_file(${PREFIX}/bin/simple.dll)
    test_expect_version(${PREFIX}/bin/simple.dll FileVersion 1.1.2)
    test_expect_version(${PREFIX}/bin/simple.dll ProductVersion 1.0.0)

    test_expect_file(${PREFIX}/lib/simple.lib)
endif()
