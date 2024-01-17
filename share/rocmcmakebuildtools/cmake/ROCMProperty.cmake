# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(rocm_define_property SCOPE NAME DOC)
    if(NOT CMAKE_SCRIPT_MODE_FILE)
        define_property(${SCOPE} PROPERTY "${NAME}" BRIEF_DOCS "${DOC}" FULL_DOCS "${DOC}")
    endif()
endfunction()
