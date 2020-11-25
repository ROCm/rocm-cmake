# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

find_program(GIT NAMES git)

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
    ${TMP_DIR}/repo 1.0 "
    test_expect_eq(\${CPACK_DEBIAN_PACKAGE_RELEASE} $ENV{CPACK_DEBIAN_PACKAGE_RELEASE})
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
