################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

find_program(GIT NAMES git)

file(MAKE_DIRECTORY ${TMP_DIR}/repo)
test_exec(COMMAND ${GIT} init WORKING_DIRECTORY ${TMP_DIR}/repo)
write_version_cmake(${TMP_DIR}/repo 1.0 "
    test_expect_eq(\${PROJECT_VERSION_MAJOR} 1)
    test_expect_eq(\${PROJECT_VERSION_MINOR} 0)
    test_expect_eq(\${PROJECT_VERSION_PATCH} 0)
    test_expect_eq(\${PROJECT_VERSION} \${PROJECT_VERSION_MAJOR}.\${PROJECT_VERSION_MINOR}.\${PROJECT_VERSION_PATCH}.\${PROJECT_VERSION_TWEAK})
    test_expect_matches(\${PROJECT_VERSION_TWEAK} ^1-[0-9a-f]+\$)
")
test_exec(COMMAND ${GIT} add . WORKING_DIRECTORY ${TMP_DIR}/repo)
test_exec(COMMAND ${GIT} commit -am "Init" WORKING_DIRECTORY ${TMP_DIR}/repo)
install_dir(${TMP_DIR}/repo)
