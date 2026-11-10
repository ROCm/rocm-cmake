# ######################################################################################################################
# Copyright (C) 2026 Advanced Micro Devices, Inc.
# ######################################################################################################################

# The project defers a call that fails configuration if rocm_defer runs it in
# the wrong directory scope, so a clean configure is the assertion.
configure_dir(${TEST_DIR}/rocmdefer)
