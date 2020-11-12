# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

find_program(GIT NAMES git)

set(ENV{ROCM_LIBPATCH_VERSION} "21001")

# Try to test without git
file(MAKE_DIRECTORY ${TMP_DIR}/repo)
execute_process(
    COMMAND ${GIT} describe --dirty --long --always
    WORKING_DIRECTORY ${TMP_DIR}/repo
    OUTPUT_VARIABLE GIT_TAG
    RESULT_VARIABLE RESULT)
if(NOT ${RESULT} EQUAL 0)
    set(GIT_TAG 0)
endif()

write_version_cmake(
    ${TMP_DIR}/repo
    "4.5.6"
    "
    test_expect_eq(\${PROJECT_VERSION_MAJOR} 4)
    test_expect_eq(\${PROJECT_VERSION_MINOR} 5)
    test_expect_eq(\${PROJECT_VERSION_PATCH} 6)
    test_expect_eq(\${PROJECT_VERSION}
        \${PROJECT_VERSION_MAJOR}.\${PROJECT_VERSION_MINOR}.\${PROJECT_VERSION_PATCH})
    test_expect_eq(\${CPACK_PACKAGE_VERSION} \${PROJECT_VERSION}.\$ENV{ROCM_LIBPATCH_VERSION})
")

install_dir(${TEST_DIR}/libsimple TARGETS package)
test_check_package(
    NAME simple
    HEADER simple.h
    TARGET simple)
install_dir(${TEST_DIR}/libbasic)
install_dir(${TEST_DIR}/libsimple2 TARGETS package)
test_check_package(
    NAME simple2
    HEADER simple2.h
    TARGET simple2)
