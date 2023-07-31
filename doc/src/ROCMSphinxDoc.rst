ROCMSphinxDoc
=============

Commands
--------

.. cmake:command:: rocm_add_sphinx_doc

.. code-block:: cmake

    rocm_add_sphinx_doc(
        SRC_DIR
        BUILDER <sphinx-builder>
        [OUTPUT_DIR <output-directory>]
        [DEPENDS <doc-targets>...]
        [VARS <sphinx-variables>...]
        [TEMPLATE_VARS <sphinx-variables>...]
        [USE_DOXYGEN]
    )

This will create a ``sphinx-${BUILDER}`` doc-type target which will generate
documentation using sphinx. The ``SRC_DIR`` should be the directory that
contains the ``conf.py`` file.

The options are:

``OUTPUT_DIR``
  The directory where build output will be written. By default, it's
  ``${CMAKE_CURRENT_BINARY_DIR}/sphinx/${BUILDER}``

``DEPENDS``
  Sets up target-level dependencies between ``sphinx-${BUILDER}`` and the
  user-provided list of targets.

``VARS``
  List of configuration values passed to Sphinx. List items will be passed as
  command-line args by prepending ``-D`` to each item.

``TEMPLATE_VARS``
  List of HTML template values passed to Sphinx. List items will be passed as
  command-line args by prepending ``-A`` to each item.

``USE_DOXYGEN``
  Flag denoting the use of Doxygen in the fashion rocm-docs-core expects it.

Variables
---------

.. cmake:variable:: SPHINX_EXECUTABLE

This cached variable can be used to set which ``sphinx-build`` executable to use. By default it will search for ``sphinx-build`` on the system. The ``SPHINX_DIR`` environmental variable is taken as a ``HINT`` while searching.

.. cmake:variable:: DOXYGEN_EXECUTABLE

This cached variable can be used to set which ``doxygen`` executable to use. By default it will search for ``doxygen`` on the system. The ``DOXYGEN_DIR`` environmental variable is taken as a ``HINT`` while searching.

.. cmake:variable:: SPHINX_${BUILDER}_DIR

This is the directory where the documentation will be built. By default, it will use the ``OUTPUT_DIR`` passed to ``rocm_add_sphinx_doc`` otherwise it will be set to ``sphinx/${BUILDER}`` directory in the cmake build directory.
