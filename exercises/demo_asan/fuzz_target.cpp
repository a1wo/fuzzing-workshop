#include <iostream>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <fstream>
#include <vector>
#include <cctype> // For isprint

// Simple vulnerable function that processes input
void process_input(const char* data, size_t size) {
    char buffer[64];
    
    // Vulnerability 1: Buffer overflow if input is too long

    if (size > 0 && data[0] == 'A') {
        std::cout << "Debug: Processing data of size " << size << ": ";
        std::cout << data << std::endl;
        strcpy(buffer, data); // Unsafe copy - can overflow buffer
        std::cout << "Processing A command: " << buffer << std::endl;
    }
    
    // Vulnerability 2: Out-of-bounds read
    if (size >= 4 && strncmp(data, "READ", 4) == 0) {
        // Reading way beyond bounds to cause crash
        char value = data[size + 2]; // OOPS
        std::cout << "Read value: " << (int)value << std::endl;
    }
    
    // Vulnerability 3: Integer overflow leading to heap corruption
    if (size > 8 && strncmp(data, "ALLOC", 5) == 0) {
        int alloc_size = 2 * atoi(data + 5);
        if (alloc_size > 0) {
            // Potential integer overflow
            char* heap_buf = new char[alloc_size];
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
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <input_file>" << std::endl;
        return 1;
    }
     
    // Get filename from command line argument
    const char* filename = argv[1];
    
    // Read file content
    std::ifstream file(filename, std::ios::binary);
    if (!file) {
        std::cout << "Cannot open file " << filename << std::endl;
        return 0;
    }
    
    // Get file size
    file.seekg(0, std::ios::end);
    size_t file_size = file.tellg();
    file.seekg(0, std::ios::beg);
    
    // Read entire file into buffer
    std::vector<char> buffer(file_size + 1); // +1 for null terminator
    file.read(buffer.data(), file_size);
    buffer[file_size] = '\0'; // Add null terminator
    file.close();
    
    process_input(buffer.data(), file_size);
    
    return 0;
}
