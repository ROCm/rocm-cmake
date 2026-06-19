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

# test.cmake runs in script mode (cmake -P) where MSVC is never set, and the test
# projects may build with a different generator/compiler than this build. Detect
# once -- using the same generator/toolset and inherited CC/CXX the test projects
# use -- whether that toolchain targets the MSVC ABI (cl, clang-cl, or clang++
# targeting *-windows-msvc) and relay the result as ROCM_MSVC. Only Windows can be
# MSVC, so the probe (which requires a working compiler) is skipped elsewhere.
set(ROCM_MSVC OFF)
if(CMAKE_HOST_WIN32)
    set(_msvc_src ${CMAKE_CURRENT_BINARY_DIR}/msvc-probe)
    set(_msvc_build ${_msvc_src}/build)
    file(WRITE ${_msvc_src}/CMakeLists.txt
         "cmake_minimum_required(VERSION 3.5)\n"
         "project(rocm_msvc_probe CXX)\n"
         "file(WRITE \"\${CMAKE_BINARY_DIR}/msvc.txt\" \"\${MSVC}\")\n")
    set(_msvc_args)
    if(NOT "${ROCM_CMAKE_GENERATOR}" STREQUAL "")
        list(APPEND _msvc_args -G "${ROCM_CMAKE_GENERATOR}")
    endif()
    foreach(_var CMAKE_MAKE_PROGRAM CMAKE_GENERATOR_INSTANCE CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET)
        if(DEFINED ROCM_${_var} AND NOT "${ROCM_${_var}}" STREQUAL "")
            list(APPEND _msvc_args -D "${_var}=${ROCM_${_var}}")
        endif()
    endforeach()
    file(REMOVE_RECURSE ${_msvc_build})
    file(MAKE_DIRECTORY ${_msvc_build})
    execute_process(
        COMMAND ${CMAKE_COMMAND} ${_msvc_args} ${_msvc_src}
        WORKING_DIRECTORY ${_msvc_build}
        RESULT_VARIABLE _msvc_result
        OUTPUT_QUIET ERROR_QUIET)
    if(_msvc_result EQUAL 0 AND EXISTS ${_msvc_build}/msvc.txt)
        file(READ ${_msvc_build}/msvc.txt _msvc_value)
        string(STRIP "${_msvc_value}" _msvc_value)
        if(_msvc_value)
            set(ROCM_MSVC ON)
        endif()
    else()
        message(WARNING "rocm-cmake tests: could not probe MSVC; assuming non-MSVC toolchain")
    endif()
endif()
list(APPEND TEST_ARGUMENTS -D "ROCM_MSVC:BOOL=${ROCM_MSVC}")

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
