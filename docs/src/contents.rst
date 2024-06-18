.. rocm-cmake documentation master file, created by
   sphinx-quickstart on Thu Sep 16 18:46:06 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.
.. highlight:: cmake

.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _contents:

****************************************************
Modules and functions
****************************************************

- :ref:`rocmanalyzers`
   + :any:`rocm_mark_as_analyzer`
   + :any:`ROCM_ENABLE_GH_ANNOTATIONS`
- :ref:`rocmchecktargetids`
   + :any:`rocm_check_target_ids`
- :ref:`rocmclangtidy`
   + :any:`rocm_enable_clang_tidy`
   + :any:`rocm_clang_tidy_check`
   + :any:`CLANG_TIDY_EXE`
   + :any:`CLANG_TIDY_CACHE`
   + :any:`CLANG_TIDY_CACHE_SIZE`
   + :any:`CLANG_TIDY_DEPEND_ON_TARGET`
- :ref:`rocmclients`
   + :any:`rocm_package_setup_client_component`
- :ref:`rocmcppcheck`
   + :any:`rocm_enable_cppcheck`
   + :any:`CPPCHECK_EXE`
   + :any:`CPPCHECK_BUILD_DIR`
- :ref:`rocmcreatepackage`
   + :any:`rocm_create_package`
   + :any:`rocm_package_add_rpm_dependencies`
   + :any:`rocm_package_add_deb_dependencies`
   + :any:`rocm_package_add_dependencies`
   + :any:`rocm_package_setup_component`
- :ref:`rocmdocs`
   + :any:`rocm_mark_as_doc`
   + :any:`rocm_clean_doc_output`
- :ref:`rocmdoxygendoc`
   + :any:`rocm_add_doxygen_doc`
   + :any:`DOXYGEN_EXECUTABLE`
   + :any:`DOT_EXECUTABLE`
- :ref:`rocminstallsymlinks`
   + :any:`rocm_install_symlink_subdir`
- :ref:`rocminstalltargets`
   + :any:`rocm_install`
   + :any:`rocm_install_targets`
   + :any:`rocm_export_targets`
- :ref:`rocmconfighelpers`
   + :any:`rocm_configure_package_config_file`
- :ref:`rocmsetupversion`
   + :any:`rocm_get_version`
   + :any:`rocm_setup_version`
- :ref:`rocmsphinxdoc`
   + :any:`rocm_add_doxygen_doc`
   + :any:`SPHINX_EXECUTABLE`
   + :any:`SPHINX_${BUILDER}_DIR`
- :ref:`rocmtest`
   + :any:`rocm_enable_test_package`
   + :any:`rocm_add_test`
   + :any:`rocm_add_test_executable`
   + :any:`rocm_test_header`
   + :any:`rocm_test_headers`
   + :any:`rocm_install_test`
   + :any:`rocm_mark_as_test`
   + :any:`rocm_link_test_dependencies`
   + :any:`rocm_test_link_libraries`
   + :any:`CTEST_PARALLEL_LEVEL`
   + :any:`CTEST_TIMEOUT`
   + :any:`ROCM_TEST_GDB`
- :ref:`rocmutilities`
   + :any:`rocm_join_if_set`
   + :any:`rocm_defer`
   + :any:`rocm_find_program_version`

Index and tables
================

* :ref:`genindex`
* :ref:`search`