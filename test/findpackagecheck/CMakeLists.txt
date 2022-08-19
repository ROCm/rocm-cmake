
cmake_minimum_required (VERSION 3.5)
project(findpackagecheck CXX)

message(STATUS "PKG: ${PKG}")
message(STATUS "PKG_TARGET: ${PKG_TARGET}")
message(STATUS "CHECK_TARGET: ${CHECK_TARGET}")

find_package(${PKG})

if(NOT TARGET ${CHECK_TARGET})
    message(FATAL_ERROR "Target ${CHECK_TARGET} is missing.")
endif()

configure_file(main.cpp.in main.cpp @ONLY)

add_executable(main ${CMAKE_CURRENT_BINARY_DIR}/main.cpp)
target_link_libraries(main ${PKG_TARGET})
install(TARGETS main DESTINATION bin)
