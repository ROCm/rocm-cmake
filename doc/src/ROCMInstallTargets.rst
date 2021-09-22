ROCMInstallTargets
==================

Commands
--------

.. cmake:command:: rocm_install

.. code-block:: cmake

    rocm_install(TARGETS <target>... [...])
    rocm_install({FILES | PROGRAMS} <file>... [...])
    rocm_install(DIRECTORY <dir>... [...])
    rocm_install(SCRIPT <file> [...])
    rocm_install(CODE <code> [...])
    rocm_install(EXPORT <export-name> [...])

Wraps installers to install to the correct component (devel or runtime) unless COMPONENT is specified. The TARGETS signature wraps ``rocm_install_targets``, all other signatures wrap ``install``.

.. cmake:command:: rocm_install_targets

.. code-block:: cmake

    rocm_install_targets(
        TARGETS <target>...
        [PREFIX <path>]
        [EXPORT <export-file>]
        [INCLUDE <directory>...]
        [COMPONENT <component>]
    )

Install targets into the appropriate directory. Unless COMPONENT is specified, libraries will be installed to the base package and namelinked in the ``devel`` package, and everything else will be installed to the ``devel`` package.

.. cmake:command:: rocm_export_targets

.. code-block:: cmake

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

Export the installed targets so they can be consumed with ``find_package``.

