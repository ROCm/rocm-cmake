.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmanalyzers:

****************************************************
ROCMAnalyzers
****************************************************

This creates an ``analyze`` target which can run all analysis for a project.

Commands
--------

.. cmake:command:: rocm_mark_as_analyzer

.. code-block:: cmake

    rocm_mark_as_analyzer(<target>)

Marks a target to be included with the ``analyze`` target.

Variables
---------

.. cmake:variable:: ROCM_ENABLE_GH_ANNOTATIONS

Set this variable to ``ON`` so that analyzers will emit diagnostics in a format that GitHub can use to annotate pull requests.
