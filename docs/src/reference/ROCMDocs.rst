.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmdocs:

****************************************************
ROCMDocs
****************************************************

This creates a ``doc`` target which can run all documentation generation for the project.

Commands
--------

.. cmake:command:: rocm_mark_as_doc

.. code-block:: cmake

    rocm_mark_as_doc(<target>)

Marks a target to be included with the ``doc`` target.

.. cmake:command:: rocm_clean_doc_output

.. code-block:: cmake

    rocm_clean_doc_output(DIR)

Output directory of documentation that should be removed when calling ``make clean``.

