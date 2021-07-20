# ######################################################################################################################
# Copyright (C) 2017-2019 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(ROCM_DISABLE_LDCONFIG
    OFF
    CACHE BOOL "")

include(CMakeParseArguments)
include(GNUInstallDirs)
include(ROCMSetupVersion)

find_program(MAKE_NSIS_EXE makensis)
find_program(RPMBUILD_EXE rpmbuild)
find_program(DPKG_EXE dpkg)

macro(rocm_create_package)
    set(options LDCONFIG PTH)
    set(oneValueArgs NAME DESCRIPTION SECTION MAINTAINER LDCONFIG_DIR PREFIX)
    set(multiValueArgs DEPENDS COMPONENTS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(TOLOWER ${PARSE_NAME} _rocm_cpack_package_name)
    set(CPACK_PACKAGE_NAME ${_rocm_cpack_package_name})
    set(CPACK_PACKAGE_VENDOR "Advanced Micro Devices, Inc")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PARSE_DESCRIPTION})
    set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
    set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
    if(NOT CMAKE_HOST_WIN32)
        set(CPACK_SET_DESTDIR
            ON
            CACHE BOOL "Boolean toggle to make CPack use DESTDIR mechanism when packaging")
    endif()

    rocm_get_patch_version(ROCM_VERSION_NUM)
    if(ROCM_VERSION_NUM)
        set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}.${ROCM_VERSION_NUM}")
    endif()

    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${PARSE_MAINTAINER})
    set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
    set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")

    set(CPACK_NSIS_MODIFY_PATH On)
    set(CPACK_NSIS_PACKAGE_NAME ${PARSE_NAME})

    set(CPACK_RPM_PACKAGE_RELOCATABLE Off)
    set(CPACK_RPM_PACKAGE_AUTOREQPROV
        Off
        CACHE BOOL "turns off rpm autoreqprov field; packages explicity list dependencies")
    set(CPACK_RPM_FILE_NAME "RPM-DEFAULT")

    set(DEBIAN_VERSION ${PROJECT_VERSION_TWEAK})
    # Sanitize tweak version for debian
    if(DEBIAN_VERSION)
        string(REGEX REPLACE "[^A-Za-z0-9.+~]" "~" DEBIAN_VERSION ${DEBIAN_VERSION})
    endif()
    if(DEFINED ENV{CPACK_DEBIAN_PACKAGE_RELEASE})
        set(DEBIAN_VERSION $ENV{CPACK_DEBIAN_PACKAGE_RELEASE})
    endif()

    set(RPM_RELEASE ${PROJECT_VERSION_TWEAK})
    # Sanitize tweak version for rpm
    if(RPM_RELEASE)
        string(REPLACE "-" "_" RPM_RELEASE ${RPM_RELEASE})
    endif()
    if(DEFINED ENV{CPACK_RPM_PACKAGE_RELEASE})
        set(RPM_RELEASE $ENV{CPACK_RPM_PACKAGE_RELEASE})
    endif()

    if (DEFINED CACHE{ROCM_DEVEL_COMPONENT})
        list(APPEND PARSE_COMPONENTS "$CACHE{ROCM_DEVEL_COMPONENT}")
        if(CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS)
            string(JOIN ", " CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS "${CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS}" "${CPACK_PACKAGE_NAME} (>=${CPACK_PACKAGE_VERSION})")
        else()
            set(CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS "${CPACK_PACKAGE_NAME} (>=${CPACK_PACKAGE_VERSION})")
        endif()
        if(CPACK_RPM_DEVEL_PACKAGE_REQUIRES)
            string(JOIN ", " CPACK_RPM_DEVEL_PACKAGE_REQUIRES "${CPACK_RPM_DEVEL_PACKAGE_REQUIRES}" "${CPACK_PACKAGE_NAME} >=${CPACK_PACKAGE_VERSION}")
        else()
            set(CPACK_RPM_DEVEL_PACKAGE_REQUIRES "${CPACK_PACKAGE_NAME} >= ${CPACK_PACKAGE_VERSION}")
        endif()
    endif()

    # '%{?dist}' breaks manual builds on debian systems due to empty Provides
    execute_process(
        COMMAND rpm --eval %{?dist}
        RESULT_VARIABLE PROC_RESULT
        OUTPUT_VARIABLE EVAL_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(PROC_RESULT EQUAL "0" AND NOT EVAL_RESULT STREQUAL "")
        string(APPEND RPM_RELEASE "%{?dist}")
    endif()
    set(CPACK_DEBIAN_PACKAGE_RELEASE ${DEBIAN_VERSION})
    set(CPACK_RPM_PACKAGE_RELEASE ${RPM_RELEASE})

    set(CPACK_GENERATOR "TGZ;ZIP")
    if(EXISTS ${MAKE_NSIS_EXE})
        list(APPEND CPACK_GENERATOR "NSIS")
    endif()

    if(EXISTS ${RPMBUILD_EXE})
        list(APPEND CPACK_GENERATOR "RPM")
        if(PARSE_COMPONENTS)
            set(CPACK_RPM_COMPONENT_INSTALL ON)
        endif()
    endif()

    if(EXISTS ${DPKG_EXE})
        list(APPEND CPACK_GENERATOR "DEB")
        if(PARSE_COMPONENTS)
            set(CPACK_DEB_COMPONENT_INSTALL ON)
            execute_process(
                COMMAND dpkg --print-architecture
                RESULT_VARIABLE PROC_RESULT
                OUTPUT_VARIABLE COMMAND_OUTPUT
                OUTPUT_STRIP_TRAILING_WHITESPACE)
            if(PROC_RESULT EQUAL "0" AND NOT COMMAND_OUTPUT STREQUAL "")
                set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${COMMAND_OUTPUT}")
            endif()
        endif()
    endif()

    if(PARSE_DEPENDS)
        string(REPLACE ";" ", " DEPENDS "${PARSE_DEPENDS}")
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "${DEPENDS}")
        set(CPACK_RPM_PACKAGE_REQUIRES "${DEPENDS}")
    endif()

    set(LIB_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    if(PARSE_PREFIX)
        set(LIB_DIR ${CMAKE_INSTALL_PREFIX}/${PARSE_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    endif()

    file(WRITE ${PROJECT_BINARY_DIR}/debian/postinst "")
    file(WRITE ${PROJECT_BINARY_DIR}/debian/prerm "")
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${PROJECT_BINARY_DIR}/debian/postinst;${PROJECT_BINARY_DIR}/debian/prerm")
    set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/debian/postinst")
    set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/debian/prerm")

    if(PARSE_LDCONFIG AND NOT ${ROCM_DISABLE_LDCONFIG})
        set(LDCONFIG_DIR ${LIB_DIR})
        if(PARSE_LDCONFIG_DIR)
            set(LDCONFIG_DIR ${PARSE_LDCONFIG_DIR})
        endif()
        file(
            APPEND ${PROJECT_BINARY_DIR}/debian/postinst
            "
            echo \"${LDCONFIG_DIR}\" > /etc/ld.so.conf.d/${PARSE_NAME}.conf
            ldconfig
        ")

        file(
            APPEND ${PROJECT_BINARY_DIR}/debian/prerm
            "
            rm /etc/ld.so.conf.d/${PARSE_NAME}.conf
            ldconfig
        ")
    endif()

    if(PARSE_PTH)
        set(PYTHON_SITE_PACKAGES
            "/usr/lib/python3/dist-packages;/usr/lib/python2.7/dist-packages"
            CACHE STRING "The site packages used for packaging")
        foreach(PYTHON_SITE ${PYTHON_SITE_PACKAGES})
            file(
                APPEND ${PROJECT_BINARY_DIR}/debian/postinst
                "
                mkdir -p ${PYTHON_SITE}
                echo \"${LIB_DIR}\" > ${PYTHON_SITE}/${PARSE_NAME}.pth
            ")

            file(
                APPEND ${PROJECT_BINARY_DIR}/debian/prerm
                "
                rm ${PYTHON_SITE}/${PARSE_NAME}.pth
            ")
        endforeach()
    endif()
    if(PARSE_COMPONENTS)
        rocm_set_comp_cpackvar("${PARSE_COMPONENTS}")
    endif()
    include(CPack)
endmacro()

function(rocm_set_os_id OS_ID)
    set(_os_id "unknown")
    if(EXISTS "/etc/os-release")
        rocm_read_os_release(_os_id "ID")
    endif()
    set(${OS_ID}
        ${_os_id}
        PARENT_SCOPE)
    set(os_id_out ${OS_ID}_${_os_id})
    set(${os_id_out}
        TRUE
        PARENT_SCOPE)
endfunction()

function(rocm_read_os_release OUTPUT KEYVALUE)
    # finds the line with the keyvalue
    if(EXISTS "/etc/os-release")
        file(STRINGS /etc/os-release _keyvalue_line REGEX "^${KEYVALUE}=")
    endif()

    # remove keyvalue=
    string(REGEX REPLACE "^${KEYVALUE}=\"?(.*)" "\\1" _output "${_keyvalue_line}")

    # remove trailing quote
    string(REGEX REPLACE "\"$" "" _output "${_output}")
    set(${OUTPUT}
        ${_output}
        PARENT_SCOPE)
endfunction()

macro(rocm_set_comp_cpackvar components)
    # Setting component specific variables
    set(CPACK_RPM_MAIN_COMPONENT "Unspecified")
    set(CPACK_RPM_UNSPECIFIED_DISPLAY_NAME "${CPACK_PACKAGE_NAME}")
    set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
    list(APPEND CPACK_COMPONENTS_ALL Unspecified)
    set(CPACK_DEBIAN_UNSPECIFIED_FILE_NAME
       "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}-${DEBIAN_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb")
    set(CPACK_DEBIAN_UNSPECIFIED_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")

    foreach(COMPONENT ${components})
        list(APPEND CPACK_COMPONENTS_ALL "${COMPONENT}")
        set(CPACK_RPM_${COMPONENT}_FILE_NAME "RPM-DEFAULT")
        set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "DEB-DEFAULT")
    endforeach()
endmacro()
