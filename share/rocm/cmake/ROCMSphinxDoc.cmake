# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

include_guard(GLOBAL)

include(CMakeParseArguments)
include(ROCMDocs)

find_program(
    SPHINX_EXECUTABLE
    NAMES sphinx-build
    HINTS "$ENV{SPHINX_DIR}"
    PATH_SUFFIXES bin
    DOC "Sphinx documentation generator")

find_program(
    DOXYGEN_EXECUTABLE
    NAMES doxygen
    HINTS "$ENV{DOXYGEN_DIR}"
    PATH_SUFFIXES bin
    DOC "Doxygen documentation generator")

mark_as_advanced(SPHINX_EXECUTABLE)
mark_as_advanced(DOXYGEN_EXECUTABLE)

function(rocm_add_sphinx_doc SRC_DIR)
    set(options USE_DOXYGEN)
    set(oneValueArgs BUILDER CONFIG_DIR OUTPUT_DIR)
    set(multiValueArgs DEPENDS VARS TEMPLATE_VARS)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(SRC_DIR "${SRC_DIR}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    if(NOT PARSE_CONFIG_DIR AND NOT EXISTS "${SRC_DIR}/conf.py")
        message(FATAL_ERROR "rocm_add_sphinx_doc cannot find ${SRC_DIR}/conf.py")
    endif()

    if(PARSE_BUILDER)
        string(TOUPPER ${PARSE_BUILDER} BUILDER)
    else()
        message(FATAL_ERROR "rocm_add_sphinx_doc requires providing a BUILDER to use.")
    endif()

    if(PARSE_OUTPUT_DIR)
        get_filename_component(OUTPUT_DIR "${PARSE_OUTPUT_DIR}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    else()
        if(DEFINED ROCM_CMAKE_DOCS_DIR)
            set(OUTPUT_DIR "${ROCM_CMAKE_DOCS_DIR}")
        else()
            set(OUTPUT_DIR "sphinx/${PARSE_BUILDER}")
        endif()
    endif()

    if(PARSE_CONFIG_DIR)
        if(NOT EXISTS "${PARSE_CONFIG_DIR}/conf.py")
            message(FATAL_ERROR "rocm_add_sphinx_doc cannot find ${PARSE_CONFIG_DIR}/conf.py")
        endif()
        get_filename_component(CONFIG_DIR "${PARSE_CONFIG_DIR}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set(CONFIG_DIR_ARG -c "${CONFIG_DIR}")
    else()
        set(CONFIG_DIR_ARG)
    endif()

    set(VARS)
    foreach(VAR IN LISTS PARSE_VARS)
        list(APPEND VARS -D "${VAR}")
    endforeach()
    foreach(VAR IN LISTS PARSE_TEMPLATE_VARS)
        list(APPEND VARS -A "${VAR}")
    endforeach()

    if(PARSE_USE_DOXYGEN)
        set(USE_DOXYGEN -D "doxygen_executable=${DOXYGEN_EXECUTABLE}")
    else()
        set(USE_DOXYGEN)
    endif()

    if(NOT TARGET sphinx-${BUILDER})
        add_custom_target(sphinx-${BUILDER})
    endif()

    add_custom_target(
        ${PROJECT_NAME}-sphinx-${BUILDER}
        COMMAND
            "${SPHINX_EXECUTABLE}"
            ${CONFIG_DIR_ARG}
            -b ${PARSE_BUILDER}
            -d "${CMAKE_CURRENT_BINARY_DIR}/doctrees"
            ${USE_DOXYGEN}
            ${VARS}
            "${SRC_DIR}"
            "${OUTPUT_DIR}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Building ${PARSE_BUILDER} documentation with Sphinx")
    add_dependencies(sphinx-${BUILDER} ${PROJECT_NAME}-sphinx-${BUILDER})
    rocm_clean_doc_output("${OUTPUT_DIR}/html")
    rocm_clean_doc_output("${OUTPUT_DIR}/doctrees")
    rocm_mark_as_doc(sphinx-${BUILDER})
    if(PARSE_DEPENDS)
        add_dependencies(sphinx-${BUILDER} ${PARSE_DEPENDS})
    endif()

endfunction()
