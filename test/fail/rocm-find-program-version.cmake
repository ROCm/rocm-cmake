use_rocm_cmake()
include(ROCMUtilities)

rocm_find_program_version(
    foobar
    REQUIRED
)
