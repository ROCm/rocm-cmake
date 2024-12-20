.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmclients:

****************************************************
ROCMClients
****************************************************

Commands
--------

.. cmake:command:: rocm_package_setup_client_component

.. code-block:: cmake

    rocm_package_setup_client_component(
        <component>
        [PACKAGE_NAME <package-name>]
        [LIBRARY_NAME <library-name>]
        [DEPENDS
            [COMMON <common-dependencies>...]
            [RPM <rpm-dependencies>...]
            [DEB <deb-dependencies>...]
            [COMPONENT <component-dependencies>...]
        ]
    )

Setup a client component for packaging. See ``rocm_package_setup_component``.
