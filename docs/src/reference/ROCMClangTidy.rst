.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmclangtidy:

****************************************************
ROCMClangTidy
****************************************************

Commands
--------

.. cmake:command:: rocm_enable_clang_tidy

.. code-block:: cmake

    rocm_enable_clang_tidy(
        [CHECKS <tidy-checks>...]
        [ERRORS <tidy-checks>...]
        [EXTRA_ARGS <args>...]
        [CLANG_ARGS <args>...]
        [HEADER_FILTER <filter>]
        [ALL]
        [ANALYZE_TEMPORARY_DTORS]
        [ENABLE_ALPHA_CHECKS]
    )

Enable checks for clang tidy.

.. cmake:command:: rocm_clang_tidy_check

.. code-block:: cmake

    rocm_clang_tidy_check(TARGET)

Check the sources from target with clang tidy.

Variables
---------

.. cmake:variable:: CLANG_TIDY_EXE

This cached variable can be used to set which ``clang-tidy`` executable to use. By default it will search for ``clang-tidy`` on the system while preferring the ``clang-tidy`` found in the same directory as ``CMAKE_CXX_COMPILER``.

.. cmake:variable:: CLANG_TIDY_CACHE

This is location of the ``clang-tidy`` cache. By default, this is stored in the build directory under ``tidy-cache``.

.. cmake:variable:: CLANG_TIDY_CACHE_SIZE

This sets the size of the cache. If set to ``0`` it will disable the cache. By default, it will cache 10 runs when using the Makefile generators. When using other generators it is disabled since it is not supported.

.. cmake:variable:: CLANG_TIDY_DEPEND_ON_TARGET

When set to ``On`` it will build the target first before running ``clang-tidy``. By default, this is set to ``On``.

.. cmake:variable:: CLANG_TIDY_USE_COLOR

When set to ``On`` then ``clang-tidy`` will output diagnostics in color. By default, this is set to ``On``. It is disabled if ``ROCM_ENABLE_GH_ANNOTATIONS`` is enabled.

Fixits
------

All fixits are saved in the build directory under ``fixits/``. All fixits found during analysis can be applied by running ``clang-apply-replacements fixits/``.

