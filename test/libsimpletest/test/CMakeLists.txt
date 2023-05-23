

rocm_test_link_libraries(simple)
rocm_add_test_executable(simple-test ../test.cpp)
rocm_test_headers(HEADERS ../include/simple.h)
