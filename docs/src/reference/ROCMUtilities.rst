.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmutilities:

****************************************************
ROCMUtilities
****************************************************

Commands
--------

.. cmake:command:: rocm_join_if_set

.. code-block:: cmake

    rocm_join_if_set(<glue> <inout_var> [<input>...])

Join all the ``<input>`` arguments together using the ``<glue>`` string. If ``<inout_var>`` names a variable with a set value, join that string at the beginning, also using the ``<glue>`` string, and always store the result in ``<inout_var>``.

.. cmake:command:: rocm_defer

.. code-block:: cmake

    rocm_defer(<command>)

Call ``<command>`` at the end of configure.

.. cmake:command:: rocm_find_program_version

.. code-block:: cmake

    rocm_find_program_version(
        <PROGRAM>
        [QUIET] [REQUIRED]
        [GREATER <version>]
        [GREATER_EQUAL <version>]
        [LESS <version>]
        [LESS_EQUAL <version>]
        [EQUAL <version>]
        [OUTPUT_VARIABLE <out-var>]
    )

Determine the presence and installed version of a program that accepts the ``--version`` option.
Optionally check the version using any of the comparison operators (each comparison operator may only be specified once).
If ``out-var`` is not specified, it defaults to ``<PROGRAM>_VERSION``.
If the program is found, ``<out-var>`` is set to the version detected. If that version satisfies all version constraints, the variable ``<out-var>_OK`` is set to ``TRUE``, otherwise it is set to ``FALSE``.
