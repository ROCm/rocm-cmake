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
consistency across these different components. ROCm CMake build tools are primarily 
used when building a library, and as such are not runtime dependencies for any generated 
libraries, packages, or executables.

The build tools can be included into a CMake project by running:

.. code-block:: shell

   find_package(ROCmCMakeBuildTools)
   # or
   find_package(ROCM) # deprecated, but included for backwards compatibility

Once the tools have been included in this manner, individual files may be
included by running ``include(<file_name>)``. The file names, the
functions, variables, and macros accessible using each file are described in 
this documentation.

You can access ROCm CMake on `GitHub repository <https://github.com/ROCm/rocm-cmake>`_.

The documentation is structured as follows:

.. grid:: 2
  :gutter: 3

  .. grid-item-card:: Installation

    * :ref:`rocminstalltargets`
    * :ref:`rocminstallsymlinks`
    * :ref:`rocmheaderwrapper`
    * :ref:`rocmcreatepackage`
    * :ref:`rocmclients`
    * :ref:`rocmconfighelpers`


  .. grid-item-card:: Basic functions

    * :ref:`rocmchecktargetids`
    * :ref:`rocmsetupversion`
    * :ref:`rocmanalyzers`

  .. grid-item-card:: Standard Tooling

    * :ref:`rocmclangtidy`
    * :ref:`rocmcppcheck`
    * :ref:`rocmtest`

  .. grid-item-card:: Documentation in CMake

    * :ref:`rocmdocs`
    * :ref:`rocmdoxygendoc`
    * :ref:`rocmsphinxdoc`

  .. grid-item-card:: Internal use

    * :ref:`rocmutilities`


For a complete listing of the ROCm CMake modules and functions refer to :ref:`contents`. 

To contribute to the documentation, refer to
`Contributing to ROCm <https://rocm.docs.amd.com/en/latest/contribute/contributing.html>`_.

You can find licensing information on the
`Licensing <https://rocm.docs.amd.com/en/latest/about/license.html>`_ page.
