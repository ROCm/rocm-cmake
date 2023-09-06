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

rocm_cmake_add_test_argument(CMAKE_MAKE_PROGRAM FILEPATH "Make program to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_GENERATOR STRING "Generator to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_GENERATOR_INSTANCE STRING "Generator instance to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_GENERATOR_PLATFORM STRING "Generator platform to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_GENERATOR_TOOLSET STRING "Generator toolset to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_PREFIX_PATH PATH "Prefix path to relay to test projects")
rocm_cmake_add_test_argument(CMAKE_PROGRAM_PATH PATH "Program path to relay to test projects")

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
