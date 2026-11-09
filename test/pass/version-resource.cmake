# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

macro(test_expect_contains TEXT SUBSTRING)
    string(FIND "${TEXT}" "${SUBSTRING}" _test_expect_contains_pos)
    if(_test_expect_contains_pos EQUAL -1)
        message(FATAL_ERROR "EXPECT FAILURE: text does not contain '${SUBSTRING}':\n${TEXT}")
    endif()
endmacro()

macro(test_expect_not_contains TEXT SUBSTRING)
    string(FIND "${TEXT}" "${SUBSTRING}" _test_expect_contains_pos)
    if(NOT _test_expect_contains_pos EQUAL -1)
        message(FATAL_ERROR "EXPECT FAILURE: text contains '${SUBSTRING}':\n${TEXT}")
    endif()
endmacro()

configure_dir(${TEST_DIR}/versionresource TARGETS all BUILD_DIR_VAR BUILD_DIR)

if(NOT WIN32)
    # The new keyword arguments must parse everywhere, but only Windows gets a resource.
    test_expect_no_file(${BUILD_DIR}/mylib_version.rc)
    test_expect_no_file(${BUILD_DIR}/mylib2_version.rc)
    return()
endif()

test_expect_file(${BUILD_DIR}/mylib_version.rc)
test_expect_file(${BUILD_DIR}/myapp_version.rc)
test_expect_file(${BUILD_DIR}/mylib2_version.rc)

file(READ ${BUILD_DIR}/mylib_version.rc MYLIB_RC)
test_expect_contains("${MYLIB_RC}" "FILETYPE        VFT_DLL")
test_expect_contains("${MYLIB_RC}" "\"ProductName\", \"MyLib mylib.dll\\0\"")
test_expect_not_contains("${MYLIB_RC}" "Comments")

file(READ ${BUILD_DIR}/myapp_version.rc MYAPP_RC)
test_expect_contains("${MYAPP_RC}" "FILETYPE        VFT_APP")
test_expect_contains("${MYAPP_RC}" "\"OriginalFilename\", \"myapp.exe\\0\"")

file(READ ${BUILD_DIR}/mylib2_version.rc MYLIB2_RC)
test_expect_contains("${MYLIB2_RC}" "\"OriginalFilename\", \"librenamed.dll\\0\"")
test_expect_contains("${MYLIB2_RC}" "\"ProductName\", \"My Product 1.2\\0\"")
test_expect_contains("${MYLIB2_RC}" "\"FileDescription\", \"Test \"\"quoted\"\" description\\0\"")
test_expect_contains("${MYLIB2_RC}" "\"Comments\", \"Git commit: 0123abcd C:\\\\path\\0\"")

# The resource has to reach the linked binary, not just the generated .rc file.
file(GLOB_RECURSE MYLIB2_DLL ${BUILD_DIR}/librenamed.dll)
list(LENGTH MYLIB2_DLL MYLIB2_DLL_COUNT)
test_expect_eq(${MYLIB2_DLL_COUNT} 1)
file(STRINGS ${MYLIB2_DLL} MYLIB2_DLL_STRINGS ENCODING UTF-16LE)
test_expect_contains("${MYLIB2_DLL_STRINGS}" "Git commit: 0123abcd C:\\path")
test_expect_contains("${MYLIB2_DLL_STRINGS}" "Test \"quoted\" description")

# Reconfiguring with unchanged inputs must not rewrite the .rc, or every target relinks.
file(TIMESTAMP ${BUILD_DIR}/mylib_version.rc MYLIB_RC_TIME_BEFORE "%Y-%m-%dT%H:%M:%S")
execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 2)
test_exec(COMMAND ${CMAKE_COMMAND} ${BUILD_DIR} WORKING_DIRECTORY ${BUILD_DIR})
file(TIMESTAMP ${BUILD_DIR}/mylib_version.rc MYLIB_RC_TIME_AFTER "%Y-%m-%dT%H:%M:%S")
test_expect_eq("${MYLIB_RC_TIME_BEFORE}" "${MYLIB_RC_TIME_AFTER}")
