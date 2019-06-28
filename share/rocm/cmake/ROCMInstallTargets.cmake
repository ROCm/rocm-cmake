################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


include(CMakeParseArguments)
include(GNUInstallDirs)
include(ROCMPackageConfigHelpers)

set(ROCM_INSTALL_LIBDIR lib)

function(rocm_install_targets)
    set(options)
    set(oneValueArgs PREFIX EXPORT)
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

    foreach(INCLUDE ${PARSE_INCLUDE})
        install(DIRECTORY ${INCLUDE}/ DESTINATION ${INCLUDE_INSTALL_DIR}
            FILES_MATCHING 
            PATTERN "*.h"
            PATTERN "*.hpp"
            PATTERN "*.hh"
            PATTERN "*.hxx"
            PATTERN "*.inl"
        )
    endforeach()

    install(TARGETS ${PARSE_TARGETS} 
        EXPORT ${EXPORT_FILE}
        RUNTIME DESTINATION ${BIN_INSTALL_DIR}
        LIBRARY DESTINATION ${LIB_INSTALL_DIR}
        ARCHIVE DESTINATION ${LIB_INSTALL_DIR})

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
        set(${LIST_PREFIX}_${count} "${TMPSUBLIST}" PARENT_SCOPE)
        list(APPEND result ${LIST_PREFIX}_${count})
    endforeach()
    set(${OUTPUT_LIST} "${result}" PARENT_SCOPE)
endfunction()

function(rocm_write_package_template_function FILENAME NAME)
    string(REPLACE ";" " " ARGS "${ARGN}")
    file(APPEND ${FILENAME}
"
${NAME}(${ARGS})
")
endfunction()

function(rocm_export_targets)
    set(options)
    set(oneValueArgs NAMESPACE EXPORT NAME COMPATIBILITY PREFIX)
    set(multiValueArgs TARGETS DEPENDS INCLUDE)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}"  ${ARGN})

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

    file(WRITE ${CONFIG_TEMPLATE} "
@PACKAGE_INIT@
    ")

    foreach(NAME ${PACKAGE_NAME} ${PACKAGE_NAME_UPPER} ${PACKAGE_NAME_LOWER})
        rocm_write_package_template_function(${CONFIG_TEMPLATE} set_and_check ${NAME}_INCLUDE_DIR "@PACKAGE_INCLUDE_INSTALL_DIR@")
        rocm_write_package_template_function(${CONFIG_TEMPLATE} set_and_check ${NAME}_INCLUDE_DIRS "@PACKAGE_INCLUDE_INSTALL_DIR@")
    endforeach()
    rocm_write_package_template_function(${CONFIG_TEMPLATE} set_and_check ${PACKAGE_NAME}_TARGET_FILE "@PACKAGE_CONFIG_PACKAGE_INSTALL_DIR@/${TARGET_FILE}.cmake")

    if(PARSE_DEPENDS)
        rocm_list_split(PARSE_DEPENDS PACKAGE DEPENDS_LIST)
        foreach(DEPEND ${DEPENDS_LIST})
            rocm_write_package_template_function(${CONFIG_TEMPLATE} find_dependency ${${DEPEND}})
        endforeach()
    endif()

    foreach(INCLUDE ${PARSE_INCLUDE})
        install(FILES ${INCLUDE} DESTINATION ${CONFIG_PACKAGE_INSTALL_DIR})
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
        ${CONFIG_TEMPLATE}
        ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}.cmake
        INSTALL_DESTINATION ${CONFIG_PACKAGE_INSTALL_DIR}
        ${PREFIX_ARG}
        PATH_VARS LIB_INSTALL_DIR INCLUDE_INSTALL_DIR CONFIG_PACKAGE_INSTALL_DIR
    )
    set(COMPATIBILITY_ARG SameMajorVersion)
    if(PARSE_COMPATIBILITY)
        set(COMPATIBILITY_ARG ${PARSE_COMPATIBILITY})
    endif()
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}-version.cmake
        VERSION ${TARGET_VERSION}
        COMPATIBILITY ${COMPATIBILITY_ARG}
    )

    set(NAMESPACE_ARG)
    if(PARSE_NAMESPACE)
        set(NAMESPACE_ARG "NAMESPACE;${PARSE_NAMESPACE}")
    endif()
    install( EXPORT ${TARGET_FILE}
        DESTINATION
        ${CONFIG_PACKAGE_INSTALL_DIR}
        ${NAMESPACE_ARG}
    )

    install( FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}-version.cmake
        DESTINATION
        ${CONFIG_PACKAGE_INSTALL_DIR})

endfunction()


