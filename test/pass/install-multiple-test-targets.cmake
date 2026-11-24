configure_dir(${TEST_DIR}/installtesttargets TARGETS install-tests)
test_exec(COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
          WORKING_DIRECTORY ${PREFIX}/libexec/installed-tests/multiple-targets)
