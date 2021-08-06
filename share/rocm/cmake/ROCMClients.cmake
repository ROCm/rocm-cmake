# ########################################################################
# Copyright 2016-2021 Advanced Micro Devices, Inc.
# ########################################################################

include(ROCMUtilities)

function(rocm_set_rpm_dependencies)
    cmake_parse_arguments(PARSE "" "COMPONENT" "" ${ARGN})
    if(DEFINED PARSE_COMPONENT)
        string(TOUPPER "${PARSE_COMPONENT}" COMPONENT_VAR)
        set(REQ_VAR "CPACK_RPM_${COMPONENT_VAR}_PACKAGE_REQUIRES")
    else()
        set(REQ_VAR "CPACK_RPM_PACKAGE_REQUIRES")
    endif()
    set(RPM_DEPENDS "${${REQ_VAR}}")
    string(REPLACE ";" ", " NEW_DEPENDS "${PARSE_UNPARSED_ARGUMENTS}")
    rocm_join_if_set(", " RPM_DEPENDS "${NEW_DEPENDS}")
    set(${REQ_VAR} "${RPM_DEPENDS}" PARENT_SCOPE)
endfunction()

function(rocm_set_deb_dependencies)
    cmake_parse_arguments(PARSE "" "COMPONENT" "" ${ARGN})
    if(DEFINED PARSE_COMPONENT)
        string(TOUPPER "${PARSE_COMPONENT}" COMPONENT_VAR)
        set(REQ_VAR "CPACK_DEBIAN_${COMPONENT_VAR}_PACKAGE_DEPENDS")
    else()
        set(REQ_VAR "CPACK_DEBIAN_PACKAGE_DEPENDS")
    endif()
    set(DEB_DEPENDS "${${REQ_VAR}}")
    foreach(DEP IN LISTS PARSE_UNPARSED_ARGUMENTS)
        string(FIND "${DEP}" " " VERSION_POSITION)
        if(VERSION_POSITION GREATER "-1")
            string(SUBSTRING "${DEP}" 0 ${VERSION_POSITION} DEP_NAME)
            math(EXPR VERSION_POSITION "${VERSION_POSITION}+1")
            string(SUBSTRING "${DEP}" ${VERSION_POSITION} -1 DEP_VERSION)
            rocm_join_if_set(", " DEB_DEPENDS "${DEP_NAME} (${DEP_VERSION})")
        else()
            rocm_join_if_set(", " DEB_DEPENDS "${DEP}")
        endif()
    endforeach()
    set(${REQ_VAR} "${DEB_DEPENDS}" PARENT_SCOPE)
endfunction()

macro(rocm_set_dependencies)
    rocm_set_deb_dependencies(${ARGN})
    rocm_set_rpm_dependencies(${ARGN})
endmacro()

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

    set(CPACK_DEBIAN_${COMPONENT_NAME}_PACKAGE_NAME "${PROJECT_NAME}-${PARSE_PACKAGE_NAME}")

    if(DEFINED PARSE_DEPENDS)
        cmake_parse_arguments(DEPENDS "" "" "COMMON;DEBIAN;RPM" ${PARSE_DEPENDS})
        if(BUILD_SHARED_LIBS)
            rocm_join_if_set(";" DEPENDS_COMMON "${PROJECT_NAME} >= ${${PROJECT_NAME}_VERSION}")
        endif()
        rocm_set_deb_dependencies(COMPONENT ${COMPONENT_NAME} ${DEPENDS_COMMON} ${DEPENDS_DEBIAN})
        rocm_set_rpm_dependencies(COMPONENT ${COMPONENT_NAME} ${DEPENDS_COMMON} ${DEPENDS_RPM})
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
        add_custom_command(
            TARGET ${TARGET} POST_BUILD
            COMMAND mklink "${_DEST}" "${REL_PATH}/${TARGET}.exe"
            BYPRODUCTS "${_DEST}"
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