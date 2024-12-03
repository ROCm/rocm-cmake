.. rocm-cmake documentation master file, created by
   sphinx-quickstart on Thu Sep 16 18:46:06 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.
.. highlight:: cmake

.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocm-cmake:

****************************************************
ROCm CMake build tools
****************************************************

ROCm CMake build tools (also known as "rocm-cmake") is a collection of functions 
that unify and simplify the CMake code of ROCm components, as well as ensuring 
consistency across these different components. The ROCm CMake build tools are used 
when building and developing many AMD ROCm libraries, but are not runtime dependencies 
for any libraries, packages or executables.

.. important::
   ROCm CMake tools are not required when building or compiling an application that uses ROCm or HIP components. 

The build tools can be included into a CMake project by running:

.. code-block:: shell

   find_package(ROCmCMakeBuildTools)
   # or
   find_package(ROCM) # deprecated, but included for backwards compatibility

Once the tools have been included in this manner, individual files may be
included by running ``include(<file_name>)``. The file names, the
functions, variables, and macros accessible using each file are described in 
this documentation.

You can access the build tools on the `ROCm CMake GitHub repository <https://github.com/ROCm/rocm-cmake>`_.
For a complete listing of the features of ROCm CMake refer to :ref:`contents`. 

To contribute to the documentation, refer to
`Contributing to ROCm <https://rocm.docs.amd.com/en/latest/contribute/contributing.html>`_.

You can find licensing information on the
`Licensing <https://rocm.docs.amd.com/en/latest/about/license.html>`_ page.
