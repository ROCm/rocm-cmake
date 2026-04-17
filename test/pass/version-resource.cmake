# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

if(WIN32)
    configure_dir(${TEST_DIR}/versionresource TARGETS all BUILD_DIR_VAR BUILD_DIR)
    test_expect_file(${BUILD_DIR}/mylib_version.rc)
    test_expect_file(${BUILD_DIR}/myapp_version.rc)
endif()
