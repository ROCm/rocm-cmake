ROCMSphinxDoc
=============

Commands
--------

.. cmake:command:: rocm_add_doxygen_doc

.. code-block:: cmake

    rocm_add_sphinx_doc(
        SRC_DIR
        [BUILDER <sphinx-builder>]
        [OUTPUT_DIR <output-directory>]
        [DEPENDS <doc-targets>]
        [VARS <sphinx-variables>...]
        [TEMPLATE_VARS <sphinx-variables>...]
    )

This will create a ``sphinx-${BUILDER}`` which will generate documentation using sphinx. THe ``SRC_DIR`` should be the directory that contains the ``conf.py`` file.

Variables
---------

.. cmake:variable:: SPHINX_EXECUTABLE

This cached variable can be used to set which ``sphinx-build`` executable to use. By default it will search for ``sphinx-build`` on the system.

.. cmake:variable:: SPHINX_${BUILDER}_DIR

This is the directory where the documentation will be built. By default, it will use the ``OUTPUT_DIR`` passed to ``rocm_add_sphinx_doc`` otherwise it will be set to ``sphinx/${BUILDER}`` directory in the cmake build directory.
