cmake_minimum_required(VERSION 3.10...3.31.0)

use_rocm_cmake()
include(ROCMCreatePackage)
include(ROCMClients)

test_expect_eq("${CMAKE_INSTALL_DEFAULT_COMPONENT_NAME}" "runtime")

set(BUILD_SHARED_LIBS ON)
rocm_package_setup_component(comp-a)

test_expect_eq("${ROCM_PACKAGE_COMPONENTS}" "comp-a")
test_expect_undef(CPACK_DEBIAN_COMP-A_PACKAGE_NAME)
test_expect_undef(CPACK_RPM_COMP-A_PACKAGE_NAME)

rocm_package_setup_component(
    comp-b
    PACKAGE_NAME test-b
    PARENT comp-a
)

test_expect_eq("${ROCM_PACKAGE_COMPONENTS}" "comp-a;comp-b")
test_expect_eq("${CPACK_DEBIAN_COMP-B_PACKAGE_NAME}" "<PACKAGE_NAME>-test-b")
test_expect_eq("${CPACK_RPM_COMP-B_PACKAGE_NAME}" "<PACKAGE_NAME>-test-b")
test_expect_eq("${ROCM_PACKAGE_COMPONENT_DEPENDENCIES}" "comp-a->comp-b")

rocm_package_setup_component(
    comp-c
    DEPENDS
        COMMON "foo > 1.0"
        DEB "bar < 2.0"
        RPM "baz = 3.0"
        COMPONENT comp-a comp-b
    LIBRARY_NAME packaging
    PACKAGE_NAME comp-c
)

test_expect_eq("${ROCM_PACKAGE_COMPONENTS}" "comp-a;comp-b;comp-c")
test_expect_eq("${CPACK_DEBIAN_COMP-C_PACKAGE_NAME}" "packaging-comp-c")
test_expect_eq("${CPACK_RPM_COMP-C_PACKAGE_NAME}" "packaging-comp-c")
test_expect_eq("${CPACK_DEBIAN_COMP-C_PACKAGE_DEPENDS}" "foo (>> 1.0), bar (<< 2.0)")
test_expect_eq("${CPACK_RPM_COMP-C_PACKAGE_REQUIRES}" "foo > 1.0, baz = 3.0")
test_expect_eq("${ROCM_PACKAGE_COMPONENT_DEPENDENCIES}" "comp-a->comp-b;comp-c->comp-a;comp-c->comp-b")

rocm_package_setup_client_component(
    client-a
    DEPENDS COMPONENT comp-c
)
test_expect_eq("${ROCM_PACKAGE_COMPONENTS}" "comp-a;comp-b;comp-c;client-a")
test_expect_undef(CPACK_DEBIAN_CLIENT-A_PACKAGE_NAME)
test_expect_undef(CPACK_RPM_CLIENT-A_PACKAGE_NAME)
test_expect_eq("${CPACK_DEBIAN_CLIENT-A_PACKAGE_DEPENDS}" "")
test_expect_eq("${CPACK_RPM_CLIENT-A_PACKAGE_REQUIRES}" "")
test_expect_eq("${ROCM_PACKAGE_COMPONENT_DEPENDENCIES}"
    "comp-a->comp-b;comp-c->comp-a;comp-c->comp-b;clients->client-a;client-a->comp-c;client-a->runtime")

set(CPACK_PACKAGE_NAME "packtest")
set(CPACK_PACKAGE_VERSION 1.0.0)

rocm_set_comp_cpackvar(FALSE "" "${ROCM_PACKAGE_COMPONENTS};clients")
test_expect_eq("${CPACK_COMPONENTS_ALL}" "runtime;comp-a;comp-b;comp-c;client-a;clients")

test_expect_eq("${CPACK_DEBIAN_RUNTIME_PACKAGE_NAME}" "packtest")
test_expect_eq("${CPACK_RPM_RUNTIME_PACKAGE_NAME}" "packtest")
test_expect_eq("${CPACK_DEBIAN_RUNTIME_PACKAGE_DEPENDS}" "")
test_expect_eq("${CPACK_RPM_RUNTIME_PACKAGE_REQUIRES}" "")

test_expect_eq("${CPACK_DEBIAN_COMP-A_PACKAGE_NAME}" "packtest-comp-a")
test_expect_eq("${CPACK_RPM_COMP-A_PACKAGE_NAME}" "packtest-comp-a")
test_expect_eq("${CPACK_DEBIAN_COMP-A_PACKAGE_DEPENDS}" "packtest-test-b (>= 1.0.0)")
test_expect_eq("${CPACK_RPM_COMP-A_PACKAGE_REQUIRES}" "packtest-test-b >= 1.0.0")

test_expect_eq("${CPACK_DEBIAN_COMP-B_PACKAGE_NAME}" "packtest-test-b")
test_expect_eq("${CPACK_RPM_COMP-B_PACKAGE_NAME}" "packtest-test-b")
test_expect_eq("${CPACK_DEBIAN_COMP-B_PACKAGE_DEPENDS}" "")
test_expect_eq("${CPACK_RPM_COMP-B_PACKAGE_REQUIRES}" "")

test_expect_eq("${CPACK_DEBIAN_COMP-C_PACKAGE_NAME}" "packaging-comp-c")
test_expect_eq("${CPACK_RPM_COMP-C_PACKAGE_NAME}" "packaging-comp-c")
test_expect_eq("${CPACK_DEBIAN_COMP-C_PACKAGE_DEPENDS}"
    "foo (>> 1.0), bar (<< 2.0), packtest-comp-a (>= 1.0.0), packtest-test-b (>= 1.0.0)")
test_expect_eq("${CPACK_RPM_COMP-C_PACKAGE_REQUIRES}"
    "foo > 1.0, baz = 3.0, packtest-comp-a >= 1.0.0, packtest-test-b >= 1.0.0")

test_expect_eq("${CPACK_DEBIAN_CLIENT-A_PACKAGE_NAME}" "packtest-client-a")
test_expect_eq("${CPACK_RPM_CLIENT-A_PACKAGE_NAME}" "packtest-client-a")
test_expect_eq("${CPACK_DEBIAN_CLIENT-A_PACKAGE_DEPENDS}" "packaging-comp-c (>= 1.0.0), packtest (>= 1.0.0)")
test_expect_eq("${CPACK_RPM_CLIENT-A_PACKAGE_REQUIRES}" "packaging-comp-c >= 1.0.0, packtest >= 1.0.0")

test_expect_eq("${CPACK_DEBIAN_CLIENTS_PACKAGE_NAME}" "packtest-clients")
test_expect_eq("${CPACK_RPM_CLIENTS_PACKAGE_NAME}" "packtest-clients")
test_expect_eq("${CPACK_DEBIAN_CLIENTS_PACKAGE_DEPENDS}" "packtest-client-a (>= 1.0.0)")
test_expect_eq("${CPACK_RPM_CLIENTS_PACKAGE_REQUIRES}" "packtest-client-a >= 1.0.0")
