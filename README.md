Rocm cmake modules
==================

ROCM cmake modules provides cmake modules for common build tasks needed for the ROCM software stack. To install from source, just run:

```
mkdir build
cd build
cmake ..
cmake --build . --target install
```

ROCMCreatePackage
=================

rocm_create_package
-------------------

    rocm_create_package(
        NAME <name>
        [DESCRIPTION <description>]
        [SECTION <section>]
        [MAINTAINER <maintainer>]
        [LDCONFIG_DIR <lib-directory>]
        [PREFIX <path>]
        [LDCONFIG]
        [HEADER_ONLY]
    )

Sets up CPack packaging. If the `devel` component is used, or if any components are set up using `rocm_setup_client_component`, these packages will be configured as well.

ROCMInstallSymlinks
===================

rocm_install_symlink_subdir
---------------------------

    rocm_install_symlink_subdir(subdir)

Install symlinks which point into the `subdir` directory.

ROCMInstallTargets
==================

rocm_install
------------

    rocm_install(TARGETS <target>... [...])
    rocm_install({FILES | PROGRAMS} <file>... [...])
    rocm_install(DIRECTORY <dir>... [...])
    rocm_install(SCRIPT <file> [...])
    rocm_install(CODE <code> [...])
    rocm_install(EXPORT <export-name> [...])

Wraps installers to install to the correct component (devel or runtime) unless COMPONENT is specified. The TARGETS signature wraps `rocm_install_targets`, all other signatures wrap `install`.

rocm_install_targets
--------------------

    rocm_install_targets(
        TARGETS <target>...
        [PREFIX <path>]
        [EXPORT <export-file>]
        [INCLUDE <directory>...]
        [COMPONENT <component>]
    )

Install targets into the appropriate directory. Unless COMPONENT is specified, libraries will be installed to the base package and namelinked in the `devel` package, and everything else will be installed to the `devel` package.

rocm_export_targets
-------------------

    rocm_export_targets(
        [NAMESPACE <namespace>]
        [EXPORT <export>]
        [INCLUDE <cmake-file>...]
        [NAME <name>]
        [COMPATIBILITY <compatibility>]
        [PREFIX <prefix>]
        [TARGETS <targets>...]
        [DEPENDS [PACKAGE <package-name>]...]
        [STATIC_DEPENDS [PACKAGE <package-name>]...]
    )

Export the installed targets so they can be consumed with `find_package`.

ROCMPackageConfigHelpers
========================

rocm_configure_package_config_file
----------------------------------

    rocm_configure_package_config_file(<input> <output>
        INSTALL_DESTINATION <path>
        [PATH_VARS <var>...]
        [PREFIX <path>]
    )

Configure the the config file used found be `find_package`.

ROCMSetupVersion
================

rocm_get_version
----------------

    rocm_get_version(<output-variable>
        [VERSION <version>]
        [DIRECTORY <path>]
    )

Get the version of directory using git tags if possible.

rocm_setup_version
------------------

    rocm_setup_version(
        VERSION <version>
        [NO_GIT_TAG_VERSION]
        [PARENT <commit>]
    )

Setup the version for the project. This will try to use git tag to set the version if possible unless `NO_GIT_TAG_VERSION` is passed. The `PARENT` argument can be used to set the commit to start the count of number of commits to the current revision.

ROCMCheckTargetIds
==================

rocm_check_target_ids
---------------------

    rocm_check_target_ids(<output-variable>
        TARGETS <target-id>...
    )

Returns the subset of HIP [target-ids](https://clang.llvm.org/docs/ClangOffloadBundler.html#target-id) supported by the current CXX compiler.

ROCMClients
===========

rocm_setup_client_component
---------------------------

    rocm_setup_client_component(<component_name>
        [PACKAGE_NAME <package_name>]
        [LIBRARY_NAME <library_name>]
        [DEPENDS 
            [COMMON <common-dep>...]
            [DEBIAN <debian-dep>...]
            [RPM <rpm-dep>...]]
    )

Sets up the named component to generate a package named `<library_name>-<package_name>`. `<library_name>` defaults to `PROJECT_NAME`, and `<package_name>` defaults to `<component_name>`. The dependencies should all be listed in RPM style, e.g. `foo >= 1.0`.

rocm_install_client_with_symlink
--------------------------------

    rocm_install_client_with_symlink(
        <target> <component>
        [EXE_DESTINATION <exe_dest>]
        [SYMLINK_DESTINATION <symlink_dest>]
    )

Installs the named target to the named component in the directory `${CMAKE_INSTALL_PREFIX}/<exe_dest>`, and installs a symbolic link to that target in `${CMAKE_INSTALL_PREFIX}/<symlink_dest>`. On Windows, a copy of the target is installed instead of a symbolic link.

ROCMUtilities
=============

rocm_join_if_set
----------------

    rocm_join_if_set(<glue> <inout_variable> <inputs>...)

Joins the `<inputs>` together with the `<glue>` string, then is appended to `<inout_variable>` with a `<glue>` string between if `<inout_variable>` is set and non-empty, otherwise `<inout_variable>` is set to this `<glue>`d string of `<inputs>`.

rocm_add_rpm_dependencies
-------------------------

    rocm_add_rpm_dependencies(<rpm-dep>...
        [COMPONENT <component>]
    )

Adds the listed `<rpm-dep>`s to the RPM package for the associated `<component>`, or for the package overall if a `<component>` is not given.

rocm_add_deb_dependencies
-------------------------

    rocm_add_deb_dependencies(<deb-dep>...
        [COMPONENT <component>]
    )

Adds the listed `<deb-dep>`s to the DEB package for the associated `<component>`, or for the package overall if a `<component>` is not given. NOTE: this dependency should be given in the RPM style (e.g. `foo >= 1.0`), NOT in the Debian style (e.g. `foo (>= 1.0)`).

rocm_add_dependencies
---------------------

    rocm_add_dependencies(<common-dep>...
        [COMPONENT <component>]
    )

Adds the listed `<common-dep>`s to both the DEB and RPM packages for the associated `<component>`, or for the package overall if a `<component>` is not given. NOTE: this dependency should be given in the RPM style (e.g. `foo >= 1.0`), NOT in the Debian style (e.g. `foo (>= 1.0)`)
