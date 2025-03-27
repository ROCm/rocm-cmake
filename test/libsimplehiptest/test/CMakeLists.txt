

rocm_test_link_libraries(simple)
rocm_add_test_executable(simple-test ../test.cpp)
rocm_test_headers(HEADERS ../include/simple.h)
rocm_test_target_hip_runtime_include(TARGET simple-main)
