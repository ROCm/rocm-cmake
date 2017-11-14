################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

find_program(GIT NAMES git)

function(write_version_cmake DIR CONTENT)
    configure_file(${TEST_DIR}/version/CMakeLists.txt ${DIR}/CMakeLists.txt @ONLY)
endfunction()

file(MAKE_DIRECTORY ${TMP_DIR}/repo1)
test_exec(COMMAND ${GIT} init WORKING_DIRECTORY ${TMP_DIR}/repo1)
write_version_cmake(${TMP_DIR}/repo1 "
    test_expect_eq(\${PROJECT_VERSION} 1.0)
    test_expect_eq(\${PROJECT_VERSION_MAJOR} 1)
    test_expect_eq(\${PROJECT_VERSION_MINOR} 0)
    test_expect_eq(\${PROJECT_VERSION_PATCH} 0)
    test_expect_matches(\${PROJECT_VERSION_TWEAK} ^[0-9a-f]+\$)
")
test_exec(COMMAND ${GIT} add . WORKING_DIRECTORY ${TMP_DIR}/repo1)
test_exec(COMMAND ${GIT} commit -am "Init" WORKING_DIRECTORY ${TMP_DIR}/repo1)
install_dir(${TMP_DIR}/repo1)


file(MAKE_DIRECTORY ${TMP_DIR}/repo2)
write_version_cmake(${TMP_DIR}/repo2 "
    test_expect_eq(\${PROJECT_VERSION} 1.0)
    test_expect_eq(\${PROJECT_VERSION_MAJOR} 1)
    test_expect_eq(\${PROJECT_VERSION_MINOR} 0)
    test_expect_eq(\${PROJECT_VERSION_PATCH} 0)
    test_expect_matches(\${PROJECT_VERSION_TWEAK} -dirty\$)
")
install_dir(${TMP_DIR}/repo2)
