use_rocm_cmake()
include(ROCMUtilities)

rocm_find_program_version(
    ${CMAKE_COMMAND}
    OUTPUT_VARIABLE test_version
)

test_expect_eq("${test_version}" "${CMAKE_VERSION}")
test_expect_eq("${test_version_OK}" TRUE)

rocm_find_program_version(
    ${CMAKE_COMMAND}
    OUTPUT_VARIABLE test_version
    GREATER_THAN "${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.0"
)

test_expect_eq("${test_version_OK}" TRUE)

rocm_find_program_version(
    ${CMAKE_COMMAND}
    OUTPUT_VARIABLE test_version
    LESS "${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.0"
)

test_expect_eq("${test_version_OK}" FALSE)

rocm_find_program_version(
    foobar
    OUTPUT_VARIABLE test_version
)

test_expect_eq("${test_version}" "0.0.0")
test_expect_eq("${test_version_OK}" FALSE)
