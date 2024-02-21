# rocm-cmake

rocm-cmake is a collection of CMake modules for common build and development
tasks within the ROCm project. It is therefore a build dependency for many of
the libraries that comprise the ROCm platform.

rocm-cmake is **not** required for building libraries or programs that _use_ ROCm;
it is required for building some of the libraries that are _a part of_ ROCm.

To install from source, run:

```bash
mkdir build
cd build
cmake ..
cmake --build .
sudo cmake --build . --target install
```
