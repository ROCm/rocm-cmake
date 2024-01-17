include(ROCMSphinxDoc)
rocm_add_sphinx_doc(${CMAKE_CURRENT_LIST_DIR}
    BUILDER html
    OUTPUT_DIR html
)
