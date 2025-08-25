## Compilation:
### Compilation Systems:
1. gcc/clang
```bash
$CXX $CXXFLAGS -o target fuzz_target.cpp;
```
2. make
```bash
./configure --prefix="$(pwd)/build" --disable-shared
make -j$(nproc)
make install
```

### Parameters:

1. clang
```bash
CC=clang
CXX=clang++
CFLAGS=""
CXXFLAGS=""
```

2. ASAN
```bash
CC=clang
CXX=clang++
CFLAGS="-fsanitize=address"
CXXFLAGS="-fsanitize=address"
```

check if compiled with ASAN:
```bash
strings fuzz_target | grep asan
```

3. UBSAN
```bash
CC=clang
CXX=clang++
CFLAGS="-fsanitize=undefined"
CXXFLAGS="-fsanitize=undefined"
```

check if compiled with UBSAN:
```bash
strings fuzz_target | grep undefined-behavior
```

4. AFL
```bash
export AFL_USE_ASAN=1 or AFL_USE_UBSAN=1 or AFL_USE_MASAN=1 or ..
CC=afl-clang-fast
CXX=afl-clang-fast++
CFLAGS=""
CXXFLAGS=""
```

5. coverage
```bash
CC=clang
CXX=clang++
CFLAGS="-fprofile-instr-generate -fcoverage-mapping"
CXXFLAGS="-fprofile-instr-generate -fcoverage-mapping"
```

use: 
```bash
rm -f fuzz_target && 
```
### make sure crashes
write sample crashes.
run to check the program crash.

## Running AFL:

```bash
mkdir input && echo "." > input/a
rm -r output/
afl-fuzz -i input -o output -- ./fuzz_target @@
```

for ASAN may need:
```bash
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1 
```

## Options To Find fasters
1. change seed corpus

2. change afl settings:
```bash
afl-fuzz -i input -o output -P explore -L -1 -- ./fuzz_target @@
```

3. make dictionary 
```bash
strings ./target | grep -E "^[0-9]+$|^[A-Z]+[0-9]*$" >> dictionary.txt
sed 's/^".*"$/&/; t; s/^.*$/"&"/' dictionary.txt > dictionary_tmp.txt
rm dictionary.txt && mv dictionary_tmp.txt dictionary.txt
```
```bash
afl-fuzz -i input -o output -x dictionary.txt -- ./fuzz_target @@
```


## Triaging

# coverage
```bash
../../scripts/coverage_report.sh output/default/queue/ ./cov_target
cd coverage_html && python3 -m http.server 8000
```

# minimizing
```bash
afl-tmin -i output/default/crashes/* -o CRASH_min -- ./fuzz_target @@
```