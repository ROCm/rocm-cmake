################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

set(ROCM_CMAKE_GENERATOR "" CACHE STRING "")

function(create_test NAME TEST)
    set(GENERATOR_FLAG)
    if(ROCM_CMAKE_GENERATOR)
        set(GENERATOR_FLAG "-DROCM_CMAKE_GENERATOR=${ROCM_CMAKE_GENERATOR}")
    endif()
    add_custom_target(${NAME} COMMAND ${CMAKE_COMMAND} ${GENERATOR_FLAG} -P ${CMAKE_CURRENT_SOURCE_DIR}/test.cmake ${TEST} ${CMAKE_CURRENT_BINARY_DIR}/tmp/${NAME})
    add_test(NAME ${NAME} COMMAND ${CMAKE_COMMAND} ${GENERATOR_FLAG} -P ${CMAKE_CURRENT_SOURCE_DIR}/test.cmake ${TEST} ${CMAKE_CURRENT_BINARY_DIR}/tmp/${NAME})
endfunction()

file(GLOB PASS_TESTS pass/*.cmake)
foreach(TEST ${PASS_TESTS})
    get_filename_component(NAME ${TEST} NAME_WE)
    create_test(pass-${NAME} ${TEST})
endforeach()

file(GLOB FAIL_TESTS fail/*.cmake)
# Disable wrapper fail test, as the warning is changed to message
# This is temporary and will be enabled back later when the behavior is reverted
list(FILTER FAIL_TESTS EXCLUDE REGEX ".*wrapper\.cmake$")

foreach(TEST ${FAIL_TESTS})
    get_filename_component(NAME ${TEST} NAME_WE)
    create_test(fail-${NAME} ${TEST})
    set_tests_properties(fail-${NAME} PROPERTIES WILL_FAIL On)
endforeach()
