################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


include(CMakeParseArguments)
include(GNUInstallDirs)

find_program(MAKE_NSIS_EXE makensis)
find_program(RPMBUILD_EXE rpmbuild)
find_program(DPKG_EXE dpkg)

macro(rocm_create_package)
    set(options LDCONFIG)
    set(oneValueArgs NAME DESCRIPTION SECTION MAINTAINER LDCONFIG_DIR PREFIX)
    set(multiValueArgs DEPENDS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(CPACK_PACKAGE_NAME ${PARSE_NAME})
    set(CPACK_PACKAGE_VENDOR "Advanced Micro Devices, Inc")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PARSE_DESCRIPTION})
    set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
    set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
    if(NOT CMAKE_HOST_WIN32)
        set( CPACK_SET_DESTDIR ON CACHE BOOL "Boolean toggle to make CPack use DESTDIR mechanism when packaging" )
    endif()

    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${PARSE_MAINTAINER})
    set(CPACK_DEBIAN_PACKAGE_SECTION "devel")

    set(CPACK_NSIS_MODIFY_PATH On)
    set(CPACK_NSIS_PACKAGE_NAME ${PARSE_NAME})

    set(CPACK_RPM_PACKAGE_RELOCATABLE Off)
    set( CPACK_RPM_PACKAGE_AUTOREQPROV Off CACHE BOOL "turns off rpm autoreqprov field; packages explicity list dependencies" )

    set(CPACK_GENERATOR "TGZ;ZIP")
    if(EXISTS ${MAKE_NSIS_EXE})
        list(APPEND CPACK_GENERATOR "NSIS")
    endif()

    if(EXISTS ${RPMBUILD_EXE})
        list(APPEND CPACK_GENERATOR "RPM")
    endif()

    if(EXISTS ${DPKG_EXE})
        list(APPEND CPACK_GENERATOR "DEB")
    endif()

    if(PARSE_DEPENDS)
        string(REPLACE ";" ", " DEPENDS "${PARSE_DEPENDS}")
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "${DEPENDS}")
        set(CPACK_RPM_PACKAGE_REQUIRES "${DEPENDS}")
    endif()

    if(PARSE_LDCONFIG)
        set(LDCONFIG_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
        if(PARSE_LDCONFIG_DIR)
            set(LDCONFIG_DIR ${PARSE_LDCONFIG_DIR})
        elseif(PARSE_PREFIX)
            set(LDCONFIG_DIR ${CMAKE_INSTALL_PREFIX}/${PARSE_PREFIX}/${CMAKE_INSTALL_LIBDIR})
        endif()
        file(WRITE ${PROJECT_BINARY_DIR}/debian/postinst "
            echo \"${LDCONFIG_DIR}\" > /etc/ld.so.conf.d/${PARSE_NAME}.conf
            ldconfig
        ")

        file(WRITE ${PROJECT_BINARY_DIR}/debian/prerm "
            rm /etc/ld.so.conf.d/${PARSE_NAME}.conf
            ldconfig
        ")

        set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${PROJECT_BINARY_DIR}/debian/postinst;${PROJECT_BINARY_DIR}/debian/prerm")
        set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/debian/postinst")
        set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/debian/prerm")
    endif()
    include(CPack)
endmacro()
