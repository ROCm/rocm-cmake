# ########################################################################
# Copyright 2016-2021 Advanced Micro Devices, Inc.
# ########################################################################

include(ROCMUtilities)

macro(rocm_setup_client_component COMPONENT_NAME)
    set(options)
    set(oneValueArgs PACKAGE_NAME LIBRARY_NAME)
    set(multipleValueArgs DEPENDS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    list(APPEND ROCM_BUILD_CLIENTS ${COMPONENT_NAME})

    if(NOT DEFINED PARSE_PACKAGE_NAME)
        string(TOLOWER "${COMPONENT_NAME}" PARSE_PACKAGE_NAME)
    endif()

    if(NOT BUILD_SHARED_LIBS)
        set(PARSE_PACKAGE_NAME "${PARSE_PACKAGE_NAME}-static")
    endif()

    if(NOT DEFINED PARSE_LIBRARY_NAME)
        set(PARSE_LIBRARY_NAME "${PROJECT_NAME}")
    endif()

    set(CPACK_DEBIAN_${COMPONENT_NAME}_PACKAGE_NAME "${PROJECT_NAME}-${PARSE_PACKAGE_NAME}")

    if(DEFINED PARSE_DEPENDS OR BUILD_SHARED_LIBS)
        cmake_parse_arguments(DEPENDS "" "" "COMMON;DEBIAN;RPM" ${PARSE_DEPENDS})
        if(BUILD_SHARED_LIBS)
            rocm_join_if_set(";" DEPENDS_COMMON "${PROJECT_NAME} >= ${${PROJECT_NAME}_VERSION}")
        endif()
        rocm_add_deb_dependencies(COMPONENT ${COMPONENT_NAME} ${DEPENDS_COMMON} ${DEPENDS_DEBIAN})
        rocm_add_rpm_dependencies(COMPONENT ${COMPONENT_NAME} ${DEPENDS_COMMON} ${DEPENDS_RPM})
    endif()
endmacro()

macro(rocm_install_client_with_symlink TARGET COMPONENT)
    set(options)
    set(oneValueArgs EXE_DESTINATION SYMLINK_DESTINATION)
    set(multipleValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    if(NOT DEFINED PARSE_EXE_DESTINATION)
        set(PARSE_EXE_DESTINATION "${CMAKE_PROJECT_NAME}/bin")
    endif()

    if(NOT DEFINED PARSE_SYMLINK_DESTINATION)
        set(PARSE_SYMLINK_DESTINATION "bin")
    endif()

    install(
        TARGETS ${TARGET}
        DESTINATION "${PARSE_EXE_DESTINATION}"
        COMPONENT ${COMPONENT}
    )
    rocm_find_relative_path("${PARSE_SYMLINK_DESTINATION}" "${PARSE_EXE_DESTINATION}" REL_PATH)
    set(_DEST "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.symlink")
    if(WIN32)
        string(REPLACE "/" "\\" ESCAPED_DEST "${_DEST}")
        string(REPLACE "/" "\\" REL_PATH "${REL_PATH}")
        add_custom_command(
            TARGET ${TARGET} POST_BUILD
            COMMAND mklink "${ESCAPED_DEST}" "${REL_PATH}\\${TARGET}.exe"
            BYPRODUCTS "${ESCAPED_DEST}"
            VERBATIM
        )
        install(
            FILES "${_DEST}"
            DESTINATION "${PARSE_SYMLINK_DESTINATION}"
            RENAME "${TARGET}.exe"
            COMPONENT ${COMPONENT}
        )
    else()
        add_custom_command(
            TARGET ${TARGET} POST_BUILD
            COMMAND ln -sf "${REL_PATH}/${TARGET}" "${_DEST}"
            BYPRODUCTS "${_DEST}"
        )
        install(
            FILES "${_DEST}"
            DESTINATION "${PARSE_SYMLINK_DESTINATION}"
            RENAME "${TARGET}"
            COMPONENT ${COMPONENT}
        )
    endif()
endmacro()