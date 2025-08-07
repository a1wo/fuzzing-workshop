# Exercise 1 - LibTIFF

This time we will fuzz **LibTIFF** image library. The goal is to find a crash/PoC for CVE-2016-9297 in libtiff 4.0.4 and to measure the code coverage data of your queue/crash/PoC. 
  
**CVE-2016-9297** is an Out-of-bounds Read vulnerability that can be triggered via crafted TIFF_SETGET_C16ASCII or TIFF_SETGET_C32_ASCII tag values.


## What you will learn
Once you complete this exercise you will know:
- How to fuzz a real-world target
- How to use code coverage data to improve the effectiveness of fuzzing

## Note -s 90
- AFL uses a non-deterministic testing algorithm, so two fuzzing sessions are never the same. That's why we highly recommend **to set a fixed seed (-s 90)**. This way your fuzzing results will be similar to ours.  

## Helper scripts

You have a few helper scripts available:
* compile.sh - Contains information on how to build the target with AFL's clang wrappers, that instrument the target.
* compile_cov - Run this to compile the target with compiler flags that are needed to generate a coverage report.
* coverage_report.sh - Generate a HTML-based coverage report. View which code paths were triggered.

## Do it yourself!
In order to complete this exercise, you need to:
1) Fuzz LibTiff (with ASan enabled) until you have a few unique crashes
2) Triage the crashes to find a PoC for the vulnerability
3) Measure the code coverage of this PoC - Use `coverage_report.sh`
4) Fix the issue


**Estimated time = 1 hour**