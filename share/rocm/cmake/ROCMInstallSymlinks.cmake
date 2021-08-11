# ######################################################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
# ######################################################################################################################

function(rocm_install_symlink_subdir SUBDIR)
    set(options)
    set(oneValueArgs COMPONENT NAME_PREFIX)
    set(multipleValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    # TODO: Check if SUBDIR is relative path Copy instead of symlink on windows
    if(CMAKE_HOST_WIN32)
        set(SYMLINK_CMD "file(COPY \${SRC} DESTINATION \${DEST_DIR})")
    else()
        set(SYMLINK_CMD "execute_process(COMMAND ln -sf \${SRC_REL} \${DEST})")
    endif()

    set(INSTALL_CMD "
        set(SUBDIR \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${SUBDIR})
        file(GLOB_RECURSE FILES RELATIVE \${SUBDIR} \${SUBDIR}/*)
        foreach(FILE \${FILES})
            set(SRC \${SUBDIR}/\${FILE})
            set(DEST \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/\${FILE})
            get_filename_component(DEST_DIR \${DEST} DIRECTORY)
            get_filename_component(DEST_NAME \${DEST} NAME)
            set(DEST \${DEST_DIR}/${PARSE_NAME_PREFIX}\${DEST_NAME})
            file(MAKE_DIRECTORY \${DEST_DIR})
            file(RELATIVE_PATH SRC_REL \${DEST_DIR} \${SRC})
            message(STATUS \"symlink: \${SRC_REL} -> \${DEST}\")
            ${SYMLINK_CMD}
        endforeach()
    ")
    if(PARSE_COMPONENT)
        install(CODE "${INSTALL_CMD}" COMPONENT ${PARSE_COMPONENT})
    else()
        install(CODE "${INSTALL_CMD}")
        if(ROCM_USE_DEV_COMPONENT)
            rocm_install(CODE "${INSTALL_CMD}")
        endif()
    endif()
endfunction()
