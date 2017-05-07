
include(WriteBasicConfigVersionFile)

macro(write_basic_package_version_file)
  write_basic_config_version_file(${ARGN})
endmacro()

function(rocm_configure_package_config_file _inputFile _outputFile)
  set(options NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO)
  set(oneValueArgs INSTALL_DESTINATION INSTALL_PREFIX)
  set(multiValueArgs PATH_VARS )

  cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}"  ${ARGN})

  if(PARSE_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to rocm_configure_package_config_file(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
  endif()

  if(NOT PARSE_INSTALL_DESTINATION)
    message(FATAL_ERROR "No INSTALL_DESTINATION given to rocm_configure_package_config_file()")
  endif()

  if(DEFINED PARSE_INSTALL_PREFIX)
    if(IS_ABSOLUTE "${PARSE_INSTALL_PREFIX}")
      set(installPrefix "${PARSE_INSTALL_PREFIX}")
    else()
      message(FATAL_ERROR "INSTALL_PREFIX must be an absolute path")
    endif()
  elseif(IS_ABSOLUTE "${CMAKE_INSTALL_PREFIX}")
    set(installPrefix "${CMAKE_INSTALL_PREFIX}")
  else()
    get_filename_component(installPrefix "${CMAKE_INSTALL_PREFIX}" ABSOLUTE)
  endif()

  if(IS_ABSOLUTE "${PARSE_INSTALL_DESTINATION}")
    set(absInstallDir "${PARSE_INSTALL_DESTINATION}")
  else()
    set(absInstallDir "${installPrefix}/${PARSE_INSTALL_DESTINATION}")
  endif()

  file(RELATIVE_PATH PACKAGE_RELATIVE_PATH "${absInstallDir}" "${installPrefix}" )

  foreach(var ${PARSE_PATH_VARS})
    if(NOT DEFINED ${var})
      message(FATAL_ERROR "Variable ${var} does not exist")
    else()
      if(IS_ABSOLUTE "${${var}}")
        string(REPLACE "${installPrefix}" "\${PACKAGE_PREFIX_DIR}"
                        PACKAGE_${var} "${${var}}")
      else()
        set(PACKAGE_${var} "\${PACKAGE_PREFIX_DIR}/${${var}}")
      endif()
    endif()
  endforeach()

  get_filename_component(inputFileName "${_inputFile}" NAME)

  set(PACKAGE_INIT "
####### Expanded from @PACKAGE_INIT@ by rocm_configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was ${inputFileName}                            ########

get_filename_component(_CMAKE_CURRENT_LIST_FILE_REAL \"\${CMAKE_CURRENT_LIST_FILE}\" REALPATH)
get_filename_component(_CMAKE_CURRENT_LIST_DIR_REAL \"\${_CMAKE_CURRENT_LIST_FILE_REAL}\" DIRECTORY)
get_filename_component(PACKAGE_PREFIX_DIR \"\${_CMAKE_CURRENT_LIST_DIR_REAL}/${PACKAGE_RELATIVE_PATH}\" ABSOLUTE)
")

  if("${absInstallDir}" MATCHES "^(/usr)?/lib(64)?/.+")
    # Handle "/usr move" symlinks created by some Linux distros.
    string(APPEND PACKAGE_INIT "
# Use original install prefix when loaded through a \"/usr move\"
# cross-prefix symbolic link such as /lib -> /usr/lib.
get_filename_component(_realCurr \"\${CMAKE_CURRENT_LIST_DIR}\" REALPATH)
get_filename_component(_realOrig \"${absInstallDir}\" REALPATH)
if(_realCurr STREQUAL _realOrig)
  set(PACKAGE_PREFIX_DIR \"${installPrefix}\")
endif()
unset(_realOrig)
unset(_realCurr)
")
  endif()

  if(NOT PARSE_NO_SET_AND_CHECK_MACRO)
    string(APPEND PACKAGE_INIT "
macro(set_and_check _var _file)
  set(\${_var} \"\${_file}\")
  if(NOT EXISTS \"\${_file}\")
    message(FATAL_ERROR \"File or directory \${_file} referenced by variable \${_var} does not exist !\")
  endif()
endmacro()

include(CMakeFindDependencyMacro OPTIONAL RESULT_VARIABLE _CMakeFindDependencyMacro_FOUND)
if (NOT _CMakeFindDependencyMacro_FOUND)
    macro(find_dependency dep)
        if (NOT \${dep}_FOUND)
            set(rocm_fd_version)
            if (\${ARGC} GREATER 1)
                set(rocm_fd_version \${ARGV1})
            endif()
            set(rocm_fd_exact_arg)
            if(\${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION_EXACT)
                set(rocm_fd_exact_arg EXACT)
            endif()
            set(rocm_fd_quiet_arg)
            if(\${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
                set(rocm_fd_quiet_arg QUIET)
            endif()
            set(rocm_fd_required_arg)
            if(\${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
                set(rocm_fd_required_arg REQUIRED)
            endif()
            find_package(\${dep} \${rocm_fd_version}
                \${rocm_fd_exact_arg}
                \${rocm_fd_quiet_arg}
                \${rocm_fd_required_arg}
            )
            string(TOUPPER \${dep} cmake_dep_upper)
            if (NOT \${dep}_FOUND AND NOT \${cmake_dep_upper}_FOUND)
                set(\${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE \"\${CMAKE_FIND_PACKAGE_NAME} could not be found because dependency \${dep} could not be found.\")
                set(\${CMAKE_FIND_PACKAGE_NAME}_FOUND False)
                return()
            endif()
            set(rocm_fd_version)
            set(rocm_fd_required_arg)
            set(rocm_fd_quiet_arg)
            set(rocm_fd_exact_arg)
        endif()
    endmacro()
endif()

")
  endif()


  if(NOT PARSE_NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    string(APPEND PACKAGE_INIT "
macro(check_required_components _NAME)
  foreach(comp \${\${_NAME}_FIND_COMPONENTS})
    if(NOT \${_NAME}_\${comp}_FOUND)
      if(\${_NAME}_FIND_REQUIRED_\${comp})
        set(\${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()
")
  endif()

  string(APPEND PACKAGE_INIT "
####################################################################################")

  configure_file("${_inputFile}" "${_outputFile}" @ONLY)

endfunction()
