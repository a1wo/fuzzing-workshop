export CC=afl-clang-fast
export CXX=afl-clang-fast++

# Clean
echo "[+] Cleaning the previous build"
make clean

# Compile
echo "[+] Compiling the library"
./configure --disable-shared
make -j$(nproc)
