# ######################################################################################################################
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# ######################################################################################################################

include(ROCMCheckTargetIds)

macro(_rocm_get_arch_keyword_list)
    # TODO: These lists are not accurate! They must be updated before this can be merged.
    set(_arches_rocm6.0 gfx900 gfx906:xnack- gfx908:xnack- gfx90a:xnack+ gfx90a:xnack- gfx940 gfx941 gfx942 gfx1010 gfx1012 gfx1030 gfx1100 gfx1101 gfx1102)
    set(_arches_rocm6.3 gfx900 gfx906:xnack- gfx908:xnack- gfx90a gfx940 gfx941 gfx942 gfx1010 gfx1012 gfx1030 gfx1100 gfx1101 gfx1102 gfx1151 gfx1200 gfx1201)
    set(_arches_asan gfx908:xnack+ gfx90a:xnack+ gfx942:xnack+ )
    set(_arches_rdna2 gfx1030 )
    set(_arches_rdna3 gfx1100 )
    set(_arches_rdna ${_arches_rdna2} ${_arches_rdna3} )
    set(_arches_cdna1 gfx908:xnack- gfx908:xnack+ )
    set(_arches_cdna2 gfx90a:xnack- gfx90a:xnack+ )
    set(_arches_cdna3 gfx942:xnack- gfx942:xnack+ )
    set(_arches_cdna ${_arches_cdna1} ${_arches_cdna2} ${_arches_cdna3} )
    set(_arches_gcn gfx900 gfx906:xnack-)
    set(_arch_keyword_list rocm6.0 rocm6.3 asan rdna cdna gcn)
endmacro()

function(_rocm_process_arch_list OUT_VAR)
    _rocm_get_arch_keyword_list()
    set(new_arch_list)
    foreach (ARCH_ITEM IN LISTS ARGN)
        if (${ARCH_ITEM} IN_LIST _arch_keyword_list)
            list(APPEND new_arch_list ${_arches_${ARCH_ITEM}})
        else()
            list(APPEND new_arch_list ${ARCH_ITEM})
        endif()
    endforeach()
    set(${OUT_VAR} "${new_arch_list}" PARENT_SCOPE)
endfunction()

function(rocm_determine_architecture)
    # parse arguments
    set(options)
    set(oneValueArgs)
    set(multiValueArgs BLOCK ALLOW)
    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_property(enabled_langs GLOBAL PROPERTY ENABLED_LANGUAGES)

    set(HIP_ENABLED FALSE)
    set(arch_dest GPU_TARGETS)
    if (HIP IN_LIST enabled_langs)
        set(HIP_ENABLED TRUE)
        set(arch_dest CMAKE_HIP_ARCHITECTURES)
    endif()

    # Determine input list of architectures to use
    set(arch_list)
    if (HIP_ENABLED AND (CMAKE_HIP_ARCHITECTURES))
        set(arch_list ${CMAKE_HIP_ARCHITECTURES})
    elseif(GPU_TARGETS)
        set(arch_list ${GPU_TARGETS})
    elseif(AMDGPU_TARGETS)
        message(DEPRECATION "Use of AMDGPU_TARGETS is deprecated, replace with GPU_TARGETS.")
        set(arch_list ${AMDGPU_TARGETS})
    endif()

    # TODO: if arch_list is empty at this point, get the architecture of all GPUs on the current machine

    # Process any arch keywords
    _rocm_process_arch_list(arch_list ${arch_list})
    if(PARSE_BLOCK)
        _rocm_process_arch_list(block_list ${PARSE_BLOCK})
    else()
        set(block_list)
    endif()
    if(PARSE_ALLOW)
        _rocm_process_arch_list(allow_list ${PARSE_ALLOW})
        list(REMOVE_ITEM block_list ${allow_list})
    endif()
    # Remove arches listed in block, not listed in allow
    list(REMOVE_ITEM arch_list ${block_list})
    rocm_check_target_ids(arch_list TARGETS ${arch_list})
    set(${arch_dest} "${arch_list}" CACHE STRING "")
endfunction(rocm_determine_architecture)
