################################################################################
# Copyright (C) 2017-2019 Advanced Micro Devices, Inc.
################################################################################


include(CMakeParseArguments)
include(GNUInstallDirs)

find_program(MAKE_NSIS_EXE makensis)
find_program(RPMBUILD_EXE rpmbuild)
find_program(DPKG_EXE dpkg)

macro(rocm_create_package)
    set(options LDCONFIG PTH)
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

    rocm_set_os_id(_os_id)
    rocm_read_os_release(_version_id "VERSION_ID")

    #only set CPACK_SYSTEM_NAME for AMD supported OSes
    if (_os_id_centos OR _os_id_rhel)
        STRING(CONCAT _SYSTEM_NAME "el" ${_version_id} ".x86_64")
    #Debs use underscrore between OS and architecture
    elseif(_os_id_ubuntu)
        STRING(CONCAT _SYSTEM_NAME ${_os_id} "-" ${_version_id} "_amd64")
    elseif(_os_id_sles)
        STRING(CONCAT _SYSTEM_NAME ${_os_id} "-" ${_version_id} ".amd64")
    else()
        set(_SYSTEM_NAME ${CPACK_SYSTEM_NAME})
    endif()

    set(CPACK_SYSTEM_NAME ${_SYSTEM_NAME} CACHE STRING "CPACK_SYSTEM_NAME for packaging")
    
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

    set(LIB_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    if(PARSE_PREFIX)
        set(LIB_DIR ${CMAKE_INSTALL_PREFIX}/${PARSE_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    endif()

    file(WRITE ${PROJECT_BINARY_DIR}/debian/postinst "")
    file(WRITE ${PROJECT_BINARY_DIR}/debian/prerm "")
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${PROJECT_BINARY_DIR}/debian/postinst;${PROJECT_BINARY_DIR}/debian/prerm")
    set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/debian/postinst")
    set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${PROJECT_BINARY_DIR}/debian/prerm")

    if(PARSE_LDCONFIG)
        set(LDCONFIG_DIR ${LIB_DIR})
        if(PARSE_LDCONFIG_DIR)
            set(LDCONFIG_DIR ${PARSE_LDCONFIG_DIR})
        endif()
        file(APPEND ${PROJECT_BINARY_DIR}/debian/postinst "
            echo \"${LDCONFIG_DIR}\" > /etc/ld.so.conf.d/${PARSE_NAME}.conf
            ldconfig
        ")

        file(APPEND ${PROJECT_BINARY_DIR}/debian/prerm "
            rm /etc/ld.so.conf.d/${PARSE_NAME}.conf
            ldconfig
        ")
    endif()

    if(PARSE_PTH)
        set(PYTHON_SITE_PACKAGES "/usr/lib/python3/dist-packages;/usr/lib/python2.7/dist-packages" CACHE STRING "The site packages used for packaging")
        foreach(PYTHON_SITE ${PYTHON_SITE_PACKAGES})
            file(APPEND ${PROJECT_BINARY_DIR}/debian/postinst "
                mkdir -p ${PYTHON_SITE}
                echo \"${LIB_DIR}\" > ${PYTHON_SITE}/${PARSE_NAME}.pth
            ")

            file(APPEND ${PROJECT_BINARY_DIR}/debian/prerm "
                rm ${PYTHON_SITE}/${PARSE_NAME}.pth
            ")
        endforeach()
    endif()
    include(CPack)
endmacro()

function (rocm_set_os_id OS_ID)
    set(_os_id "unknown")
    if (EXISTS "/etc/os-release")
        rocm_read_os_release(_os_id "ID")
    endif()
    set(${OS_ID} ${_os_id} PARENT_SCOPE)
    set(${OS_ID}_${_os_id} TRUE PARENT_SCOPE)
endfunction()

function (rocm_read_os_release OUTPUT KEYVALUE)
    #finds the line with the keyvalue
    if (EXISTS "/etc/os-release")
        file (STRINGS /etc/os-release _keyvalue_line REGEX "^${KEYVALUE}=")
    endif()

    #remove keyvalue=
    string (REGEX REPLACE "^${KEYVALUE}=\"?(.*)" "\\1" _output "${_keyvalue_line}")

    #remove trailing quote
    string (REGEX REPLACE "\"$" "" _output "${_output}")
    set(${OUTPUT} ${_output} PARENT_SCOPE)
endfunction()
