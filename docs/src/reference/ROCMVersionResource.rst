.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmVersionResource:

****************************************************
ROCMVersionResource
****************************************************

Commands
--------

.. cmake:command:: rocm_add_version_resource

.. code-block:: cmake

    rocm_add_version_resource(
        TARGET      <target>
        DESCRIPTION <string>
        [PRODUCT_NAME  <string>]
        [COMPANY_NAME  <string>]
        [COPYRIGHT     <string>]
        [FILENAME      <string>]
    )

Add a Windows PE version resource to a DLL or EXE target.

``TARGET``
  The target to add the version resource to.

``DESCRIPTION``
  A short description of the file (required).

``PRODUCT_NAME``
  The product name. Defaults to ``${PROJECT_NAME}``.

``COMPANY_NAME``
  The company name. Defaults to ``"Advanced Micro Devices, Inc."``.

``COPYRIGHT``
  The copyright string. Defaults to ``"Copyright (c) 2015-<year> Advanced Micro Devices, Inc. All rights reserved."``.

``FILENAME``
  The original filename. Defaults to the target output name with ``.dll`` or ``.exe`` extension.

Example
-------

.. code-block:: cmake

    rocm_add_version_resource(
        TARGET      mylib
        DESCRIPTION "My ROCm Library"
    )
