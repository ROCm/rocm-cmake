# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(rocm_wrap_header_dir)
    message(STATUS "rocm_wrap_header_dir args: ${ARGN}")
    cmake_parse_arguments(PARSE "" "DIRECTORY;GUARD;LOCATION" "PATTERNS" ${ARGN})
    file (GLOB_RECURSE include_files RELATIVE "${PARSE_DIRECTORY}" ${PARSE_PATTERNS})
    foreach (include_file ${include_files})
        if (NOT "${include_file}" MATCHES "^../")
            rocm_wrap_header_file(
                INCLUDE_FILE "${include_file}"
                GUARD ${PARSE_GUARD}
                LOCATION ${PARSE_LOCATION}
            )
        endif()
    endforeach()
endfunction()

function(rocm_wrap_header_file)
    cmake_parse_arguments(PARSE "" "INCLUDE_FILE;GUARD;LOCATION;INSTALL_LOCATION" "" ${ARGN})
    if(NOT PARSE_INSTALL_LOCATION)
        set(PARSE_INSTALL_LOCATION "${PROJECT_BINARY_DIR}/include/${CMAKE_PROJECT_NAME}")
    endif()
    get_filename_component(file_name ${PARSE_INCLUDE_FILE} NAME)
    get_filename_component(file_path ${PARSE_INCLUDE_FILE} DIRECTORY)
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
    file(RELATIVE_PATH include_statements 
        "${wrapper_location}"
        "${PARSE_INSTALL_LOCATION}/${include_file}"
    )
    configure_file(
        "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/header_template.h.in"
        "${PROJECT_BINARY_DIR}/${PARSE_LOCATION}/${PARSE_INCLUDE_FILE}"
    )
endfunction()
