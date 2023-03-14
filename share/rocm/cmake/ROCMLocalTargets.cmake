# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(rocm_local_targets VARIABLE)
    set(${VARIABLE} "NOTFOUND" PARENT_SCOPE)
    find_program(_rocm_agent_enumerator rocm_agent_enumerator HINTS /opt/rocm/bin ENV ROCM_PATH)
    if(NOT _rocm_agent_enumerator STREQUAL "_rocm_agent_enumerator-NOTFOUND")
        execute_process(
            COMMAND "${_rocm_agent_enumerator}"
            RESULT_VARIABLE _found_agents
            OUTPUT_VARIABLE _rocm_agents
            ERROR_QUIET
        )
        if (_found_agents EQUAL 0)
            string(REPLACE "\n" ";" _rocm_agents "${_rocm_agents}")
            unset(result)
            foreach (agent IN LISTS _rocm_agents)
                if (NOT agent STREQUAL "gfx000")
                    list(APPEND result "${agent}")
                endif()
            endforeach()
            if(result)
                set(${VARIABLE} "${result}" PARENT_SCOPE)
            endif()
        endif()
    endif()
endfunction()
