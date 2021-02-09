# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

file(MAKE_DIRECTORY ${TMP_DIR}/repo)
write_version_cmake(
    ${TMP_DIR}/repo
    "1.0 NO_GIT_TAG_VERSION"
    "
    test_expect_eq(\${PROJECT_VERSION_MAJOR} 1)
    test_expect_eq(\${PROJECT_VERSION_MINOR} 0)
    test_expect_eq(\${PROJECT_VERSION_PATCH} 0)
    test_expect_eq(\${PROJECT_VERSION}
        \${PROJECT_VERSION_MAJOR}.\${PROJECT_VERSION_MINOR}.\${PROJECT_VERSION_PATCH})
")
install_dir(${TMP_DIR}/repo)
