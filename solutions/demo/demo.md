## Demo: pswd.c

### The Bug
`pswd.c` crashes when the correct password (`1234`) is entered — it calls `crash()` which dereferences a null pointer.
The goal is to let AFL fuzz stdin and discover the input `1234` that triggers the crash.

Note: unlike the other exercises, this target reads from **stdin** (not a file argument), so AFL is run without `@@`.

---

## Compilation:

### 1. Regular
```bash
clang -o pswd ../../exercises/demo/pswd.c
```

### 2. ASAN
```bash
clang -fsanitize=address -o pswd ../../exercises/demo/pswd.c
```

Check if compiled with ASAN:
```bash
strings pswd | grep asan
```

### 3. UBSAN
```bash
clang -fsanitize=undefined -o pswd ../../exercises/demo/pswd.c
```

Check if compiled with UBSAN:
```bash
strings pswd | grep undefined-behavior
```

### 4. AFL
```bash
export AFL_USE_ASAN=1
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1
afl-clang-fast -g -O1 -fsanitize=address -fno-omit-frame-pointer \
    ../../exercises/demo/pswd.c -o pswd
```

Or just run:
```bash
bash compile.sh
```

### 5. Coverage
```bash
clang -fprofile-instr-generate -fcoverage-mapping -o cov_pswd ../../exercises/demo/pswd.c
```

### Make sure it crashes
```bash
echo "1234" | ./pswd
```

---

## Running AFL:

pswd reads from **stdin** — do not use `@@`.

```bash
mkdir -p input
echo "."    > input/seed1.txt
echo "AAAA" > input/seed2.txt
echo "1234" > input/seed3.txt
rm -rf output
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1
afl-fuzz -i input -o output -- ./pswd
```

---

## Options To Find Faster

### 1. Change seed corpus
Add numeric strings to help AFL reach the password comparison:
```bash
echo "0000" > input/seed4.txt
echo "9999" > input/seed5.txt
```

### 2. Change AFL settings
```bash
afl-fuzz -i input -o output -P explore -L -1 -- ./pswd
```

### 3. Make a dictionary
```bash
strings ./pswd | grep -E "^[0-9]+$" >> dictionary.txt
sed 's/^".*"$/&/; t; s/^.*$/"&"/' dictionary.txt > dictionary_tmp.txt
rm dictionary.txt && mv dictionary_tmp.txt dictionary.txt
afl-fuzz -i input -o output -x dictionary.txt -- ./pswd
```

---

## Triaging

### Coverage
```bash
clang -fprofile-instr-generate -fcoverage-mapping -o cov_pswd ../../exercises/demo/pswd.c
../../scripts/coverage_report.sh output/default/queue/ ./cov_pswd
cd coverage_html && python3 -m http.server 8000
```

### Minimize a crash
```bash
afl-tmin -i output/default/crashes/id:000000* -o crash_min -- ./pswd
cat crash_min
```
