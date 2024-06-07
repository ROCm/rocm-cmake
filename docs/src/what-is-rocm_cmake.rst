.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _what-is-cmake:

****************************************************
What is ROCm CMake
****************************************************

The ROCm CMake build tools are primarily used when building a library, and
as such are not runtime dependencies for any generated libraries, packages,
or executables.

The tools can be included into a CMake project by running:

.. code-block:: shell

   find_package(ROCmCMakeBuildTools)
   # or
   find_package(ROCM) # deprecated, but included for backwards compatibility

Once the tools have been included in this manner, individual files may be
included by running ``include(<file_name>)``. The file names, the
functions, variables, and macros accessible using each file are described in 
this documentation.
