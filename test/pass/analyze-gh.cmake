# ######################################################################################################################
# Copyright (C) 2020 Advanced Micro Devices, Inc.
# ######################################################################################################################

if(WIN32)
install_dir(${TEST_DIR}/analyze)

install_dir(
    ${TEST_DIR}/analyze
    CMAKE_ARGS -DCLANG_TIDY_CACHE_SIZE=0 -DROCM_ENABLE_GH_ANNOTATIONS=On)

else()
    install_dir(${TEST_DIR}/analyze TARGETS analyze analyze)

    install_dir(
        ${TEST_DIR}/analyze
        CMAKE_ARGS -DCLANG_TIDY_CACHE_SIZE=0 -DROCM_ENABLE_GH_ANNOTATIONS=On
        TARGETS analyze analyze)
endif()
