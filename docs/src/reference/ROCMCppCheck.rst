ROCMCppCheck
============

Commands
--------

.. cmake:command:: rocm_enable_cppcheck

.. code-block:: cmake

    rocm_enable_cppcheck(
        [CHECKS <checks>...]
        [SUPPRESS <suppresions>...]
        [DEFINE <defines>...]
        [UNDEFINE <undefines>...]
        [INCLUDE <include-paths>...]
        [SOURCES <sources>...]
        [ADDONS <addons>...]
        [RULE_FILE <path-to-rule-file>]
        [FORCE]
        [INCONCLUSIVE]
    )

Enable checks for cppcheck.

Variables
---------

.. cmake:variable:: CPPCHECK_EXE

This cached variable can be used to set which ``cppcheck`` executable to use. By default it will search for ``cppcheck`` on the system.

.. cmake:variable:: CPPCHECK_BUILD_DIR

Sets the path to use for cppcheck's build directory where it caches the analysis. By default, this is set the ``cppcheck-build`` under cmake's build directory.

