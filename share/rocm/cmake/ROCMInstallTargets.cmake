# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

cmake_policy(SET CMP0057 NEW)

include(CMakeParseArguments)
include(GNUInstallDirs)
include(ROCMPackageConfigHelpers)
include(ROCMPolicy)

set(ROCM_INSTALL_LIBDIR lib)
rocm_cmake_policy(GET RCP0000 SETUP_DEV_COMPONENT)
rocm_cmake_policy(GET RCP0004 USE_POLICIES)
if(NOT USE_POLICIES STREQUAL "NEW")
    if(ROCM_USE_DEV_COMPONENT AND NOT WIN32)
        rocm_cmake_policy(SET RCP0000 NEW)
    else()
        rocm_cmake_policy(SET RCP0000 OLD)
    endif()
endif()

function(rocm_install)
    rocm_cmake_policy(GET RCP0000 USE_DEV_COMPONENT)
    rocm_cmake_policy(GET RCP0004 USE_POLICIES)
    if(ARGV0 STREQUAL "TARGETS")
        # rocm_install_targets deals with the component in its own fashion.
        rocm_install_targets("${ARGN}")
    elseif(NOT USE_DEV_COMPONENT STREQUAL "NEW")
        # If we want legacy behaviour, directly call install with no meddling.
        install(${ARGN})
    else()
        # We want to define the COMPONENT argument in the correct position, only if the user did not define
        #  the COMPONENT argument. Therefore, capture the component argument and any arguments which can
        #  legally follow it, so we can place those after the inserted COMPONENT argument.
        set(options OPTIONAL EXCLUDE_FROM_ALL)
        set(oneValueArgs COMPONENT RENAME)
        # Specifying all valid first arguments as multiValueArgs captures all arguments between the first argument
        #  and the COMPONENT argument (or any argument which can follow COMPONENT) in order.
        set(multiValueArgs FILES PROGRAMS DIRECTORY CODE SCRIPT EXPORT FILES_MATCHING)

        cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
        if(PARSE_COMPONENT)
            # The user specified the component, so don't do anything.
            install(${ARGN})
            return()
        endif()
        rocm_cmake_policy(GET RCP0002 USE_DEFAULT_RUNTIME)
        rocm_cmake_policy(GET RCP0005 MODIFY_INSTALL_COMPONENT)
        if(USE_DEFAULT_RUNTIME STREQUAL "NEW")
            set(_runtime_install_component "runtime")
        else()
            set(_runtime_install_component "Unspecified")
        endif()
        set(INSTALL_ARGS "${ARGV0};"
            "${PARSE_FILES}"
            "${PARSE_PROGRAMS}"
            "${PARSE_DIRECTORY}"
            "${PARSE_CODE}"
            "${PARSE_SCRIPT}"
            "${PARSE_EXPORT}")

        set(RUNTIME_MODES "PROGRAMS")
        if(NOT ARGV0 IN_LIST RUNTIME_MODES)
            list(APPEND INSTALL_ARGS COMPONENT devel)
        elseif(MODIFY_INSTALL_COMPONENT STREQUAL "NEW")
            list(APPEND INSTALL_ARGS COMPONENT "${_runtime_install_component}")
        endif()

        if(PARSE_RENAME)
            list(APPEND INSTALL_ARGS RENAME "${PARSE_RENAME}")
        endif()
        if(PARSE_OPTIONAL)
            list(APPEND INSTALL_ARGS OPTIONAL)
        endif()
        if(PARSE_EXCLUDE_FROM_ALL)
            list(APPEND INSTALL_ARGS EXCLUDE_FROM_ALL)
        endif()
        if(PARSE_FILES_MATCHING)
            list(APPEND INSTALL_ARGS FILES_MATCHING "${PARSE_FILES_MATCHING}")
        endif()
        install(${INSTALL_ARGS})
    endif()
endfunction()

function(rocm_install_targets)
    set(options)
    set(oneValueArgs PREFIX EXPORT COMPONENT)
    set(multiValueArgs TARGETS INCLUDE)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
    set(EXPORT_FILE ${PROJECT_NAME_LOWER}-targets)
    if(PARSE_EXPORT)
        set(EXPORT_FILE ${PARSE_EXPORT})
    endif()

    if(PARSE_PREFIX)
        set(PREFIX_DIR ${PARSE_PREFIX})
        set(BIN_INSTALL_DIR ${PARSE_PREFIX}/${CMAKE_INSTALL_BINDIR})
        set(LIB_INSTALL_DIR ${PARSE_PREFIX}/${ROCM_INSTALL_LIBDIR})
        set(INCLUDE_INSTALL_DIR ${PARSE_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})
    else()
        set(BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR})
        set(LIB_INSTALL_DIR ${ROCM_INSTALL_LIBDIR})
        set(INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    foreach(TARGET ${PARSE_TARGETS})
        foreach(INCLUDE ${PARSE_INCLUDE})
            get_filename_component(INCLUDE_PATH ${INCLUDE} ABSOLUTE)
            target_include_directories(${TARGET} INTERFACE $<BUILD_INTERFACE:${INCLUDE_PATH}>)
            get_target_property(TARGET_TYPE ${TARGET} TYPE)
            if(NOT "${TARGET_TYPE}" STREQUAL "INTERFACE_LIBRARY")
                target_include_directories(${TARGET} PRIVATE ${INCLUDE_PATH})
            endif()
        endforeach()
        target_include_directories(${TARGET} INTERFACE $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>)
    endforeach()

    rocm_cmake_policy(GET RCP0002 USE_DEFAULT_RUNTIME)
    if(USE_DEFAULT_RUNTIME STREQUAL "NEW")
        set(runtime_component "runtime")
    else()
        set(runtime_component "Unspecified")
    endif()

    rocm_cmake_policy(GET RCP0000 SETUP_DEVEL)
    rocm_cmake_policy(GET RCP0004 USE_POLICIES)
    if(
        (NOT USE_POLICIES STREQUAL "NEW" AND ROCM_USE_DEV_COMPONENT) OR
        (USE_POLICIES STREQUAL "NEW" AND SETUP_DEVEL STREQUAL "NEW")
    )
        set(devel_component_arg "COMPONENT;devel")
    else()
        set(devel_component_arg "COMPONENT;${runtime_component}")
    endif()

    rocm_cmake_policy(GET RCP0005 MODIFY_INSTALL_COMPONENT)
    if(PARSE_COMPONENT)
        set(runtime_component_arg "COMPONENT;${PARSE_COMPONENT}")
        set(devel_component_arg "COMPONENT;${PARSE_COMPONENT}")
    elseif(MODIFY_INSTALL_COMPONENT STREQUAL "NEW")
        set(runtime_component_arg "COMPONENT;${runtime_component}")
    endif()

    foreach(INCLUDE ${PARSE_INCLUDE})
        install(
            DIRECTORY ${INCLUDE}/
            DESTINATION ${INCLUDE_INSTALL_DIR}
            ${devel_component_arg}
            FILES_MATCHING
            PATTERN "*.h"
            PATTERN "*.hpp"
            PATTERN "*.hh"
            PATTERN "*.hxx"
            PATTERN "*.inl")
    endforeach()

    install(
        TARGETS ${PARSE_TARGETS}
        EXPORT ${EXPORT_FILE}
        RUNTIME
            DESTINATION ${BIN_INSTALL_DIR}
            ${runtime_component_arg}
        LIBRARY
            DESTINATION ${LIB_INSTALL_DIR}
            ${runtime_component_arg}
            NAMELINK_SKIP
        ARCHIVE
            DESTINATION ${LIB_INSTALL_DIR}
            ${devel_component_arg}
    )
    foreach(TARGET IN LISTS PARSE_TARGETS)
        get_target_property(T_TYPE ${TARGET} TYPE)
        if(T_TYPE STREQUAL "SHARED_LIBRARY")
            install(
                    TARGETS ${TARGET}
                    EXPORT ${EXPORT_FILE}
                    LIBRARY
                        DESTINATION ${LIB_INSTALL_DIR}
                        ${devel_component_arg}
                        NAMELINK_ONLY
            )
        endif()
    endforeach()
endfunction()

set(_rocm_tmp_list_marker "@@__rocm_tmp_list_marker__@@")

function(rocm_list_split LIST ELEMENT OUTPUT_LIST)
    string(REPLACE ";" ${_rocm_tmp_list_marker} TMPLIST "${${LIST}}")
    string(REPLACE "${_rocm_tmp_list_marker}${ELEMENT}${_rocm_tmp_list_marker}" ";" TMPLIST "${TMPLIST}")
    string(REPLACE "${ELEMENT}${_rocm_tmp_list_marker}" "" TMPLIST "${TMPLIST}")
    string(REPLACE "${_rocm_tmp_list_marker}${ELEMENT}" "" TMPLIST "${TMPLIST}")
    set(LIST_PREFIX _rocm_list_split_${OUTPUT_LIST}_SUBLIST)
    set(count 0)
    set(result)
    foreach(SUBLIST ${TMPLIST})
        string(REPLACE ${_rocm_tmp_list_marker} ";" TMPSUBLIST "${SUBLIST}")
        math(EXPR count "${count}+1")
        set(list_var ${LIST_PREFIX}_${count})
        set(${list_var}
            "${TMPSUBLIST}"
            PARENT_SCOPE)
        list(APPEND result ${LIST_PREFIX}_${count})
    endforeach()
    set(${OUTPUT_LIST}
        "${result}"
        PARENT_SCOPE)
endfunction()

function(rocm_write_package_template_function FILENAME NAME)
    string(REPLACE ";" " " ARGS "${ARGN}")
    file(
        APPEND ${FILENAME}
        "
${NAME}(${ARGS})
")
endfunction()

function(rocm_write_package_deps CONFIG_TEMPLATE)
    set(DEPENDS ${ARGN})
    rocm_list_split(DEPENDS PACKAGE DEPENDS_LIST)
    foreach(DEPEND ${DEPENDS_LIST})
        rocm_write_package_template_function(${CONFIG_TEMPLATE} find_dependency ${${DEPEND}})
    endforeach()
endfunction()

function(rocm_export_targets)
    set(options)
    set(oneValueArgs NAMESPACE EXPORT NAME COMPATIBILITY PREFIX)
    set(multiValueArgs TARGETS DEPENDS INCLUDE STATIC_DEPENDS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(PACKAGE_NAME ${PROJECT_NAME})
    if(PARSE_NAME)
        set(PACKAGE_NAME ${PARSE_NAME})
    endif()

    string(TOUPPER ${PACKAGE_NAME} PACKAGE_NAME_UPPER)
    string(TOLOWER ${PACKAGE_NAME} PACKAGE_NAME_LOWER)

    set(TARGET_FILE ${PACKAGE_NAME_LOWER}-targets)
    if(PARSE_EXPORT)
        set(TARGET_FILE ${PARSE_EXPORT})
    endif()
    set(CONFIG_NAME ${PACKAGE_NAME_LOWER}-config)
    set(TARGET_VERSION ${PROJECT_VERSION})

    if(PARSE_PREFIX)
        set(PREFIX_DIR ${PARSE_PREFIX})
        set(PREFIX_ARG PREFIX ${PREFIX_DIR})
        set(BIN_INSTALL_DIR ${PREFIX_DIR}/${CMAKE_INSTALL_BINDIR})
        set(LIB_INSTALL_DIR ${PREFIX_DIR}/${ROCM_INSTALL_LIBDIR})
        set(INCLUDE_INSTALL_DIR ${PREFIX_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    else()
        set(BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR})
        set(LIB_INSTALL_DIR ${ROCM_INSTALL_LIBDIR})
        set(INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR})
    endif()
    set(CONFIG_PACKAGE_INSTALL_DIR ${LIB_INSTALL_DIR}/cmake/${PACKAGE_NAME_LOWER})

    set(CONFIG_TEMPLATE "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME_LOWER}-config.cmake.in")

    file(
        WRITE ${CONFIG_TEMPLATE}
        "
@PACKAGE_INIT@
    ")

    foreach(NAME ${PACKAGE_NAME} ${PACKAGE_NAME_UPPER} ${PACKAGE_NAME_LOWER})
        rocm_write_package_template_function(${CONFIG_TEMPLATE} set_and_check ${NAME}_INCLUDE_DIR
                                             "@PACKAGE_INCLUDE_INSTALL_DIR@")
        rocm_write_package_template_function(${CONFIG_TEMPLATE} set_and_check ${NAME}_INCLUDE_DIRS
                                             "@PACKAGE_INCLUDE_INSTALL_DIR@")
    endforeach()
    rocm_write_package_template_function(${CONFIG_TEMPLATE} set_and_check ${PACKAGE_NAME}_TARGET_FILE
                                         "@PACKAGE_CONFIG_PACKAGE_INSTALL_DIR@/${TARGET_FILE}.cmake")

    if(PARSE_DEPENDS)
        rocm_write_package_deps(${CONFIG_TEMPLATE} ${PARSE_DEPENDS})
    endif()

    if(PARSE_STATIC_DEPENDS AND NOT BUILD_SHARED_LIBS)
        rocm_write_package_deps(${CONFIG_TEMPLATE} ${PARSE_STATIC_DEPENDS})
    endif()

    foreach(INCLUDE ${PARSE_INCLUDE})
        rocm_install(FILES ${INCLUDE} DESTINATION ${CONFIG_PACKAGE_INSTALL_DIR})
        get_filename_component(INCLUDE_BASE ${INCLUDE} NAME)
        rocm_write_package_template_function(${CONFIG_TEMPLATE} include "\${CMAKE_CURRENT_LIST_DIR}/${INCLUDE_BASE}")
    endforeach()

    if(PARSE_TARGETS)
        rocm_write_package_template_function(${CONFIG_TEMPLATE} include "\${${PACKAGE_NAME}_TARGET_FILE}")
        foreach(NAME ${PACKAGE_NAME} ${PACKAGE_NAME_UPPER} ${PACKAGE_NAME_LOWER})
            rocm_write_package_template_function(${CONFIG_TEMPLATE} set ${NAME}_LIBRARIES ${PARSE_TARGETS})
            rocm_write_package_template_function(${CONFIG_TEMPLATE} set ${NAME}_LIBRARY ${PARSE_TARGETS})
        endforeach()
    endif()

    rocm_configure_package_config_file(
        ${CONFIG_TEMPLATE} ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}.cmake
        INSTALL_DESTINATION ${CONFIG_PACKAGE_INSTALL_DIR} ${PREFIX_ARG}
        PATH_VARS LIB_INSTALL_DIR INCLUDE_INSTALL_DIR CONFIG_PACKAGE_INSTALL_DIR)
    set(COMPATIBILITY_ARG SameMajorVersion)
    if(PARSE_COMPATIBILITY)
        set(COMPATIBILITY_ARG ${PARSE_COMPATIBILITY})
    endif()
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}-version.cmake
        VERSION ${TARGET_VERSION}
        COMPATIBILITY ${COMPATIBILITY_ARG})

    set(NAMESPACE_ARG)
    if(PARSE_NAMESPACE)
        set(NAMESPACE_ARG "NAMESPACE;${PARSE_NAMESPACE}")
    endif()
    rocm_install(
        EXPORT ${TARGET_FILE}
        DESTINATION ${CONFIG_PACKAGE_INSTALL_DIR}
        ${NAMESPACE_ARG})

    rocm_install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}-version.cmake
        DESTINATION
            ${CONFIG_PACKAGE_INSTALL_DIR})

endfunction()
