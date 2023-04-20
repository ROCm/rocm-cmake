# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(test_expect_version PATH KIND EXPECTED_VERSION)
    test_exec(COMMAND powershell -command "(GET-ITEM ${PATH}).VersionInfo.${KIND}" OUTPUT_VARIABLE TEST_VERSION)
    string(STRIP "${TEST_VERSION}" TEST_VERSION)
    test_expect_eq(${TEST_VERSION} ${EXPECTED_VERSION})
endfunction()

set(ENV{ROCM_DLL_FILE_VERSION} 1.2.3)
set(ENV{ROCM_DLL_VERSION} 4.5.6)
install_dir(${TEST_DIR}/libsimple CMAKE_ARGS -DBUILD_SHARED_LIBS=On -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On)
if(WIN32)
    test_expect_file(${PREFIX}/bin/simple.dll)
    test_expect_version(${PREFIX}/bin/simple.dll FileVersion 1.2.3)
    test_expect_version(${PREFIX}/bin/simple.dll ProductVersion 4.5.6)

    test_expect_file(${PREFIX}/lib/simple.lib)
endif()
