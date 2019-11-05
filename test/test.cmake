################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


include(CMakeParseArguments)

string(RANDOM _TEST_RAND)
set(TEST ${CMAKE_ARGV3})
set(TEST_DIR ${CMAKE_CURRENT_LIST_DIR})
set(TMP_DIR ${CMAKE_ARGV4}-${_TEST_RAND})
file(MAKE_DIRECTORY ${TMP_DIR})
set(PREFIX ${TMP_DIR}/usr)
set(BUILDS_DIR ${TMP_DIR}/builds)

macro(test_expect_eq X Y)
    if(NOT "${X}" STREQUAL "${Y}")
        message(FATAL_ERROR "EXPECT FAILURE: ${X} != ${Y} ${ARGN}")
    endif()
endmacro()

macro(test_expect_matches X Y)
    if("${X}" STREQUAL "" OR NOT "${X}" MATCHES "${Y}")
        message(FATAL_ERROR "EXPECT FAILURE: ${X} NOT MATCHES ${Y} ${ARGN}")
    endif()
endmacro()

macro(test_expect_not_matches X Y)
    if("${X}" MATCHES "${Y}")
        message(FATAL_ERROR "EXPECT FAILURE: ${X} MATCHES ${Y} ${ARGN}")
    endif()
endmacro()

macro(test_expect_file FILE)
    if(NOT EXISTS ${FILE})
        message(FATAL_ERROR "EXPECT FILE: ${FILE}")
    endif()
endmacro()

macro(test_exec)
    execute_process(${ARGN} RESULT_VARIABLE test_exec_RESULT)
    if(NOT test_exec_RESULT EQUAL 0)
        message(FATAL_ERROR "Process failed: ${ARGN}")
    endif()
endmacro()

function(install_dir DIR)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs CMAKE_ARGS TARGETS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(RANDOM BUILD_RAND)
    set(BUILD_DIR ${BUILDS_DIR}/${BUILD_RAND})
    if(NOT EXISTS ${BUILD_DIR})
        file(MAKE_DIRECTORY ${BUILD_DIR})
    endif()
    test_exec(COMMAND ${CMAKE_COMMAND} 
        -DCMAKE_PREFIX_PATH=${PREFIX} 
        -DCMAKE_INSTALL_PREFIX=${PREFIX}
        ${PARSE_CMAKE_ARGS}
        ${DIR}
        WORKING_DIRECTORY ${BUILD_DIR}
    )
    test_exec(COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR})
    foreach(TARGET ${PARSE_TARGETS})
        test_exec(COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR} --target ${TARGET})
    endforeach()
    test_exec(COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR} --target install)

    file(REMOVE_RECURSE ${BUILD_DIR})
endfunction()

function(write_version_cmake DIR VERSION CONTENT)
    configure_file(${TEST_DIR}/version/CMakeLists.txt ${DIR}/CMakeLists.txt @ONLY)
endfunction()

function(test_check_package)
    set(options)
    set(oneValueArgs NAME HEADER TARGET)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(HEADER_FLAG)
    if(PARSE_HEADER)
        set(HEADER_FLAG -DPKG_HEADER=${PARSE_HEADER})
    endif()

    set(TARGET ${PARSE_NAME})
    if(PARSE_TARGET)
        set(TARGET ${PARSE_TARGET})
    endif()

    install_dir(${TEST_DIR}/findpackagecheck CMAKE_ARGS -DPKG=${PARSE_NAME} -DPKG_TARGET=${TARGET} ${HEADER_FLAG})
endfunction()

install_dir(${TEST_DIR}/../)

include(${TEST})

file(REMOVE_RECURSE ${TMP_DIR})
