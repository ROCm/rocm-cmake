# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(HOOK [[include("${CMAKE_CURRENT_LIST_DIR}/../BASE-fortran/BASE-fortran-config.cmake" OPTIONAL)]])

# Writes a Fortran config package for BASE, like a binding installed after the C
# library: it finds the C package itself when it is the one requested.
function(write_fortran_package BASE CMAKE_DIR)
    file(
        WRITE ${CMAKE_DIR}/${BASE}-fortran/${BASE}-fortran-config.cmake
        "if(NOT TARGET ${BASE})
    include(CMakeFindDependencyMacro)
    find_dependency(${BASE})
endif()
if(NOT TARGET ${BASE}_fortran)
    add_library(${BASE}_fortran INTERFACE IMPORTED)
    set_target_properties(${BASE}_fortran PROPERTIES INTERFACE_LINK_LIBRARIES ${BASE})
endif()
set(${BASE}_FORTRAN_DIR \"\${CMAKE_CURRENT_LIST_DIR}\")
set(${BASE}_FORTRAN_FOUND TRUE)
")
endfunction()

function(read_config BASE)
    file(GLOB_RECURSE CONFIG ${PREFIX}/*/cmake/${BASE}/${BASE}-config.cmake)
    get_filename_component(CONFIG_DIR ${CONFIG} DIRECTORY)
    get_filename_component(CMAKE_DIR ${CONFIG_DIR} DIRECTORY)
    file(READ ${CONFIG} CONTENT)
    string(REPLACE BASE ${BASE} LINE "${HOOK}")
    string(FIND "${CONTENT}" "${LINE}" HOOK_POS)
    set(CMAKE_DIR ${CMAKE_DIR} PARENT_SCOPE)
    set(HOOK_POS ${HOOK_POS} PARENT_SCOPE)
endfunction()

install_dir(${TEST_DIR}/libsimple)
read_config(simple)
if(HOOK_POS EQUAL -1)
    message(FATAL_ERROR "simple-config.cmake does not include simple-fortran-config.cmake.")
endif()
file(RELATIVE_PATH CMAKE_DIR_REL ${PREFIX} ${CMAKE_DIR})

# No Fortran package installed: the include is a no-op.
configure_dir(${TEST_DIR}/fortranconfigcheck CMAKE_ARGS -DPKG=simple -DBASE=simple -DEXPECT_FORTRAN=OFF)

write_fortran_package(simple ${CMAKE_DIR})
foreach(PKG simple simple-fortran)
    configure_dir(
        ${TEST_DIR}/fortranconfigcheck
        CMAKE_ARGS -DPKG=${PKG} -DBASE=simple -DEXPECT_FORTRAN=ON -DEXPECT_FORTRAN_FOUND=TRUE
                   -DEXPECT_FORTRAN_DIR=${CMAKE_DIR}/simple-fortran)
endforeach()

# The include follows the install tree when it moves.
set(MOVED ${TMP_DIR}/moved)
file(COPY ${PREFIX}/ DESTINATION ${MOVED})
configure_dir(
    ${TEST_DIR}/fortranconfigcheck
    CMAKE_ARGS -DPKG=simple -DBASE=simple -Dsimple_DIR=${MOVED}/${CMAKE_DIR_REL}/simple -DEXPECT_FORTRAN=ON
               -DEXPECT_FORTRAN_FOUND=TRUE -DEXPECT_FORTRAN_DIR=${MOVED}/${CMAKE_DIR_REL}/simple-fortran)

# A package that passes its own <package>-fortran-config.cmake via INCLUDE, as
# rocRAND and hipRAND do, keeps loading only that one, until it stops passing it.
set(LEGACY_DIR ${TMP_DIR}/legacy)
file(WRITE ${LEGACY_DIR}/legacy-fortran-config.cmake "set(legacy_FORTRAN_FOUND YES)\n")
file(
    WRITE ${LEGACY_DIR}/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5...3.31.0)
project(legacy NONE)
find_package(ROCmCMakeBuildTools)
include(ROCMInstallTargets)
include(ROCMSetupVersion)
rocm_setup_version(VERSION 1.0.0)
add_library(legacy INTERFACE)
rocm_install_targets(TARGETS legacy)
if(LEGACY_INCLUDE)
    rocm_export_targets(TARGETS legacy INCLUDE \${CMAKE_CURRENT_SOURCE_DIR}/legacy-fortran-config.cmake)
else()
    rocm_export_targets(TARGETS legacy)
endif()
")

install_dir(${LEGACY_DIR} CMAKE_ARGS -DLEGACY_INCLUDE=ON)
read_config(legacy)
if(NOT HOOK_POS EQUAL -1)
    message(FATAL_ERROR "legacy-config.cmake includes both legacy-fortran-config.cmake files.")
endif()
write_fortran_package(legacy ${CMAKE_DIR})
configure_dir(${TEST_DIR}/fortranconfigcheck CMAKE_ARGS -DPKG=legacy -DBASE=legacy -DEXPECT_FORTRAN=OFF
                                                        -DEXPECT_FORTRAN_FOUND=YES)

file(REMOVE_RECURSE ${CMAKE_DIR}/legacy)
install_dir(${LEGACY_DIR} CMAKE_ARGS -DLEGACY_INCLUDE=OFF)
configure_dir(
    ${TEST_DIR}/fortranconfigcheck
    CMAKE_ARGS -DPKG=legacy -DBASE=legacy -DEXPECT_FORTRAN=ON -DEXPECT_FORTRAN_FOUND=TRUE
               -DEXPECT_FORTRAN_DIR=${CMAKE_DIR}/legacy-fortran)
