# On cmake 3.19+ rocm_defer must run the call in the scope that scheduled it,
# so the deferred call should see this subdirectory as its current source dir.
function(rocm_defer_check_scope)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19.0" AND NOT CMAKE_CURRENT_SOURCE_DIR MATCHES "/sub$")
        message(FATAL_ERROR "rocm_defer ran in '${CMAKE_CURRENT_SOURCE_DIR}', expected the sub directory")
    endif()
endfunction()

rocm_defer(rocm_defer_check_scope)
