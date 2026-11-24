

rocm_test_link_libraries(simple)
rocm_add_test_executable(simple-test ../test.cpp)
set_tests_properties(simple-test PROPERTIES LABELS "smoke")
rocm_test_headers(HEADERS ../include/simple.h)
