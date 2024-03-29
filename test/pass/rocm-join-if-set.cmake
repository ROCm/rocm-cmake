use_rocm_cmake()
include(ROCMUtilities)

function(test_rocm_join_if_set EXPECTED INITIAL GLUE)
    set(me ${INITIAL})
    # message("Expected='" ${EXPECTED} "' initial='" ${me} "'")
    rocm_join_if_set(${GLUE} me ${ARGN})
    # message("got '" ${me} "'")
    test_expect_eq("${me}" "${EXPECTED}")
endfunction()

test_rocm_join_if_set("hello, there" "hello" ", " "there")
test_rocm_join_if_set("there" "" ", " "there")
test_rocm_join_if_set("hello, there, how" "hello" ", " "there" "how")
test_rocm_join_if_set("1, 2, 3, 4" "1" ", " 2 3 4)
test_rocm_join_if_set("1, 2, 3, 4, 0" "1" ", " 2 3 4 0)
test_rocm_join_if_set("1, 2, 3, 4, 0, 1" "1" ", " 2 3 4 0 1)
test_rocm_join_if_set("1, 2, 3" "1" ", " 2 3 "")
test_rocm_join_if_set("1, 2, 3, 4" "1" ", " 2 3 "" 4)
test_rocm_join_if_set("0, there" 0 ", " "there")
test_rocm_join_if_set("FALSE, there" FALSE ", " "there")
test_rocm_join_if_set("false, there" false ", " "there")
