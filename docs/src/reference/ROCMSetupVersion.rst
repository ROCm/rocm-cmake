.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmSetupVersion:

****************************************************
ROCMSetupVersion
****************************************************

Commands
--------

.. cmake:command:: rocm_get_version

.. code-block:: cmake

    rocm_get_version(<output-variable>
        [VERSION <version>]
        [DIRECTORY <path>]
    )

Get the version of directory using git tags if possible.

.. cmake:command:: rocm_setup_version

.. code-block:: cmake

    rocm_setup_version(
        VERSION <version>
        [NO_GIT_TAG_VERSION]
        [PARENT <commit>]
    )

Setup the version for the project. This will try to use git tag to set the version if possible unless ``NO_GIT_TAG_VERSION`` is passed. The ``PARENT`` argument can be used to set the commit to start the count of number of commits to the current revision.

.. cmake:command:: rocm_add_resource_version

.. code-block:: cmake

    rocm_add_version_resource(<target> <product_name> <product_description>)

Add a Windows PE version resource to a shared library, module library (DLL) or executable (EXE) target.

Example
-------

.. code-block: cmake

    rocm_add_version_resource(mylib "MyLib" "My ROCm Library")
