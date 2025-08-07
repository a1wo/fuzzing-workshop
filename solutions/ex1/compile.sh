#!/bin/bash

# Compile the fuzzing target with AFL++ instrumentation and AddressSanitizer
echo "Compiling fuzz_target.cpp with AFL++ instrumentation..."

# Make sure AFL++ binaries are in PATH (they should be after building the Docker image)
export AFL_USE_ASAN=1  # Enable AddressSanitizer to catch memory errors
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1 
# Compile with afl-clang-fast++ for better performance
afl-clang-fast++ -g -O1 -fsanitize=address -fno-omit-frame-pointer \
    fuzz_target.cpp -o fuzz_target

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful! Binary created: fuzz_target"
    echo ""
    echo "To start fuzzing, run:"
    echo "mkdir -p input output"
    echo "echo 'SAFE' > input/seed1.txt"
    echo "echo 'AAAA' > input/seed2.txt" 
    echo "echo 'READ1234' > input/seed3.txt"
    echo "afl-fuzz -s 90 -i input -o output ./fuzz_target"
else
    echo "✗ Compilation failed!"
    exit 1
fi
