## Ex1: vulnerable.c

### The Bugs

**Bug 1: Heap Use-After-Free (ASAN)**

In `main()`, when the password is too long (`strlen >= MAX_PASSWORD_LENGTH = 10`), the else branch runs:
```c
free(authorized);   // freed here
...
// later, outside the if/else:
if (authorized != NULL && *authorized == TRUE)  // UAF read — pointer not NULL but memory is gone
```
`authorized` is freed but the pointer is not set to NULL, so the check passes and reads freed memory.
ASAN reports: `heap-use-after-free`.

Trigger: any password with length >= 10, e.g. `AAAAAAAAAA`, then any key number.

**Bug 2: Memory Leak (raw_key)**

In the else branch, `raw_key` returned by `get_input()` is never freed.
Only `key` and `password` are freed at the end of main.

**Note: The intentional crash**

`crash()` is called when `check_password()` returns 1, i.e. when the SHA1 of the input matches `SECRET_PWORD`.
AFL is very unlikely to find this path — it requires inverting SHA1.

---

## Compilation:

### 1. Regular
```bash
clang -o vulnerable ../../exercises/ex1/src/vulnerable.c -lcrypto
```

### 2. ASAN
```bash
clang -fsanitize=address -o vulnerable ../../exercises/ex1/src/vulnerable.c -lcrypto
```

Check if compiled with ASAN:
```bash
strings vulnerable | grep asan
```

### 3. UBSAN
```bash
clang -fsanitize=undefined -o vulnerable ../../exercises/ex1/src/vulnerable.c -lcrypto
```

Check if compiled with UBSAN:
```bash
strings vulnerable | grep undefined-behavior
```

### 4. AFL
```bash
export AFL_USE_ASAN=1
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1
afl-clang-fast -g -O1 -fsanitize=address -fno-omit-frame-pointer \
    ../../exercises/ex1/src/vulnerable.c -o vulnerable -lcrypto
```

Or just run:
```bash
bash compile.sh
```

### 5. Coverage
```bash
clang -fprofile-instr-generate -fcoverage-mapping \
    ../../exercises/ex1/src/vulnerable.c -o cov_vulnerable -lcrypto
```

### Make sure it crashes
```bash
printf "AAAAAAAAAA\n0\n" | ./vulnerable
```

---

## Running AFL:

vulnerable reads from **stdin** — do not use `@@`.

```bash
mkdir -p input
echo "."                 > input/seed1.txt
echo "AAAA"              > input/seed2.txt
printf "AAAAAAAAAA\n0\n" > input/seed3.txt
rm -rf output
export ASAN_OPTIONS=abort_on_error=1:symbolize=0:detect_leaks=0:allocator_may_return_null=1
afl-fuzz -i input -o output -- ./vulnerable
```

---

## Options To Find Faster

### 1. Change seed corpus
Add 10+ char strings to immediately exercise the else branch:
```bash
printf "BBBBBBBBBB\n1\n" > input/seed4.txt
```

### 2. Change AFL settings
```bash
afl-fuzz -i input -o output -P explore -L -1 -- ./vulnerable
```

### 3. Make a dictionary
```bash
strings ./vulnerable | grep -E "^[0-9]+$|^[A-Z]+[0-9]*$" >> dictionary.txt
sed 's/^".*"$/&/; t; s/^.*$/"&"/' dictionary.txt > dictionary_tmp.txt
rm dictionary.txt && mv dictionary_tmp.txt dictionary.txt
afl-fuzz -i input -o output -x dictionary.txt -- ./vulnerable
```

---

## Triaging

### Coverage
```bash
clang -fprofile-instr-generate -fcoverage-mapping \
    ../../exercises/ex1/src/vulnerable.c -o cov_vulnerable -lcrypto
../../scripts/coverage_report.sh output/default/queue/ ./cov_vulnerable
cd coverage_html && python3 -m http.server 8000
```

### Minimize a crash
```bash
afl-tmin -i output/default/crashes/id:000000* -o crash_min -- ./vulnerable
cat crash_min | xxd
```
