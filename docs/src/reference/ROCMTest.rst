.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmtest:

****************************************************
ROCMTest
****************************************************

This adds a ``check`` target to build and run the tests using CTest. A ``tests`` target can be used to just build the tests. All the tests are then packaged in the test component. 

Commands
--------

.. cmake:command:: rocm_enable_test_package

.. code-block:: cmake

    rocm_enable_test_package(<name>)

Enable the test package. This must be called before ``rocm_create_package`` in the same directory. The ``<name>`` specifies the name of the directory to install the tests to.

.. cmake:command:: rocm_add_test

.. code-block:: cmake

    rocm_add_test(NAME <name> COMMAND <command> [<arg>...]
        [CONFIGURATIONS <config>...]
        [COMMAND_EXPAND_LISTS]
    )

Add test command to CTest and to test package.

.. cmake:command:: rocm_add_test_executable

.. code-block:: cmake

    rocm_add_test_executable(<name> <sources>...)

Adds an executable to be built and ran for tests. The executable will link in the dependencies specified with ``rocm_test_link_libraries`` or ``rocm_test_include_directories``. It will also be installed with the test component. The name of the test will be the same as the name of the executable.

.. cmake:command:: rocm_test_header

.. code-block:: cmake

    rocm_test_header(<test-name> <header-include>)

This will add a test for checking a header can be included standalone and that there is no ODR issues in the header.

.. cmake:command:: rocm_test_headers

.. code-block:: cmake

    rocm_test_headers(
        PREFIX <prefix>
        HEADERS <header-paths>
        DEPENDS <targets>...
    )

This will test multiple headers at once. The ``PREFIX`` will specifiy any prefix to the included file needed. THe ``HEADERS`` is a list of headers to test for. This can also include globbing. For each file, the ``PREFIX`` and base name will be used for the include. The ``DEPENDS`` can list targets to link in for the test.

.. cmake:command:: rocm_install_test

.. code-block:: cmake

    rocm_install_test(
        [TARGETS <targets>...]
        [FILES <files>...]
        [DESTINATION <path>]
    )

Install the target or file into the test directory. The ``DESTINATION`` can be specified for ``FILES`` but is relative to the test installation directory.

.. cmake:command:: rocm_mark_as_test

.. code-block:: cmake

    rocm_mark_as_test(<targets>...)

This will include the target as part of the ``tests`` target.

.. cmake:command:: rocm_link_test_dependencies

.. code-block:: cmake

    rocm_link_test_dependencies(<targets>...)

This will add test dependencies specified with ``rocm_test_link_libraries`` or ``rocm_test_include_directories``.

.. cmake:command:: rocm_test_link_libraries

.. code-block:: cmake

    rocm_test_link_libraries(<targets>...)

Targets to link to test executables.

Variables
---------

.. cmake:variable:: CTEST_PARALLEL_LEVEL

The parallel level used for ``check`` target to run the tests. The default is the number of cores.

.. cmake:variable:: CTEST_TIMEOUT

The timeout used for ``check`` target to run the tests. The default is 5000 seconds.

.. cmake:variable:: ROCM_TEST_GDB

Use gdb to printout a stacktrace when a test fails. This is either set to ``On`` or ``Off``.

