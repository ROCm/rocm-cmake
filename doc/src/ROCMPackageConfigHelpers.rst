ROCMPackageConfigHelpers
========================

Commands
--------

.. cmake:command:: rocm_configure_package_config_file

.. code-block:: cmake

    rocm_configure_package_config_file(<input> <output>
        INSTALL_DESTINATION <path>
        [PATH_VARS <var>...]
        [PREFIX <path>]
    )

Configure the the config file used found be ``find_package``.

