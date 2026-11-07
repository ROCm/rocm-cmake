# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/libsimple)

file(GLOB_RECURSE SIMPLE_CONFIG ${PREFIX}/*/cmake/simple/simple-config.cmake)
get_filename_component(SIMPLE_CONFIG_DIR ${SIMPLE_CONFIG} DIRECTORY)
get_filename_component(CMAKE_DIR ${SIMPLE_CONFIG_DIR} DIRECTORY)
file(RELATIVE_PATH CMAKE_DIR_REL ${PREFIX} ${CMAKE_DIR})

file(READ ${SIMPLE_CONFIG} SIMPLE_CONFIG_CONTENT)
string(FIND "${SIMPLE_CONFIG_CONTENT}"
            [[include("${CMAKE_CURRENT_LIST_DIR}/../simple-fortran/simple-fortran-config.cmake" OPTIONAL)]] HOOK_POS)
if(HOOK_POS EQUAL -1)
    message(FATAL_ERROR "simple-config.cmake does not include simple-fortran-config.cmake:\n${SIMPLE_CONFIG_CONTENT}")
endif()

# No Fortran package installed: the include is a no-op.
configure_dir(${TEST_DIR}/fortranconfigcheck CMAKE_ARGS -DPKG=simple -DEXPECT_FORTRAN=OFF)

# A Fortran package installed after the C one, like a binding: it finds the C
# package itself when it is the one requested.
file(
    WRITE ${CMAKE_DIR}/simple-fortran/simple-fortran-config.cmake
    "if(NOT TARGET simple)
    include(CMakeFindDependencyMacro)
    find_dependency(simple)
endif()
if(NOT TARGET simple_fortran)
    add_library(simple_fortran INTERFACE IMPORTED)
    set_target_properties(simple_fortran PROPERTIES INTERFACE_LINK_LIBRARIES simple)
endif()
set(simple_FORTRAN_DIR \"\${CMAKE_CURRENT_LIST_DIR}\")
set(simple_FORTRAN_FOUND TRUE)
")

foreach(PKG simple simple-fortran)
    configure_dir(${TEST_DIR}/fortranconfigcheck CMAKE_ARGS -DPKG=${PKG} -DEXPECT_FORTRAN=ON
                                                            -DEXPECT_FORTRAN_DIR=${CMAKE_DIR}/simple-fortran)
endforeach()

# The include follows the install tree when it moves.
set(MOVED ${TMP_DIR}/moved)
file(COPY ${PREFIX}/ DESTINATION ${MOVED})
configure_dir(
    ${TEST_DIR}/fortranconfigcheck
    CMAKE_ARGS -DPKG=simple -Dsimple_DIR=${MOVED}/${CMAKE_DIR_REL}/simple -DEXPECT_FORTRAN=ON
               -DEXPECT_FORTRAN_DIR=${MOVED}/${CMAKE_DIR_REL}/simple-fortran)
