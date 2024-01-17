include(ROCMSphinxDoc)
rocm_add_sphinx_doc(src
    CONFIG_DIR ${CMAKE_SOURCE_DIR}/docs
    BUILDER html
    OUTPUT_DIR html
)
