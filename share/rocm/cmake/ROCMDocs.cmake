# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

include_guard(GLOBAL)

if(NOT TARGET doc)
    add_custom_target(doc)
endif()

function(rocm_mark_as_doc)
    add_dependencies(doc ${ARGN})
endfunction()

function(rocm_clean_doc_output DIR)
    set_property(
        DIRECTORY
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES "${DIR}")
endfunction()
