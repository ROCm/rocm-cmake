# Change Log for rocm-cmake

## [0.6.0]
### Added
- `rocm_set_devel_component` can be used to set the component used for devel packaging (defaults to devel). 
- `rocm_install_targets` can now install to a specific component using COMPONENT argument.
- `rocm_install` is a wrapper on `install`:
    - If the installation mode is TARGETS, call `rocm_install_targets` with the same arguments.
    - If COMPONENT is not specified but the devel component has been set, install to the devel component using `install` with all other arguments unchanged.
    - Otherwise, call `install` with the same arguments.
### Changed
- If the devel component has been set:
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

