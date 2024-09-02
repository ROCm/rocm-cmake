.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmconfighelpers:

****************************************************
ROCMPackageConfigHelpers
****************************************************

Commands
--------

.. cmake:command:: rocm_configure_package_config_file

.. code-block:: cmake

    rocm_configure_package_config_file(<input> <output>
        INSTALL_DESTINATION <path>
        [PATH_VARS <var>...]
        [PREFIX <path>]
    )

Configure the config file used by ``find_package``.

