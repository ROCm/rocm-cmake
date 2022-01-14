# ######################################################################################################################
# Copyright (C) 2017-2019 Advanced Micro Devices, Inc.
# ######################################################################################################################

set(ROCM_DISABLE_LDCONFIG
    OFF
    CACHE BOOL "")

set(ROCM_DEP_ROCMCORE TRUE CACHE BOOL "Add dependency on rocm-core package, default 'TRUE'")

include(CMakeParseArguments)
include(GNUInstallDirs)
include(ROCMSetupVersion)

find_program(MAKE_NSIS_EXE makensis)
find_program(RPMBUILD_EXE rpmbuild)
find_program(DPKG_EXE dpkg)

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12.0")
    # pretty much just a wrapper around string JOIN
    function(rocm_join_if_set glue inout_variable)
        string(JOIN "${glue}" to_set_parent ${${inout_variable}} ${ARGN})
        set(${inout_variable} "${to_set_parent}" PARENT_SCOPE)
    endfunction()
else()
    # cmake < 3.12 doesn't have string JOIN
    function(rocm_join_if_set glue inout_variable)
        set(accumulator "${${inout_variable}}")
        set(tglue ${glue})
        if(accumulator STREQUAL "")
            set(tglue "")       # No glue needed if initially unset
        endif()
        foreach(ITEM IN LISTS ARGN)
            string(CONCAT accumulator "${accumulator}" "${tglue}" "${ITEM}")
            set(tglue ${glue})  # Always need glue after the first concatenate
        endforeach()
        set(${inout_variable} "${accumulator}" PARENT_SCOPE)
    endfunction()
endif()

macro(rocm_package_add_rocm_core_dependency)
    # Optionally add depenency on rocm-core
    # This mainly empty package exists to allow all of rocm
    # to be removed in one step by removing rocm-core
    if(ROCM_DEP_ROCMCORE)
        rocm_join_if_set(", " CPACK_DEBIAN_PACKAGE_DEPENDS "rocm-core")
        rocm_join_if_set(", " CPACK_RPM_PACKAGE_REQUIRES "rocm-core")
    endif()
endmacro()

macro(rocm_create_package)
    set(options LDCONFIG PTH HEADER_ONLY)
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
        if(${CPACK_SET_DESTDIR})
            set(CPACK_PACKAGING_INSTALL_PREFIX "")
        endif()
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

    if(DEFINED ENV{CPACK_DEBIAN_PACKAGE_RELEASE})
        set(DEBIAN_VERSION $ENV{CPACK_DEBIAN_PACKAGE_RELEASE})
    elseif(PROJECT_VERSION_TWEAK)
        # Sanitize tweak version for debian
        string(REGEX REPLACE "[^A-Za-z0-9.+~]" "~" DEBIAN_VERSION ${PROJECT_VERSION_TWEAK})
    endif()

    if(DEFINED ENV{CPACK_RPM_PACKAGE_RELEASE})
        set(RPM_RELEASE $ENV{CPACK_RPM_PACKAGE_RELEASE})
    elseif(PROJECT_VERSION_TWEAK)
        # Sanitize tweak version for rpm
        string(REPLACE "-" "_" RPM_RELEASE ${PROJECT_VERSION_TWEAK})
    endif()

    if (ROCM_USE_DEV_COMPONENT)
        list(APPEND PARSE_COMPONENTS devel)
        set(CPACK_DEBIAN_DEVEL_PACKAGE_NAME "${CPACK_PACKAGE_NAME}-dev")
        rocm_join_if_set(", " CPACK_DEBIAN_UNSPECIFIED_PACKAGE_RECOMMENDS
            "${CPACK_PACKAGE_NAME}-dev (>=${CPACK_PACKAGE_VERSION})")
        execute_process(
            COMMAND rpmbuild --version
            RESULT_VARIABLE PROC_RESULT
            OUTPUT_VARIABLE EVAL_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(PROC_RESULT EQUAL "0" AND NOT EVAL_RESULT STREQUAL "")
            string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+$" RPMBUILD_VERSION "${EVAL_RESULT}")
            if (RPMBUILD_VERSION VERSION_GREATER_EQUAL "4.12.0")
                rocm_join_if_set(", " CPACK_RPM_UNSPECIFIED_PACKAGE_SUGGESTS
                    "${CPACK_PACKAGE_NAME}-devel >= ${CPACK_PACKAGE_VERSION}")
            endif()
        endif()
        if(PARSE_HEADER_ONLY)
            set(CPACK_DEBIAN_DEVEL_PACKAGE_PROVIDES "${CPACK_PACKAGE_NAME} (= ${CPACK_PACKAGE_VERSION})")
            set(CPACK_RPM_DEVEL_PACKAGE_PROVIDES "${CPACK_PACKAGE_NAME} = ${CPACK_PACKAGE_VERSION}")
        else()
            rocm_join_if_set(", " CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS
                "${CPACK_PACKAGE_NAME} (>=${CPACK_PACKAGE_VERSION})")
            rocm_join_if_set(", " CPACK_RPM_DEVEL_PACKAGE_REQUIRES
                "${CPACK_PACKAGE_NAME} >= ${CPACK_PACKAGE_VERSION}")
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

    rocm_package_add_rocm_core_dependency()

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
        rocm_set_comp_cpackvar(PARSE_HEADER_ONLY "${PARSE_COMPONENTS}")
    endif()
    include(CPack)
endmacro()

macro(rocm_setup_license HEADER_ONLY)
    if(NOT CPACK_RESOURCE_FILE_LICENSE)
        file(GLOB _license_files LIST_DIRECTORIES FALSE "${CMAKE_SOURCE_DIR}/LICENSE*")
        set(_detected_license_files)
        foreach(_license_file IN LISTS _license_files)
            if(_license_file MATCHES "LICENSE(\\.(md|txt))?$")
                list(APPEND _detected_license_files "${_license_file}")
            endif()
        endforeach()
        list(LENGTH _detected_license_files _num_licenses)
        if(_num_licenses GREATER 1)
            message(AUTHOR_WARNING
                "rocm-cmake warning: Multiple license files found, "
                "please specify one using CPACK_RESOURCE_FILE_LICENSE."
            )
        elseif(_num_licenses EQUAL 0)
            message(AUTHOR_WARNING
                "rocm-cmake warning: Could not find a license file, "
                "please specify one using CPACK_RESOURCE_FILE_LICENSE."
            )
        else()
            message(STATUS "rocm-cmake: Set license file to ${CPACK_RESOURCE_FILE_LICENSE}.")
            list(GET _detected_license_files 0 CPACK_RESOURCE_FILE_LICENSE)
        endif()
    endif()

    if(CPACK_RESOURCE_FILE_LICENSE)
        if(NOT ${HEADER_ONLY})
            install(
                FILES ${CPACK_RESOURCE_FILE_LICENSE}
                DESTINATION share/doc/${_rocm_cpack_package_name}
                COMPONENT runtime
            )
        else()
            install(
                FILES ${CPACK_RESOURCE_FILE_LICENSE}
                DESTINATION share/doc/${_rocm_cpack_package_name}
                COMPONENT devel
            )
        endif()
    endif()
endmacro()

macro(rocm_set_comp_cpackvar HEADER_ONLY components)
    # Setting component specific variables
    set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)

    rocm_setup_license(${HEADER_ONLY})

    if(NOT ${HEADER_ONLY})
        set(CPACK_RPM_MAIN_COMPONENT "Unspecified")
        set(CPACK_RPM_UNSPECIFIED_DISPLAY_NAME "${CPACK_PACKAGE_NAME}")
        list(APPEND CPACK_COMPONENTS_ALL Unspecified)
        set(CPACK_DEBIAN_UNSPECIFIED_FILE_NAME
           "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}-${DEBIAN_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb")
        set(CPACK_DEBIAN_UNSPECIFIED_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
    endif()

    foreach(COMPONENT ${components})
        list(APPEND CPACK_COMPONENTS_ALL "${COMPONENT}")
        set(CPACK_RPM_${COMPONENT}_FILE_NAME "RPM-DEFAULT")
        set(CPACK_DEBIAN_${COMPONENT}_FILE_NAME "DEB-DEFAULT")
    endforeach()
endmacro()
