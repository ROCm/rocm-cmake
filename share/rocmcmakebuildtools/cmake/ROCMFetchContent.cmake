# ######################################################################################################################
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# ######################################################################################################################

include(ROCMChecks)
include(FetchContent)
macro(_save_watched_wrapper func_name)
    function(ROCM_${func_name})
        set(func_ARGV ARGV)
        _push_watched_vars()
        ${func_name}(${func_ARGV})
        _pop_watched_vars()
    endfunction()
endmacro()

_save_watched_wrapper(FetchContent_Declare)
_save_watched_wrapper(FetchContent_MakeAvailable)
_save_watched_wrapper(FetchContent_Populate)
_save_watched_wrapper(FetchContent_GetProperties)
_save_watched_wrapper(FetchContent_SetPopulated)
