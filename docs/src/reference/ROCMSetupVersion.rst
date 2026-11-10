.. meta::
  :description: ROCm CMake
  :keywords: ROCm, Cmake, library, api, AMD

.. _rocmSetupVersion:

****************************************************
ROCMSetupVersion
****************************************************

Commands
--------

.. cmake:command:: rocm_get_version

.. code-block:: cmake

    rocm_get_version(<output-variable>
        [VERSION <version>]
        [DIRECTORY <path>]
    )

Get the version of directory using git tags if possible.

.. cmake:command:: rocm_setup_version

.. code-block:: cmake

    rocm_setup_version(
        VERSION <version>
        [NO_GIT_TAG_VERSION]
        [PARENT <commit>]
    )

Setup the version for the project. This will try to use git tag to set the version if possible unless ``NO_GIT_TAG_VERSION`` is passed. The ``PARENT`` argument can be used to set the commit to start the count of number of commits to the current revision.

.. cmake:command:: rocm_add_version_resource

.. code-block:: cmake

    rocm_add_version_resource(<target> <name> <description>
        [PRODUCT_NAME <product_name>]
        [COMMENTS <comments>]
    )

Add a Windows PE version resource to a shared library, module library (DLL) or executable (EXE) target. The file and product versions come from ``PROJECT_VERSION``. ``<name>`` sets ``InternalName``, ``<description>`` sets ``FileDescription``, and ``OriginalFilename`` is derived from the target's ``OUTPUT_NAME``, ``PREFIX`` and ``SUFFIX``.

``PRODUCT_NAME`` overrides ``ProductName``, which defaults to ``<name> <filename>``. ``COMMENTS`` adds a ``Comments`` value, for example the git commit the binary was built from; it is omitted by default.

The generated ``.rc`` file is only rewritten when its content changes, so reconfiguring does not relink the target. On non-Windows platforms the command does nothing. If no resource compiler is available (``CMAKE_RC_COMPILER`` is unset or set to a ``NOTFOUND``/``NOTREQUIRED`` value, or the ``RC`` language is not enabled), a warning is printed and the target is built without a version resource.

Example
-------

.. code-block:: cmake

    rocm_add_version_resource(mylib "MyLib" "My ROCm Library")

    rocm_add_version_resource(mylib "MyLib" "My ROCm Library"
        PRODUCT_NAME "AMD ROCm MyLib ${PROJECT_VERSION}"
        COMMENTS "Git commit: ${MYLIB_GIT_COMMIT}")
