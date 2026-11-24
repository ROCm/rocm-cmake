// Copyright (C) 2026 Advanced Micro Devices, Inc.

#ifdef _WIN32
__declspec(dllimport)
#endif
void mylib_func();

int main() {
    mylib_func();
    return 0;
}
