# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(rocm_wrap_header_dir DIRECTORY)
    cmake_parse_arguments(PARSE "" "GUARD;LOCATION;OUTPUT_LOCATION" "PATTERNS" ${ARGN})
    if(NOT PARSE_GUARD)
        set(PARSE_GUARD WRAPPER)
    endif()
    if(NOT PARSE_LOCATION)
        set(PARSE_LOCATION "${CMAKE_PROJECT_NAME}/include")
    endif()
    if(NOT PARSE_OUTPUT_LOCATION)
        set(PARSE_OUTPUT_LOCATION "${PROJECT_BINARY_DIR}/${PARSE_LOCATION}")
    endif()
    get_filename_component(PARSE_OUTPUT_LOCATION "${PARSE_OUTPUT_LOCATION}" ABSOLUTE BASE_DIR "${PROJECT_BINARY_DIR}")
    file (GLOB_RECURSE include_files RELATIVE "${DIRECTORY}" ${PARSE_PATTERNS})
    foreach (include_file ${include_files})
        if (NOT "${include_file}" MATCHES "^../")
            rocm_wrap_header_file(
                "${include_file}"
                GUARD ${PARSE_GUARD}
                LOCATION ${PARSE_LOCATION}
                OUTPUT_LOCATION ${PARSE_OUTPUT_LOCATION}
            )
        endif()
    endforeach()
endfunction()

function(rocm_wrap_header_file INCLUDE_FILE)
    cmake_parse_arguments(PARSE "" "GUARD;LOCATION;INSTALL_LOCATION;OUTPUT_LOCATION" "" ${ARGN})
    if(NOT PARSE_GUARD)
        set(PARSE_GUARD WRAPPER)
    endif()
    if(NOT PARSE_LOCATION)
        set(PARSE_LOCATION "${CMAKE_PROJECT_NAME}/include")
    endif()
    if(NOT PARSE_INSTALL_LOCATION)
        set(PARSE_INSTALL_LOCATION "${PROJECT_BINARY_DIR}/include/${CMAKE_PROJECT_NAME}")
    endif()
    if(NOT PARSE_OUTPUT_LOCATION)
        set(PARSE_OUTPUT_LOCATION "${PROJECT_BINARY_DIR}/${PARSE_LOCATION}")
    endif()
    get_filename_component(PARSE_OUTPUT_LOCATION "${PARSE_OUTPUT_LOCATION}" ABSOLUTE BASE_DIR "${PROJECT_BINARY_DIR}")
    get_filename_component(file_name ${INCLUDE_FILE} NAME)
    get_filename_component(file_path ${INCLUDE_FILE} DIRECTORY)
    string(REPLACE "/" ";" path_dirs "${file_path}")
    set(guard "")
    foreach(subdir IN LISTS path_dirs)
        if(NOT (subdir STREQUAL '' OR subdir STREQUAL '.'))
            string(TOUPPER ${subdir} subdir_uc)
            set(guard "${guard}_${subdir_uc}")
        endif()
    endforeach()

    string(TOUPPER ${file_name} file_name)
    string(REGEX REPLACE "[-.]" "_" file_name "${file_name}")
    set(include_guard "ROCM_${PARSE_GUARD}${guard}_${file_name}")
    set(wrapper_location "${PROJECT_BINARY_DIR}/${PARSE_LOCATION}/${file_path}")
    file(RELATIVE_PATH file_rel_path
        "${wrapper_location}"
        "${PARSE_INSTALL_LOCATION}/${include_file}"
    )
    configure_file(
        "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/header_template.h.in"
        "${PARSE_OUTPUT_LOCATION}/${INCLUDE_FILE}"
    )
endfunction()
