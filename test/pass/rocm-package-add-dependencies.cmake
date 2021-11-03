use_rocm_cmake()
include(ROCMCreatePackage)

function(test_rocm_package_add_deb_dependencies EXPECTED INITIAL)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${INITIAL}")
    rocm_package_add_deb_dependencies(DEPENDS ${ARGN})
    test_expect_eq("${CPACK_DEBIAN_PACKAGE_DEPENDS}" "${EXPECTED}")

    set(CPACK_DEBIAN_TEST_PACKAGE_DEPENDS "${INITIAL}")
    rocm_package_add_deb_dependencies(COMPONENT test DEPENDS ${ARGN})
    test_expect_eq("${CPACK_DEBIAN_TEST_PACKAGE_DEPENDS}" "${EXPECTED}")
endfunction()

function(test_rocm_package_add_rpm_dependencies EXPECTED INITIAL)
    set(CPACK_RPM_PACKAGE_REQUIRES "${INITIAL}")
    rocm_package_add_rpm_dependencies(DEPENDS ${ARGN})
    test_expect_eq("${CPACK_RPM_PACKAGE_REQUIRES}" "${EXPECTED}")

    set(CPACK_RPM_TEST_PACKAGE_REQUIRES "${INITIAL}")
    rocm_package_add_rpm_dependencies(COMPONENT test DEPENDS ${ARGN})
    test_expect_eq("${CPACK_RPM_TEST_PACKAGE_REQUIRES}" "${EXPECTED}")
endfunction()

function(test_rocm_package_add_dependencies DEB_EXPECTED RPM_EXPECTED DEB_INITIAL RPM_INITIAL)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${DEB_INITIAL}")
    set(CPACK_RPM_PACKAGE_REQUIRES "${RPM_INITIAL}")
    rocm_package_add_dependencies(DEPENDS ${ARGN})
    test_expect_eq("${CPACK_DEBIAN_PACKAGE_DEPENDS}" "${DEB_EXPECTED}")
    test_expect_eq("${CPACK_RPM_PACKAGE_REQUIRES}" "${RPM_EXPECTED}")

    set(CPACK_DEBIAN_TEST_PACKAGE_DEPENDS "${DEB_INITIAL}")
    set(CPACK_RPM_TEST_PACKAGE_REQUIRES "${RPM_INITIAL}")
    rocm_package_add_dependencies(COMPONENT test DEPENDS ${ARGN})
    test_expect_eq("${CPACK_DEBIAN_TEST_PACKAGE_DEPENDS}" "${DEB_EXPECTED}")
    test_expect_eq("${CPACK_RPM_TEST_PACKAGE_REQUIRES}" "${RPM_EXPECTED}")
endfunction()

# Debian testing
# Test basic package adding
test_rocm_package_add_deb_dependencies(
    "foo"
    ""
    "foo"
)
test_rocm_package_add_deb_dependencies(
    "foo, bar"
    "foo"
    "bar"
)
test_rocm_package_add_deb_dependencies(
    "foo, bar"
    ""
    "foo"
    "bar"
)

# Test operands that stay the same from deb to rpm
foreach(OP ">=" "<=" "=")
    test_rocm_package_add_deb_dependencies(
        "foo (${OP} 0.0.1)"
        ""
        "foo ${OP} 0.0.1"
    )
    test_rocm_package_add_deb_dependencies(
        "foo, bar (${OP} 0.0.2)"
        "foo"
        "bar ${OP} 0.0.2"
    )
endforeach()

# Test operands that change from deb to rpm
foreach(OP ">" "<")
    test_rocm_package_add_deb_dependencies(
        "foo (${OP}${OP} 0.0.1)"
        ""
        "foo ${OP} 0.0.1"
    )
    test_rocm_package_add_deb_dependencies(
        "foo, bar (${OP}${OP} 0.0.2)"
        "foo"
        "bar ${OP} 0.0.2"
    )
endforeach()

# RPM testing
# Test basic package adding
test_rocm_package_add_rpm_dependencies(
    "foo"
    ""
    "foo"
)
test_rocm_package_add_rpm_dependencies(
    "foo, bar"
    "foo"
    "bar"
)
test_rocm_package_add_rpm_dependencies(
    "foo, bar"
    ""
    "foo"
    "bar"
)

# Test operands that stay the same from deb to rpm
foreach(OP ">=" "<=" "=")
    test_rocm_package_add_rpm_dependencies(
        "foo ${OP} 0.0.1"
        ""
        "foo ${OP} 0.0.1"
    )
    test_rocm_package_add_rpm_dependencies(
        "foo, bar ${OP} 0.0.2"
        "foo"
        "bar ${OP} 0.0.2"
    )
endforeach()

# Test operands that change from deb to rpm
foreach(OP ">" "<")
    test_rocm_package_add_rpm_dependencies(
        "foo ${OP} 0.0.1"
        ""
        "foo ${OP} 0.0.1"
    )
    test_rocm_package_add_rpm_dependencies(
        "foo, bar ${OP} 0.0.2"
        "foo"
        "bar ${OP} 0.0.2"
    )
endforeach()

# Both testing
# Test basic package adding
test_rocm_package_add_dependencies(
    "foo" "foo"
    "" ""
    "foo"
)
test_rocm_package_add_dependencies(
    "foo, bar" "foo, bar"
    "foo" "foo"
    "bar"
)
test_rocm_package_add_dependencies(
    "foo, bar" "foo, bar"
    "" ""
    "foo"
    "bar"
)

# Test operands that stay the same from deb to rpm
foreach(OP ">=" "<=" "=")
    test_rocm_package_add_dependencies(
        "foo (${OP} 0.0.1)" "foo ${OP} 0.0.1"
        "" ""
        "foo ${OP} 0.0.1"
    )
    test_rocm_package_add_dependencies(
        "foo, bar (${OP} 0.0.2)" "foo, bar ${OP} 0.0.2"
        "foo" "foo"
        "bar ${OP} 0.0.2"
    )
endforeach()

# Test operands that change from deb to rpm
foreach(OP ">" "<")
    test_rocm_package_add_dependencies(
        "foo (${OP}${OP} 0.0.1)" "foo ${OP} 0.0.1"
        "" ""
        "foo ${OP} 0.0.1"
    )
    test_rocm_package_add_dependencies(
        "foo, bar (${OP}${OP} 0.0.2)" "foo, bar ${OP} 0.0.2"
        "foo" "foo"
        "bar ${OP} 0.0.2"
    )
endforeach()
