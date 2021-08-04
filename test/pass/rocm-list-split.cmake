
use_rocm_cmake()
include(ROCMInstallTargets)

function(test_rocm_list_split INPUT_LIST ELEMENT)
    rocm_list_split(INPUT_LIST ${ELEMENT} OUTPUT_LIST)
    list(LENGTH OUTPUT_LIST LEN)
    math(EXPR N "${LEN} - 1")
    foreach(I RANGE ${N})
        list(GET ARGN ${I} EXPECTED)
        list(GET OUTPUT_LIST ${I} SUBLIST)
        test_expect_eq("${${SUBLIST}}" "${EXPECTED}")
    endforeach()
endfunction()

test_rocm_list_split("PACKAGE;a;PACKAGE;b" PACKAGE "a" "b")
test_rocm_list_split("PACKAGE;b" PACKAGE "b")
test_rocm_list_split("b" PACKAGE "b")
# TODO
# test_rocm_list_split("PACKAGE;a1;a2;PACKAGE;b" PACKAGE "a1;a2" "b")
