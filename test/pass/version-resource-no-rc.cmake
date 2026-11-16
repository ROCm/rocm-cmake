# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

if(WIN32)
    # Toolchains signal a missing resource compiler with this sentinel; the helper must skip
    # the resource instead of breaking the build.
    configure_dir(
        ${TEST_DIR}/versionresource
        TARGETS all
        BUILD_DIR_VAR BUILD_DIR
        CMAKE_ARGS -DCMAKE_RC_COMPILER=CMAKE_RC_COMPILER-NOTREQUIRED)
    test_expect_no_file(${BUILD_DIR}/mylib_version.rc)
    test_expect_no_file(${BUILD_DIR}/myapp_version.rc)
    test_expect_no_file(${BUILD_DIR}/mylib2_version.rc)
endif()
