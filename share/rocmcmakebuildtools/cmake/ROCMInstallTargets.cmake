# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

cmake_policy(SET CMP0057 NEW)

# todo: consolidate with duplicate in ROCMCreatePackage.cmake
# Default libdir to "lib", this skips GNUInstallDirs from trying to take a guess if it's unset:
set(CMAKE_INSTALL_LIBDIR "lib" CACHE STRING "Library install directory")

include(CMakeParseArguments)
include(GNUInstallDirs)
include(ROCMPackageConfigHelpers)
include(ROCMProperty)

set(ROCM_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR})
set(ROCM_USE_DEV_COMPONENT ON CACHE BOOL "Generate a devel package?")

rocm_define_property(TARGET "ROCM_INSTALL_DIR" "Install dir for target")
function(rocm_set_install_dir_property)
    set(options)
    set(oneValueArgs DESTINATION RUNTIME_DESTINATION ARCHIVE_DESTINATION LIBRARY_DESTINATION)
    set(multiValueArgs TARGETS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    if(PARSE_UNPARSED_ARGUMENTS)
        message(
            FATAL_ERROR "Unknown keywords given to rocm_set_install_dir_property(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    set(RUNTIME_DESTINATION ${PARSE_DESTINATION})
    if(PARSE_RUNTIME_DESTINATION)
        set(RUNTIME_DESTINATION ${PARSE_RUNTIME_DESTINATION})
    endif()
    set(ARCHIVE_DESTINATION ${PARSE_DESTINATION})
    if(PARSE_ARCHIVE_DESTINATION)
        set(ARCHIVE_DESTINATION ${PARSE_ARCHIVE_DESTINATION})
    endif()
    set(LIBRARY_DESTINATION ${PARSE_DESTINATION})
    if(PARSE_LIBRARY_DESTINATION)
        set(LIBRARY_DESTINATION ${PARSE_LIBRARY_DESTINATION})
    endif()

    foreach(TARGET ${PARSE_TARGETS})
        get_target_property(TARGET_TYPE ${TARGET} TYPE)
        set(DESTINATION ${PARSE_DESTINATION})
        if(TARGET_TYPE STREQUAL "EXECUTABLE")
            set(DESTINATION ${RUNTIME_DESTINATION})
        elseif(TARGET_TYPE STREQUAL "STATIC_LIBRARY")
            set(DESTINATION ${ARCHIVE_DESTINATION})
        elseif(TARGET_TYPE MATCHES "LIBRARY")
            set(DESTINATION ${PARSE_LIBRARY_DESTINATION})
        endif()
        # Interface targets dont have an install dir
        if(NOT TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
            if(DESTINATION MATCHES "^/|$")
                set_target_properties(${TARGET} PROPERTIES ROCM_INSTALL_DIR ${DESTINATION})
            else()
                set_target_properties(${TARGET} PROPERTIES ROCM_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${DESTINATION})
            endif()
        endif()
    endforeach()
endfunction()

function(rocm_install)
    if(ARGV0 STREQUAL "TARGETS")
        # rocm_install_targets deals with the component in its own fashion.
        rocm_install_targets("${ARGN}")
    elseif(NOT ROCM_USE_DEV_COMPONENT)
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
        set(INSTALL_ARGS "${ARGV0};"
            "${PARSE_FILES}"
            "${PARSE_PROGRAMS}"
            "${PARSE_DIRECTORY}"
            "${PARSE_CODE}"
            "${PARSE_SCRIPT}"
            "${PARSE_EXPORT}")

        set(RUNTIME_MODES "PROGRAMS")
        if(PARSE_COMPONENT)
            list(APPEND INSTALL_ARGS COMPONENT "${PARSE_COMPONENT}")
        elseif(NOT ARGV0 IN_LIST RUNTIME_MODES)
            list(APPEND INSTALL_ARGS COMPONENT devel)
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

option(ROCM_SYMLINK_LIBS "Create backwards compatibility symlink for library files." OFF)

function(rocm_install_targets)
    set(options PRIVATE)
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
        if(PARSE_PRIVATE)
            set(BIN_INSTALL_DIR ${PARSE_PREFIX}/${ROCM_INSTALL_LIBDIR}/${PROJECT_NAME}/bin)
            set(LIB_INSTALL_DIR ${PARSE_PREFIX}/${ROCM_INSTALL_LIBDIR}/${PROJECT_NAME}/lib)
            set(INCLUDE_INSTALL_DIR ${PARSE_PREFIX}/${ROCM_INSTALL_LIBDIR}/${PROJECT_NAME}/include)
        else()
            set(BIN_INSTALL_DIR ${PARSE_PREFIX}/${CMAKE_INSTALL_BINDIR})
            set(LIB_INSTALL_DIR ${PARSE_PREFIX}/${ROCM_INSTALL_LIBDIR})
            set(INCLUDE_INSTALL_DIR ${PARSE_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})
        endif()
    elseif(ENABLE_ASAN_PACKAGING)
        if(PARSE_PRIVATE)
            set(BIN_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/asan/${PROJECT_NAME}/bin)
            set(LIB_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/asan/${PROJECT_NAME}/lib)
            set(INCLUDE_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/asan/${PROJECT_NAME}/include)
        else()
            set(BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR}/asan)
            set(LIB_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/asan)
            set(INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR})
        endif()
    else()
        if(PARSE_PRIVATE)
            set(BIN_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/${PROJECT_NAME}/bin)
            set(LIB_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/${PROJECT_NAME}/lib)
            set(INCLUDE_INSTALL_DIR ${ROCM_INSTALL_LIBDIR}/${PROJECT_NAME}/include)
        else()
            set(BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR})
            set(LIB_INSTALL_DIR ${ROCM_INSTALL_LIBDIR})
            set(INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR})
        endif()
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

    set(runtime "runtime")
    set(development "runtime")
    if(PARSE_COMPONENT)
        set(runtime "${PARSE_COMPONENT}")
        set(development "${PARSE_COMPONENT}")
    elseif(ROCM_USE_DEV_COMPONENT)
        set(development "devel")
    endif()

    foreach(INCLUDE ${PARSE_INCLUDE})
        install(
            DIRECTORY ${INCLUDE}/
            DESTINATION ${INCLUDE_INSTALL_DIR}
            COMPONENT ${development}
            FILES_MATCHING
            PATTERN "*.h"
            PATTERN "*.hpp"
            PATTERN "*.hh"
            PATTERN "*.hxx"
            PATTERN "*.inl")
    endforeach()

    foreach(TARGET IN LISTS PARSE_TARGETS)
        get_target_property(T_TYPE ${TARGET} TYPE)
        if(NOT T_TYPE STREQUAL "INTERFACE_LIBRARY")
            set_property(TARGET ${TARGET} APPEND PROPERTY INSTALL_RPATH "$ORIGIN/../lib")
            if(PARSE_PRIVATE)
                # Adding RPATH to private binaries to point to public libraries.
                set_property(TARGET ${TARGET} APPEND PROPERTY INSTALL_RPATH "$ORIGIN/../../")
            else()
                # Adding RPATH to public binaries to point to private libraries.
                set_property(TARGET ${TARGET} APPEND PROPERTY INSTALL_RPATH "$ORIGIN/../lib/${PROJECT_NAME}/lib")
            endif()
        endif()

        set(export_arg EXPORT ${EXPORT_FILE})
        if(T_TYPE STREQUAL "EXECUTABLE")
            unset(export_arg)
        endif()
        install(
            TARGETS ${TARGET}
            ${export_arg}
            RUNTIME
                DESTINATION ${BIN_INSTALL_DIR}
                COMPONENT ${runtime}
            LIBRARY
                DESTINATION ${LIB_INSTALL_DIR}
                COMPONENT ${runtime}
                NAMELINK_SKIP
            ARCHIVE
                DESTINATION ${LIB_INSTALL_DIR}
                COMPONENT ${development}
        )
        rocm_set_install_dir_property(
            TARGETS ${TARGET}
            RUNTIME_DESTINATION ${BIN_INSTALL_DIR}
            LIBRARY_DESTINATION ${LIB_INSTALL_DIR}
            ARCHIVE_DESTINATION ${LIB_INSTALL_DIR}
        )
        if(T_TYPE STREQUAL "SHARED_LIBRARY")
            install(
                    TARGETS ${TARGET}
                    EXPORT ${EXPORT_FILE}
                    LIBRARY
                        DESTINATION ${LIB_INSTALL_DIR}
                        COMPONENT ${development}
                        NAMELINK_ONLY
            )
        endif()
        if(ROCM_SYMLINK_LIBS AND PARSE_PRIVATE)
            message(WARNING "ROCM_SYMLINK_LIBS is not supported with PRIVATE.")
        endif()
        if(ROCM_SYMLINK_LIBS AND NOT PARSE_PRIVATE AND NOT WIN32 AND T_TYPE MATCHES ".*_LIBRARY"
            AND NOT T_TYPE STREQUAL "INTERFACE_LIBRARY")
            string(TOLOWER "${PROJECT_NAME}" LINK_SUBDIR)
            file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_symlink.cmake
                CONTENT "
                set(SRC_DIR \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX})
                set(LINK_DIR \${SRC_DIR}/${LINK_SUBDIR})
                if(NOT EXISTS \${LINK_DIR}/${ROCM_INSTALL_LIBDIR})
                    file(MAKE_DIRECTORY \${LINK_DIR}/${ROCM_INSTALL_LIBDIR})
                endif()
                file(RELATIVE_PATH LINK_PATH
                    \${LINK_DIR}/${ROCM_INSTALL_LIBDIR}
                    \${SRC_DIR}/${ROCM_INSTALL_LIBDIR})
                if(NOT EXISTS \${LINK_DIR}/${ROCM_INSTALL_LIBDIR}/$<TARGET_LINKER_FILE_NAME:${TARGET}>)
                    execute_process(COMMAND \${CMAKE_COMMAND} -E create_symlink
                        \${LINK_PATH}/$<TARGET_LINKER_FILE_NAME:${TARGET}>
                        \${LINK_DIR}/${ROCM_INSTALL_LIBDIR}/$<TARGET_LINKER_FILE_NAME:${TARGET}>
                    )
                endif()
            ")

            rocm_install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_symlink.cmake")
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

    set(INCLUDED_FILES "")

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
        list(APPEND INCLUDED_FILES ${INCLUDE_BASE})
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

    if(ROCM_SYMLINK_LIBS AND NOT WIN32)
        string(TOLOWER "${PROJECT_NAME}" LINK_SUBDIR)

        file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/cmake_symlink.cmake"
            CONTENT "
            set(SRC_DIR \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${CONFIG_PACKAGE_INSTALL_DIR})
            set(LINK_DIR \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${LINK_SUBDIR}/${ROCM_INSTALL_LIBDIR}/cmake)
            set(INCLUDED_FILES \"${INCLUDED_FILES}\")
            if(NOT EXISTS \${LINK_DIR})
                file(MAKE_DIRECTORY \${LINK_DIR})
            endif()
            file(GLOB TARGET_FILES
                LIST_DIRECTORIES false
                RELATIVE \${SRC_DIR}
                \${SRC_DIR}/${TARGET_FILE}*.cmake
            )
            foreach(filename ${CONFIG_NAME}.cmake ${CONFIG_NAME}-version.cmake \${TARGET_FILES} \${INCLUDED_FILES})
                file(RELATIVE_PATH LINK_PATH \${LINK_DIR} \${SRC_DIR}/\${filename})
                if(NOT EXISTS \${LINK_DIR}/\${filename})
                    execute_process(COMMAND \${CMAKE_COMMAND} -E create_symlink
                        \${LINK_PATH}
                        \${LINK_DIR}/\${filename}
                    )
                endif()
            endforeach()
            ")
        rocm_install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/cmake_symlink.cmake")
    endif()
endfunction()
