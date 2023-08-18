ROCMCheckTargetIds
==================

Commands
--------

.. cmake:command:: rocm_check_target_ids

.. code-block:: cmake

    rocm_check_target_ids(<output-variable>
        TARGETS <target-id>...
    )

Returns the subset of HIP `target-ids <https://clang.llvm.org/docs/ClangOffloadBundler.html#target-id>`_ supported by the current CXX compiler.
