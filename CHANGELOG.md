# Change Log for rocm-cmake

## [0.7.0]
### Added
- Component packaging functionality:
    - `rocm_package_setup_component` sets up a component for packaging, with the given name and values for the component and associated package.

        - The variable `ROCM_PACKAGE_COMPONENTS` stores a list of the components which have been set up with `rocm_package_setup_component`.
    - `rocm_package_add_rpm_dependencies` adds any number of dependencies to the RPM package for an optional specified component, including version checks (e.g. `foo >= 1.0`)
    - `rocm_package_add_deb_dependencies` adds any number of dependencies to the DEB package for an optional specified component, including version checks (e.g. `foo >= 1.0`)
        - Note that this version format matches RPM, it is reformatted to the Debian package format. This is to reduce code duplication.
    - `rocm_package_add_dependencies` is a convenience wrapper which calls both `rocm_add_rpm_dependencies` and `rocm_add_deb_dependencies` to add any number of dependencies to both packages for an optional specified component.
- Client packaging functions:
    - `rocm_package_setup_client_component` is a convenience wrapper which adds the library as a runtime dependency if shared libraries were built, and sets the parent of the client package to `clients`.
- Utility functions:
    - `rocm_join_if_set` joins any number of non-empty strings to the end of a given variable interspersed with a specified glue string, setting that variable if it was previously empty
    - `rocm_find_program_version` checks to see if the given command is available, and if it is available that the version matches some criteria. The detected version is returned in `<output_variable>`, and whether it matches all given criteria in `<output_variable>_OK`.
        - `<output_variable>` defaults to `<program>_VERSION` if not specified.
### Changed
- If `ROCM_PACKAGE_COMPONENTS` is set (either manually or by `rocm_package_setup_component`), then the components listed in `ROCM_PACKAGE_COMPONENTS` will be built as separate packages.
- `rocm_read_os_release` and `rocm_set_os_id` moved to the utilities file. As this file is included in `ROCMCreatePackage.cmake`, this change is backwards compatible.
- `rocm_install_symlink_subdir` now accepts a `COMPONENT` argument, which controls the component that the symlinks are installed into, and a `NAME_PREFIX`, which adds a prefix to the name of each symlink generated.

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
        - If provided with the `HEADER_ONLY` option (accepting no arguments), then only the devel package will be generated. The devel package will also have the "Provides" field populated with the name/version of the runtime package for backwards compatibility. This provides field is introduced as a deprecated feature, and will be removed in a future release.
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

