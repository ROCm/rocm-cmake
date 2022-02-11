# ######################################################################################################################
# Copyright (C) 2022 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(rocm_wrap_header_dir DIRECTORY)
    cmake_parse_arguments(PARSE "" "HEADER_LOCATION" "PATTERNS;GUARDS;WRAPPER_LOCATIONS;OUTPUT_LOCATIONS" ${ARGN})
    if(NOT PARSE_HEADER_LOCATION)
        set(PARSE_HEADER_LOCATION "include/${CMAKE_PROJECT_NAME}")
    endif()
    file (GLOB_RECURSE include_files RELATIVE "${DIRECTORY}" ${PARSE_PATTERNS})
    foreach (include_file ${include_files})
        if (NOT "${include_file}" MATCHES "^../")
            rocm_wrap_header_file(
                ${include_file}
                GUARDS ${PARSE_GUARDS}
                HEADER_LOCATION ${PARSE_HEADER_LOCATION}
                WRAPPER_LOCATIONS ${PARSE_WRAPPER_LOCATIONS}
                OUTPUT_LOCATIONS ${PARSE_OUTPUT_LOCATIONS}
            )
        endif()
    endforeach()
endfunction()

function(rocm_wrap_header_file INCLUDE_FILE)
    cmake_parse_arguments(PARSE "" "HEADER_LOCATION" "GUARDS;WRAPPER_LOCATIONS;OUTPUT_LOCATIONS" ${ARGN})
    if(NOT PARSE_HEADER_LOCATION)
        set(PARSE_HEADER_LOCATION "include/${CMAKE_PROJECT_NAME}")
    endif()
    get_filename_component(header_location "${PARSE_HEADER_LOCATION}/${INCLUDE_FILE}"
        ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
    get_filename_component(file_name ${INCLUDE_FILE} NAME)
    get_filename_component(file_path ${INCLUDE_FILE} DIRECTORY)
    string(REPLACE "/" ";" path_dirs "${file_path}")

    set(guard_common "")
    foreach(subdir IN LISTS path_dirs)
        if(NOT (subdir STREQUAL '' OR subdir STREQUAL '.'))
            string(TOUPPER ${subdir} subdir_uc)
            set(guard_common "${guard_common}_${subdir_uc}")
        endif()
    endforeach()
    string(TOUPPER ${file_name} file_name)
    string(REGEX REPLACE "[-.]" "_" file_name "${file_name}")
    set(guard_common "${guard_common}_${file_name}")

    # do-while
    set(first_time true)
    message(STATUS "Creating wrapper for ${INCLUDE_FILE}")
    while(first_time OR PARSE_GUARDS OR PARSE_WRAPPER_LOCATIONS OR PARSE_OUTPUT_LOCATIONS)
        rocm_wrap_header_get_info(ITEM PARSE_GUARDS PARSE_WRAPPER_LOCATIONS PARSE_OUTPUT_LOCATIONS)
        set(include_guard "ROCM_${ITEM_GUARD}${guard_common}")
        set(wrapper_location "${ITEM_WRAPPER_LOCATION}/${file_path}")
        file(RELATIVE_PATH file_rel_path "${wrapper_location}" "${header_location}")
        configure_file(
            "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/header_template.h.in"
            "${ITEM_OUTPUT_LOCATION}/${INCLUDE_FILE}"
        )
        set(first_time false)
    endwhile()

endfunction()

# internal
macro(rocm_wrap_header_get_info OUTPUT_PREFIX GUARDS_LIST WRAPPER_LOC_LIST OUTPUT_LOC_LIST)
    if(${GUARDS_LIST})
        list(GET ${GUARDS_LIST} 0 ${OUTPUT_PREFIX}_GUARD)
        list(REMOVE_AT ${GUARDS_LIST} 0)
    else()
        set(${OUTPUT_PREFIX}_GUARD WRAPPER)
    endif()
    if(${WRAPPER_LOC_LIST})
        list(GET ${WRAPPER_LOC_LIST} 0 ${OUTPUT_PREFIX}_WRAPPER_LOCATION)
        list(REMOVE_AT ${WRAPPER_LOC_LIST} 0)
    else()
        set(${OUTPUT_PREFIX}_WRAPPER_LOCATION "${CMAKE_PROJECT_NAME}/include")
    endif()
    if(${OUTPUT_LOC_LIST})
        list(GET ${OUTPUT_LOC_LIST} 0 ${OUTPUT_PREFIX}_OUTPUT_LOCATION)
        list(REMOVE_AT ${OUTPUT_LOC_LIST} 0)
    else()
        set(${OUTPUT_PREFIX}_OUTPUT_LOCATION ${CMAKE_BINARY_DIR}/${${OUTPUT_PREFIX}_WRAPPER_LOCATION})
    endif()
    get_filename_component(${OUTPUT_PREFIX}_WRAPPER_LOCATION "${${OUTPUT_PREFIX}_WRAPPER_LOCATION}"
        ABSOLUTE BASE_DIR "${PROJECT_BINARY_DIR}")
    get_filename_component(${OUTPUT_PREFIX}_OUTPUT_LOCATION "${${OUTPUT_PREFIX}_OUTPUT_LOCATION}"
        ABSOLUTE BASE_DIR "${PROJECT_BINARY_DIR}")
endmacro()
