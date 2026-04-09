#####################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015-2026 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#####################################################################################

#[=======================================================================[
rocm_add_version_resource
-------------------------
Add a Windows PE version resource to a DLL or EXE target.

Usage:
  rocm_add_version_resource(
    TARGET      <target>
    DESCRIPTION <string>
    [PRODUCT_NAME  <string>]   # defaults to "${PROJECT_NAME}"
    [COMPANY_NAME  <string>]   # defaults to "Advanced Micro Devices, Inc."
    [COPYRIGHT     <string>]   # defaults to "Copyright (c) 2015-<year> Advanced Micro Devices, Inc. All rights reserved."
    [FILENAME      <string>]   # defaults to the target output name + .dll/.exe
  )

Example:
  rocm_add_version_resource(
    TARGET      mylib
    DESCRIPTION "My ROCm Library"
  )
#]=======================================================================]

function(rocm_add_version_resource)
    if(NOT WIN32)
        return()
    endif()

    set(options "")
    set(oneValueArgs TARGET DESCRIPTION PRODUCT_NAME COMPANY_NAME COPYRIGHT FILENAME)
    set(multiValueArgs "")
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "rocm_add_version_resource: TARGET is required")
    endif()
    if(NOT ARG_DESCRIPTION)
        message(FATAL_ERROR "rocm_add_version_resource: DESCRIPTION is required for ${ARG_TARGET}")
    endif()

    # Defaults
    if(NOT ARG_PRODUCT_NAME)
        set(ARG_PRODUCT_NAME "${PROJECT_NAME}")
    endif()
    if(NOT ARG_COMPANY_NAME)
        set(ARG_COMPANY_NAME "Advanced Micro Devices, Inc.")
    endif()
    if(NOT ARG_COPYRIGHT)
        string(TIMESTAMP _year "%Y")
        set(ARG_COPYRIGHT "Copyright (c) 2015-${_year} Advanced Micro Devices, Inc. All rights reserved.")
    endif()

    get_target_property(_type ${ARG_TARGET} TYPE)

    # Resolve output filename
    if(ARG_FILENAME)
        set(_filename "${ARG_FILENAME}")
    else()
        get_target_property(_output_name ${ARG_TARGET} OUTPUT_NAME)
        if(_output_name)
            set(_filename "${_output_name}")
        else()
            set(_filename "${ARG_TARGET}")
        endif()
        if(_type STREQUAL "SHARED_LIBRARY")
            set(_filename "${_filename}.dll")
        elseif(_type STREQUAL "EXECUTABLE")
            set(_filename "${_filename}.exe")
        endif()
    endif()

    if(_type STREQUAL "SHARED_LIBRARY")
        set(_filetype "VFT_DLL")
    else()
        set(_filetype "VFT_APP")
    endif()

    # Embed the .rc template and generate it
    set(_rc_content [=[
#include <winver.h>

#define VER_FILEVERSION          @_ver_major@,@_ver_minor@,@_ver_patch@,0
#define VER_FILEVERSION_STR      "@_ver_major@.@_ver_minor@.@_ver_patch@.0\0"
#define VER_PRODUCTVERSION       @_ver_major@,@_ver_minor@,@_ver_patch@,0
#define VER_PRODUCTVERSION_STR   "@PROJECT_VERSION@\0"

#ifndef VER_FILEDESCRIPTION_STR
#define VER_FILEDESCRIPTION_STR  "@_description@\0"
#endif

#ifndef VER_INTERNALNAME_STR
#define VER_INTERNALNAME_STR     "@ARG_TARGET@\0"
#endif

#ifndef VER_ORIGINALFILENAME_STR
#define VER_ORIGINALFILENAME_STR "@_filename@\0"
#endif

#ifndef VER_LEGALCOPYRIGHT_STR
#define VER_LEGALCOPYRIGHT_STR   "@_copyright@\0"
#endif

VS_VERSION_INFO VERSIONINFO
FILEVERSION     VER_FILEVERSION
PRODUCTVERSION  VER_PRODUCTVERSION
FILEFLAGSMASK   VS_FFI_FILEFLAGSMASK
#ifdef _DEBUG
FILEFLAGS       VS_FF_DEBUG
#else
FILEFLAGS       0
#endif
FILEOS          VOS_NT_WINDOWS32
FILETYPE        @_filetype@
FILESUBTYPE     VFT2_UNKNOWN
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904B0"
        BEGIN
            VALUE "CompanyName",      "@_company_name@\0"
            VALUE "FileDescription",  VER_FILEDESCRIPTION_STR
            VALUE "FileVersion",      VER_FILEVERSION_STR
            VALUE "InternalName",     VER_INTERNALNAME_STR
            VALUE "LegalCopyright",   VER_LEGALCOPYRIGHT_STR
            VALUE "OriginalFilename", VER_ORIGINALFILENAME_STR
            VALUE "ProductName",      "@_product_name@\0"
            VALUE "ProductVersion",   VER_PRODUCTVERSION_STR
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1200
    END
END
]=])

    # Write template to a .rc.in, then configure it
    set(_rc_in  "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}_version.rc.in")
    set(_rc_out "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}_version.rc")

    file(WRITE "${_rc_in}" "${_rc_content}")

    set(_ver_major "${PROJECT_VERSION_MAJOR}")
    set(_ver_minor "${PROJECT_VERSION_MINOR}")
    set(_ver_patch "${PROJECT_VERSION_PATCH}")
    set(_description  "${ARG_DESCRIPTION}")
    set(_product_name "${ARG_PRODUCT_NAME}")
    set(_company_name "${ARG_COMPANY_NAME}")
    set(_copyright    "${ARG_COPYRIGHT}")

    configure_file("${_rc_in}" "${_rc_out}" @ONLY)

    target_sources(${ARG_TARGET} PRIVATE "${_rc_out}")

    message(STATUS "Added version resource to ${ARG_TARGET}: ${ARG_DESCRIPTION}")
endfunction()
