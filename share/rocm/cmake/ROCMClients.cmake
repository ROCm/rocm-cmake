# ########################################################################
# Copyright 2016-2021 Advanced Micro Devices, Inc.
# ########################################################################

include(ROCMCreatePackage)

function(rocm_set_rpm_dependencies COMPONENT_NAME)
    set(RPM_DEPENDS "${CPACK_RPM_${COMPONENT_NAME}_PACKAGE_REQUIRES}")
    string(REPLACE ";" ", " NEW_DEPENDS "${ARGN}")
    rocm_join_if_set(", " RPM_DEPENDS "${NEW_DEPENDS}")
    set(CPACK_RPM_${COMPONENT_NAME}_PACKAGE_REQUIRES "${RPM_DEPENDS}" PARENT_SCOPE)
endfunction()

function(rocm_set_deb_dependencies COMPONENT_NAME)
    set(DEB_DEPENDS "${CPACK_DEBIAN_${COMPONENT_NAME}_PACKAGE_DEPENDS}")
    foreach(DEP IN LISTS ARGN)
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
    set(CPACK_DEBIAN_${COMPONENT_NAME}_PACKAGE_DEPENDS "${DEB_DEPENDS}" PARENT_SCOPE)
endfunction()

macro(rocm_set_dependencies)
    rocm_set_deb_dependencies(${ARGN})
    rocm_set_rpm_dependencies(${ARGN})
endmacro()

macro(rocm_setup_client_component COMPONENT_NAME)
    set(options)
    set(oneValueArgs PACKAGE_NAME)
    set(multipleValueArgs DEPENDS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    list(APPEND ROCM_BUILD_CLIENTS ${COMPONENT_NAME})

    if(NOT DEFINED PARSE_PACKAGE_NAME)
        string(TOLOWER "${COMPONENT_NAME}" PARSE_PACKAGE_NAME)
    endif()
    string(TOUPPER "${COMPONENT_NAME}" COMPONENT_UC)

    if(BUILD_SHARED_LIBS)
        set(PARSE_PACKAGE_NAME "${PARSE_PACKAGE_NAME}-static")
    else()
        rocm_join_if_set(";" PARSE_DEPENDS "${PROJECT_NAME} >= ${${PROJECT_NAME}_VERSION}")
    endif()

    if(DEFINED PARSE_DEPENDS)
        cmake_parse_arguments(DEPENDS "" "" "COMMON;DEBIAN;RPM" ${PARSE_DEPENDS})
        rocm_set_deb_dependencies(${COMPONENT_UC} ${DEPENDS_COMMON} ${DEPENDS_DEBIAN})
        rocm_set_rpm_dependencies(${COMPONENT_UC} ${DEPENDS_COMMON} ${DEPENDS_RPM})
    endif()
endmacro()

function(rocm_find_relative_path SRC DEST OUT_VAR)
    if(SRC STREQUAL ".")
        set(${OUT_VAR} "${DEST}" PARENT_SCOPE)
    else()
        set(REL_PATH "..")
        if(WIN32)
            string(REGEX MATCHALL "[\\/]" SEPARATORS "${SRC}")
        else()
            string(REGEX MATCHALL "/" SEPARATORS "${SRC}")
        endif()
        list(LENGTH SEPARATORS N_SEPARATORS)
        if(${N_SEPARATORS} GREATER 0)
            foreach(i RANGE 1 ${N_SEPARATORS})
                string(APPEND REL_PATH "/..")
            endforeach()
        endif()
        set(${OUT_VAR} "${REL_PATH}/${DEST}" PARENT_SCOPE)
    endif()
endfunction()

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