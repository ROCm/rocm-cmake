# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

include(CMakeParseArguments)
cmake_policy(SET CMP0011 NEW)

set(SCRIPT_CMAKE_ARGS)
# cmake-lint: disable=E1120
foreach(IDX RANGE ${CMAKE_ARGC})
    list(APPEND SCRIPT_CMAKE_ARGS ${CMAKE_ARGV${IDX}})
endforeach()

cmake_parse_arguments(SCRIPT_ARGS "" "" "-P" ${SCRIPT_CMAKE_ARGS})
set(ARGS ${SCRIPT_ARGS_-P})
list(LENGTH ARGS ARGC)

string(RANDOM _TEST_RAND)
list(GET ARGS 1 TEST)
set(TEST_DIR ${CMAKE_CURRENT_LIST_DIR})
list(GET ARGS 2 TMP_DIR_ROOT)
set(TMP_DIR ${TMP_DIR_ROOT}-${_TEST_RAND})
file(MAKE_DIRECTORY ${TMP_DIR})
set(PREFIX ${TMP_DIR}/usr)
set(BUILDS_DIR ${TMP_DIR}/builds)

macro(rocm_cmake_read_test_argument CMAKE_VAR VAR_TYPE)
    if(DEFINED ROCM_${CMAKE_VAR})
        if(${CMAKE_VAR} STREQUAL "CMAKE_GENERATOR")
            list(APPEND ADDITIONAL_CONFIGURE_ARGS -G "${ROCM_${CMAKE_VAR}}")
        else()
            if(NOT ${ROCM_${CMAKE_VAR}} STREQUAL "")
                list(APPEND ADDITIONAL_CONFIGURE_ARGS -D "${CMAKE_VAR}=${ROCM_${CMAKE_VAR}}")
            endif()
        endif()
    endif()
endmacro()

rocm_cmake_read_test_argument(CMAKE_MAKE_PROGRAM FILEPATH)
rocm_cmake_read_test_argument(CMAKE_GENERATOR STRING)
rocm_cmake_read_test_argument(CMAKE_GENERATOR_INSTANCE STRING)
rocm_cmake_read_test_argument(CMAKE_GENERATOR_PLATFORM STRING)
rocm_cmake_read_test_argument(CMAKE_GENERATOR_TOOLSET STRING)
rocm_cmake_read_test_argument(CMAKE_PREFIX_PATH PATH)
rocm_cmake_read_test_argument(CMAKE_PROGRAM_PATH PATH)

# cmake-lint: disable=C0103
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

macro(test_expect_installed_file FILE)
    if(NOT EXISTS "${PREFIX}/${FILE}")
        message(FATAL_ERROR "EXPECT INSTALLED FILE: ${FILE}")
    endif()
endmacro()

macro(test_expect_no_file FILE)
    if(EXISTS ${FILE})
        message(FATAL_ERROR "EXPECT NO FILE: ${FILE}")
    endif()
endmacro()

macro(test_exec)
    string(REPLACE ";" " " EXEC_COMMAND "${ARGN}")
    string(REPLACE "|" "\;" EXEC_COMMAND "${EXEC_COMMAND}")
    string(REPLACE "|" "\;" REAL_EXEC_COMMAND "${ARGN}")
    execute_process(${REAL_EXEC_COMMAND} RESULT_VARIABLE test_exec_RESULT)
    if(NOT test_exec_RESULT EQUAL 0)
        message(FATAL_ERROR "Process failed: ${EXEC_COMMAND}")
    endif()
endmacro()

macro(use_rocm_cmake)
    list(APPEND CMAKE_MODULE_PATH ${PREFIX}/share/rocm/cmake)
endmacro()

function(configure_dir DIR)
    set(options)
    set(oneValueArgs BUILD_DIR_VAR)
    set(multiValueArgs CMAKE_ARGS TARGETS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(RANDOM BUILD_RAND)
    set(BUILD_DIR ${BUILDS_DIR}/${BUILD_RAND})
    if(NOT EXISTS ${BUILD_DIR})
        file(MAKE_DIRECTORY ${BUILD_DIR})
    endif()
    test_exec(COMMAND ${CMAKE_COMMAND} -Werror=dev ${ADDITIONAL_CONFIGURE_ARGS} -DCMAKE_PREFIX_PATH=${PREFIX}
                      -DCMAKE_INSTALL_PREFIX=${PREFIX} -DROCM_ERROR_TOOLCHAIN_VAR=On ${PARSE_CMAKE_ARGS} ${DIR}
              WORKING_DIRECTORY ${BUILD_DIR})
    foreach(TARGET ${PARSE_TARGETS})
        if("${TARGET}" STREQUAL all)
            test_exec(COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR})
        else()
            test_exec(COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR} --target ${TARGET})
        endif()
    endforeach()

    if(PARSE_BUILD_DIR_VAR)
        set(${PARSE_BUILD_DIR_VAR} ${BUILD_DIR} PARENT_SCOPE)
    else()
        file(REMOVE_RECURSE ${BUILD_DIR})
    endif()
endfunction()

function(install_dir DIR)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs CMAKE_ARGS TARGETS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    configure_dir(
        ${DIR}
        TARGETS all ${PARSE_TARGETS} install
        CMAKE_ARGS ${PARSE_CMAKE_ARGS} -DROCM_SYMLINK_LIBS=OFF)
endfunction()

function(write_version_cmake DIR VERSION CONTENT)
    configure_file(${TEST_DIR}/version/CMakeLists.txt ${DIR}/CMakeLists.txt @ONLY)
    file(COPY ${TEST_DIR}/version/LICENSE DESTINATION ${DIR})
endfunction()

function(test_check_package)
    set(options)
    set(oneValueArgs NAME HEADER TARGET CHECK_TARGET)
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
    set(CHECK_TARGET ${TARGET})
    if(PARSE_CHECK_TARGET)
        set(CHECK_TARGET ${PARSE_CHECK_TARGET})
    endif()

    install_dir(${TEST_DIR}/findpackagecheck CMAKE_ARGS -DPKG=${PARSE_NAME} -DPKG_TARGET=${TARGET}
                                                        -DCHECK_TARGET=${CHECK_TARGET} ${HEADER_FLAG})
endfunction()

install_dir(${TEST_DIR}/../)

include(${TEST})

file(REMOVE_RECURSE ${TMP_DIR})
