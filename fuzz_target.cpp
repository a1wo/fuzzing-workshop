#include <iostream>
#include <cstring>
#include <cstdlib>
#include <unistd.h>

// Simple vulnerable function that processes input
void process_input(const char* data, size_t size) {
    char buffer[64];
    
    // Vulnerability 1: Buffer overflow if input is too long
    if (size > 0 && data[0] == 'A') {
        strcpy(buffer, data); // Unsafe copy - can overflow buffer
        std::cout << "Processing A command: " << buffer << std::endl;
    }
    
    // Vulnerability 2: Out-of-bounds read
    if (size > 4 && strncmp(data, "READ", 4) == 0) {
        // Reading beyond bounds if size is exactly 5
        char value = data[size]; // OOB read
        std::cout << "Read value: " << (int)value << std::endl;
    }
    
    // Vulnerability 3: Integer overflow leading to heap corruption
    if (size > 8 && strncmp(data, "ALLOC", 5) == 0) {
        int alloc_size = atoi(data + 5);
        if (alloc_size > 0) {
            // Potential integer overflow
            char* heap_buf = new char[alloc_size * 2];
            memcpy(heap_buf, data, size); // Could overflow heap buffer
            delete[] heap_buf;
        }
    }
    
    // Vulnerability 4: Division by zero
    if (size > 6 && strncmp(data, "DIVIDE", 6) == 0) {
        int divisor = data[6] - '0';
        int result = 100 / divisor; // Division by zero if data[6] == '0'
        std::cout << "Division result: " << result << std::endl;
    }
    
    // Some "safe" processing paths
    if (size > 2 && data[0] == 'S' && data[1] == 'A' && data[2] == 'F') {
        std::cout << "Safe processing path" << std::endl;
    }
}

int main(int argc, char** argv) {
    char input[1024];
    
    // Read from stdin (AFL++ will provide input here)
    ssize_t bytes_read = read(STDIN_FILENO, input, sizeof(input) - 1);
    
    if (bytes_read > 0) {
        input[bytes_read] = '\0';
        process_input(input, bytes_read);
    } else {
        std::cerr << "No input provided" << std::endl;
        return 1;
    }
    
    return 0;
}
