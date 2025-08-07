#!/bin/bash

# Intro
echo "This script generates a coverage report from your fuzzing campaign."
echo "You can even run this script while actively fuzzing the target."
echo "[!] The script will only work if you previously compiled with 'compile_cov.sh' (i.e CFLAGS=\"-g -O0 -fprofile-instr-generate -fcoverage-mapping\")" and have already done some fuzzing
echo

# Default values
DEFAULT_OUT_DIR="/home/user/sadna/ex1/tiff-4.0.4/out"
DEFAULT_TARGET="/home/user/sadna/ex1/tiff-4.0.4/tools/tiffinfo"

# Allow user to override default values via command-line arguments
OUT_DIR="${1:-$DEFAULT_OUT_DIR}"
TARGET="${2:-$DEFAULT_TARGET}"

# Display variables to the user
echo "The script will run with the following values:"
echo "OUT_DIR = $OUT_DIR"
echo "TARGET = $TARGET"
echo

# Ask for user confirmation
read -p "Do you want to continue? (y/n): " choice

# In case this isn't our first time, we might want to clear previous .profraw files.
# Delete all .profraw files in the output directory
rm -f "$OUT_DIR"/*/queue/*.profraw

# Check user response
case "$choice" in
    y|Y ) 
        echo "Continuing script execution..."
        echo "[+] Extracting coverage data from each testcase in the corpus to a separate file"
        for testcase in "$OUT_DIR"/*/queue/*; do 
            export LLVM_PROFILE_FILE="$testcase.profraw"
            "$TARGET" "$testcase" > /dev/null 2>&1
        done

        echo "[+] Merge coverage (.profraw) data"
        llvm-profdata-15 merge "$OUT_DIR"/*/queue/*.profraw -o cov.profdata

        echo "[+] Export to HTML format"
        llvm-cov-15 show "$TARGET" -instr-profile=cov.profdata -format=html -o cov_merged

        echo "[+] Open report"
        xdg-open cov_merged/index.html
        ;;
    n|N ) 
        echo "Exiting script."
        exit 1
        ;;
    * ) 
        echo "Invalid input. Exiting."
        exit 1
        ;;
esac
