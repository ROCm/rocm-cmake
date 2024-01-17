# ######################################################################################################################
# Copyright (C) 2023 Advanced Micro Devices, Inc.
# ######################################################################################################################

install_dir(${TEST_DIR}/docsphinx TARGETS doc install)
test_expect_installed_file(
    share/doc/useful/html/index.html
    share/doc/useful/html/reference.html)
