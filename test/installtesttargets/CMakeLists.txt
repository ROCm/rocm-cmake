cmake_minimum_required(VERSION 3.5...3.31.0)
project(installtesttargets CXX)

find_package(ROCmCMakeBuildTools REQUIRED)
include(ROCMTest)
rocm_enable_test_package(multiple-targets)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/main.cpp" "int main() { return 0; }\n")
foreach(target test-a test-b)
    add_executable(${target} "${CMAKE_CURRENT_BINARY_DIR}/main.cpp")
    rocm_mark_as_test(${target})
    rocm_add_test(NAME ${target} COMMAND ${target})
endforeach()
rocm_install_test(TARGETS test-a test-b)
