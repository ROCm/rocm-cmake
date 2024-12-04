.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmdoxygendoc:

****************************************************
ROCMDoxygenDoc
****************************************************

Commands
--------

.. cmake:command:: rocm_add_doxygen_doc

.. code-block:: cmake

    rocm_add_doxygen_doc(
        [DEPENDS <doc-targets>]
        [<doxygen-setting>...]
    )

This will generate a doxygen file and then create a ``doxygen`` target that will run doxygen. Doxygen settings can be passed directly to the ``rocm_add_doxygen_doc``. Settings for doxygen can be found `here <https://www.doxygen.nl/manual/config.html>`_.

Variables
---------

.. cmake:variable:: DOXYGEN_EXECUTABLE

This cached variable can be used to set which ``doxygen`` executable to use. By default it will search for ``doxygen`` on the system.

.. cmake:variable:: DOT_EXECUTABLE

This cached variable can be used to set which ``dot`` executable to use. By default it will search for ``dot`` on the system. If ``dot`` is found then its path will be set in the generated doxygen file.



