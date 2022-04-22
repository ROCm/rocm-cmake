ROCMHeaderWrapper
=================

Commands
--------

.. cmake::command:: rocm_wrap_header_file

.. code-block:: cmake

    rocm_wrap_header_file(
        [HEADERS] <header-file> [<header-file>...]
        [HEADER_LOCATION <header-location>]
        [INCLUDE_LOCATION <include-location>]
        [GUARDS <guard>...]
        [WRAPPER_LOCATIONS <wrapper-location>...]
        [OUTPUT_LOCATIONS <output-location>...]
    )

Create a C/C++ wrapper file for each specified header file. The wrapper is simply a C/C++ header
that emits a deprecation warning before including its corresponding header. The warning can be
turned off by defining ``ROCM_NO_WRAPPER_HEADER_WARNING``.

Any relative header or wrapper locations are relative to ``${CPACK_PACKAGING_INSTALL_PREFIX}`` if it is set,
or to ``${CMAKE_INSTALL_PREFIX}`` otherwise (i.e. the install directory).
Any relative output locations are relative to ``${PROJECT_BINARY_DIR}`` (i.e. the build directory)

Each ``<header-file>`` is presumed to be installed to ``${CMAKE_INSTALL_PREFIX}/<header-location>/<header-file>``.
If it is not specified, ``<header-location>`` defaults to ``include/${CMAKE_PROJECT_NAME}`` (e.g. ``include/rocblas``).

The ``<include-location>`` parameter specifies the presumed compiler include directory, to correctly calculate suggested include directives.

Guards
^^^^^^^^^^
A guard item consists of the guard string ``<guard>``, a wrapper location ``<wrapper-location>``, and an output location ``<output-location>``.
You may specify any number of guard strings, wrapper locations and output locations.
Guard items will be created from the arguments, and if necessary the following defaults will be used:
 - Default ``<guard>``: ``WRAPPER``
 - Default ``<wrapper-location>``: ``${CMAKE_PROJECT_NAME}/include``
 - Default ``<output-location>``: The associated ``<wrapper-location>``
If no guard items are specified, one will be created using all of the default values.
Each guard item will create a wrapper file at ``${PROJECT_BINARY_DIR}/<output-location>/<header-file>`` for each header file.
This wrapper file will have the include guard ``ROCM_<guard>_<item-path>``, where ``<item-path>`` is ``<header-file>`` with each ``/`` and ``.`` replaced with ``_``.
It assumes that it will be installed to ``${CMAKE_INSTALL_PREFIX}/<wrapper-location>/<header-file>``, and will include a relative path that is correct if it is installed to that location.

For example, suppose the project name is ``rocexample`` and consider the following:

.. code-block:: cmake

    rocm_wrap_header_file(
        foo/bar.h
        HEADER_LOCATION include/rocexample
        GUARDS
            EXAMPLE
            EXAMPLE_INC
        WRAPPER_LOCATIONS
            rocexample # EXAMPLE
        OUTPUT_LOCATIONS
            wrapper/rocexample # EXAMPLE
    )

This will create two wrapper files.

The first wrapper file will be created at ``${PROJECT_BINARY_DIR}/wrapper/rocexample/foo/bar.h``.
Its include guard will be ``ROCM_EXAMPLE_FOO_BAR_H``, and it will include the file ``../../include/rocexample/foo/bar.h``
(which is the correct file when this wrapper is installed at ``${CMAKE_INSTALL_PREFIX}/rocexample/foo/bar.h``).

The second wrapper file uses the default locations, so it will be created at ``${PROJECT_BINARY_DIR}/rocexample/include/foo/bar.h``.
Its include guard will be ``ROCM_EXAMPLE_INC_FOO_BAR_H``, and it will include the file ``../../../include/rocexample/foo/bar.h``
(which is the correct file when this wrapper is installed at ``${CMAKE_INSTALL_PREFIX}/rocexample/include/foo/bar.h``)


.. cmake::command:: rocm_wrap_header_dir

.. code-block:: cmake

    rocm_wrap_header_dir(
        <include-directory>
        [HEADER_LOCATION <header-location>]
        [GUARDS <guard>...]
        [WRAPPER_LOCATIONS <wrapper-location>...]
        [OUTPUT_LOCATIONS <output-location>...]
        [PATTERNS <pattern>...]
    )

Create a C/C++ wrapper file for each header file in the given directory (or any subdirectory) matching at least one pattern.

Each file in the specified directory which matches a pattern will have a wrapper file created for it.
The ``<header-file>`` used in each call to ``rocm_wrap_header_file`` is the path to the header file relative to ``<include-directory>``.
