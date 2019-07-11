################################################################################
# Copyright (C) 2017 Advanced Micro Devices, Inc.
################################################################################


function(rocm_install_symlink_subdir SUBDIR CUSTOM_DIRECTORY)
    # TODO: Check if SUBDIR is relative path
    # Copy instead of symlink on windows
    if(CMAKE_HOST_WIN32)
        set(SYMLINK_CMD "file(COPY \${SRC} DESTINATION \${DEST_DIR})")
    else()
        set(SYMLINK_CMD "execute_process(COMMAND ln -sf \${SRC_REL} \${DEST})")
    endif()
    install(CODE "
        set(SUBDIR \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${SUBDIR})
        file(GLOB_RECURSE FILES RELATIVE \${SUBDIR} \${SUBDIR}/*)
        foreach(FILE \${FILES})
            set(SRC \${SUBDIR}/\${FILE})
            set(DEST \$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/$CUSTOM_DIRECTORY\${FILE})
            get_filename_component(DEST_DIR \${DEST} DIRECTORY)
            file(MAKE_DIRECTORY \${DEST_DIR})
            file(RELATIVE_PATH SRC_REL \${DEST_DIR} \${SRC})
            message(STATUS \"symlink: \${SRC_REL} -> \${DEST}\")
            ${SYMLINK_CMD}
        endforeach()
    ")
endfunction()

