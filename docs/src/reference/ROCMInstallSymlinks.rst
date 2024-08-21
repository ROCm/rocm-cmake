.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocminstallsymlinks:

****************************************************
ROCMInstallSymlinks
****************************************************

Commands
--------

.. cmake:command:: rocm_install_symlink_subdir

.. code-block:: cmake

    rocm_install_symlink_subdir(<subdir> [<component>])

Install symlinks which point into the ``subdir`` directory to the component `component`, or to the runtime and development components otherwise.

