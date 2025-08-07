# Compile with code coverage-report related flags
export CC=afl-clang-fast
export CXX=afl-clang-fast++

# Clean
echo "[+] Cleaning the previous build"
make clean

# Compile
echo "[+] Compiling the library"
CFLAGS="-g -O0 -fprofile-instr-generate -fcoverage-mapping" ./configure --disable-shared
make -j$(nproc)

