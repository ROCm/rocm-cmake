################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
################################################################################

macro(rocm_cmake_add_test_argument CMAKE_VAR VAR_TYPE DOC_STRING)
    set(ROCM_${CMAKE_VAR} "${${CMAKE_VAR}}" CACHE ${VAR_TYPE} "${DOC_STRING}")
    if(DEFINED ${CMAKE_VAR})
        string(REPLACE ";" "|" ROCM_${CMAKE_VAR} "${ROCM_${CMAKE_VAR}}")
        # Some variables, such as CMAKE_GENERATOR_INSTANCE will be INTERNAL empty vars
        # and relaying/setting them as empty vars explicitly will conflict with makefile
        # generators
        if(NOT "${${CMAKE_VAR}}" STREQUAL "")
            list(APPEND TEST_ARGUMENTS -D "ROCM_${CMAKE_VAR}:${VAR_TYPE}=${ROCM_${CMAKE_VAR}}")
        endif()
    endif()
endmacro()

rocm_cmake_add_test_argument(CMAKE_GENERATOR STRING "Generator to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_PREFIX_PATH PATH "Prefix path to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_PROGRAM_PATH PATH "Program path to relay to test projects")
if(ROCM_CMAKE_GENERATOR STREQUAL "${CMAKE_GENERATOR}")
    rocm_cmake_add_test_argument(CMAKE_GENERATOR_INSTANCE STRING "Generator instance to relay to test projects")
    rocm_cmake_add_test_argument(CMAKE_GENERATOR_PLATFORM STRING "Generator platform to relay to test projects")
    rocm_cmake_add_test_argument(CMAKE_GENERATOR_TOOLSET STRING "Generator toolset to relay to test projects")
    rocm_cmake_add_test_argument(CMAKE_MAKE_PROGRAM FILEPATH "Make program to relay to test projects")
endif()

# Probe the static library naming the test projects use and relay it: cmake -P
# can't know it, and MSVC is unreliable (clang++ is GNU-like yet still emits
# name.lib). Use the relayed generator/toolset + inherited CC/CXX; default to
# unix, probe only on windows.
set(ROCM_STATIC_LIBRARY_PREFIX "lib")
set(ROCM_STATIC_LIBRARY_SUFFIX ".a")
if(CMAKE_HOST_WIN32)
    set(_probe_src ${CMAKE_CURRENT_BINARY_DIR}/libname-probe)
    set(_probe_build ${_probe_src}/build)
    file(WRITE ${_probe_src}/CMakeLists.txt
         "cmake_minimum_required(VERSION 3.5)\n"
         "project(rocm_libname_probe CXX)\n"
         "file(WRITE \${CMAKE_BINARY_DIR}/prefix.txt \"\${CMAKE_STATIC_LIBRARY_PREFIX}\")\n"
         "file(WRITE \${CMAKE_BINARY_DIR}/suffix.txt \"\${CMAKE_STATIC_LIBRARY_SUFFIX}\")\n")
    set(_probe_args)
    if(NOT "${ROCM_CMAKE_GENERATOR}" STREQUAL "")
        list(APPEND _probe_args -G "${ROCM_CMAKE_GENERATOR}")
    endif()
    foreach(_var CMAKE_MAKE_PROGRAM CMAKE_GENERATOR_INSTANCE CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET)
        if(DEFINED ROCM_${_var} AND NOT "${ROCM_${_var}}" STREQUAL "")
            list(APPEND _probe_args -D "${_var}=${ROCM_${_var}}")
        endif()
    endforeach()
    file(REMOVE_RECURSE ${_probe_build})
    file(MAKE_DIRECTORY ${_probe_build})
    execute_process(
        COMMAND ${CMAKE_COMMAND} ${_probe_args} ${_probe_src}
        WORKING_DIRECTORY ${_probe_build}
        RESULT_VARIABLE _probe_result
        OUTPUT_QUIET ERROR_QUIET)
    if(_probe_result EQUAL 0 AND EXISTS ${_probe_build}/suffix.txt)
        file(READ ${_probe_build}/prefix.txt ROCM_STATIC_LIBRARY_PREFIX)
        file(READ ${_probe_build}/suffix.txt ROCM_STATIC_LIBRARY_SUFFIX)
    else()
        message(WARNING "rocm-cmake tests: could not probe static library naming")
    endif()
endif()
list(APPEND TEST_ARGUMENTS -D "ROCM_STATIC_LIBRARY_PREFIX:STRING=${ROCM_STATIC_LIBRARY_PREFIX}")
list(APPEND TEST_ARGUMENTS -D "ROCM_STATIC_LIBRARY_SUFFIX:STRING=${ROCM_STATIC_LIBRARY_SUFFIX}")

function(rocm_cmake_create_test NAME TEST)
    add_custom_target(${NAME} COMMAND ${CMAKE_COMMAND} ${TEST_ARGUMENTS} -P ${CMAKE_CURRENT_SOURCE_DIR}/test.cmake ${TEST} ${CMAKE_CURRENT_BINARY_DIR}/tmp/${NAME})
    add_test(NAME ${NAME} COMMAND ${CMAKE_COMMAND} ${TEST_ARGUMENTS} -P ${CMAKE_CURRENT_SOURCE_DIR}/test.cmake ${TEST} ${CMAKE_CURRENT_BINARY_DIR}/tmp/${NAME} COMMAND_EXPAND_LISTS)
endfunction()

file(GLOB PASS_TESTS pass/*.cmake)
foreach(TEST ${PASS_TESTS})
    get_filename_component(NAME ${TEST} NAME_WE)
    rocm_cmake_create_test(pass-${NAME} ${TEST})
endforeach()

file(GLOB FAIL_TESTS fail/*.cmake)
foreach(TEST ${FAIL_TESTS})
    get_filename_component(NAME ${TEST} NAME_WE)
    rocm_cmake_create_test(fail-${NAME} ${TEST})
    set_tests_properties(fail-${NAME} PROPERTIES WILL_FAIL On)
endforeach()
