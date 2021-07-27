# Change Log for rocm-cmake

## [0.6.0]
### Added
- The cache variable `ROCM_USE_DEV_COMPONENT` may be set to `OFF` to build with legacy behaviour.
    - On Windows, this variable defaults to `OFF`.
- `rocm_install_targets` can now install to a specific component using COMPONENT argument.
- `rocm_install` is a wrapper on `install`:
    - If the installation mode is TARGETS, call `rocm_install_targets` with the same arguments.
    - If `ROCM_USE_DEV_COMPONENT` is `OFF` or COMPONENT is specified, call `install` with the same arguments.
    - Otherwise, insert the correct arguments to install everything except libraries to the `devel` package, and install libraries to the base package with namelinks in the `devel` package.
### Changed
- If `ROCM_USE_DEV_COMPONENT` is `ON`:
    - `rocm_install_targets`:
        - Unless COMPONENT is specified, library targets will be installed to the default package and namelinked in the devel package.
        - Unless COMPONENT is specified, everything else (including any files/folders specified by INCLUDE) will be installed to the devel package.
        - If COMPONENT was specified in the call to `rocm_install_targets`, that component is used instead of the above behaviour.
    - `rocm_export_targets`:
        - All cmake files will be installed to the devel package.
    - `rocm_create_package`:
        - Package generation will be performed component-wise, and automatically include the devel component, even if the COMPONENTS argument was not provided.
- Corrects semantic versioning to SameMajorVersion compatibility (e.g. 0.6 is compatible if 0.5 is requested).
- Moved ROCMConfigVersion.cmake file to share/rocm/cmake directory for better compatibility with automatic installation.
- Correct CHANGELOG.md formatting

## [0.5.1]
### Added
- Add ROCMConfigVersion.cmake file so cmake can check the version
- Switched to semantic versioning

## [0.5]
### Added
- Change Log added and version number incremented

## [0.4]
Pre Change Log versions

