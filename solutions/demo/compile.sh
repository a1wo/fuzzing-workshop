#!/bin/bash

# Compile pswd.c with AFL++ instrumentation and AddressSanitizer
echo "[+] Compiling pswd.c with AFL++ instrumentation..."

export AFL_USE_ASAN=1
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1

afl-clang-fast -g -O1 -fsanitize=address -fno-omit-frame-pointer \
    ../../exercises/demo/pswd.c -o pswd

if [ $? -eq 0 ]; then
    echo "[+] Compilation successful! Binary created: pswd"
    echo ""
    echo "[+] Setting up seed corpus..."
    mkdir -p input
    echo "."     > input/seed1.txt
    echo "AAAA"  > input/seed2.txt
    echo "1234"  > input/seed3.txt
    echo ""
    echo "[+] To start fuzzing, run:"
    echo "    export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1"
    echo "    rm -rf output"
    echo "    afl-fuzz -i input -o output -- ./pswd"
else
    echo "[-] Compilation failed!"
    exit 1
fi
