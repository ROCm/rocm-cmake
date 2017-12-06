################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################

if(NOT TARGET analyze)
    add_custom_target(analyze)
endif()

function(rocm_mark_as_analyzer)
    add_dependencies(analyze ${ARGN})
endfunction()

