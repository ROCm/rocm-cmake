ROCMLocalTargets
================

Commands
--------

.. cmake:command:: rocm_local_targets

.. code-block:: cmake

    rocm_local_targets(<output-variable>)

Get a list of all local ROCm agents to use as local build targets.
Sets the output variable to ``"NOTFOUND"`` if the local agents could not be
determined, or if there are no local agents.
