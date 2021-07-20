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
    )

Sets up CPack packaging.

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

Install targets into the appropriate directory. 

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
