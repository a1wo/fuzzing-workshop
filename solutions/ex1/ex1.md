## Compilation:
1. regular
```bash
clang++ -o target fuzz_target.cpp
```

2. ASAN
```bash
clang++ -fsanitize=address -o target fuzz_target.cpp
```

does it change running speed?

check if compiled with ASAN:
```bash
strings fuzz_target | grep asan
```

3. UBSAN
```bash
clang++ -fsanitize=undefined -o target fuzz_target.cpp
```

4. afl
```bash
# AFL_USE_ASAN=1 afl-clang-fast++ -g -O1 -fsanitize=address -fno-omit-frame-pointer fuzz_target.cpp -o fuzz_target
export AFL_USE_ASAN=1 or AFL_USE_UBSAN=1 or AFL_USE_MASAN=1 or ..
afl-clang-fast++ fuzz_target.cpp -o fuzz_target
```

5. coverage
```bash
clang++ -fprofile-instr-generate -fcoverage-mapping -o cov_target fuzz_target.cpp
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
strings /root/fuzzing-workshop/exercises/ex1/fuzz_target | grep -E "^[0-9]+$|^[A-Z]+[0-9]*$" >> dictionary.txt
```
## Triaging

# coverage

# minimizing
```bash
afl-tmin -i output/default/crashes/* -o CRASH_min -- ./fuzz_target @@
```