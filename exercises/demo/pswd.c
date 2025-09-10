#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SECRET_PWORD "1234"  

void crash() {
    int* p = NULL;
    // Dereference null pointer to cause crash
    *p = 42;
}

char* get_input (void)
{
    char* input = NULL;
    size_t input_size = 0;
    ssize_t input_length = 0;

    input_length = getline(&input, &input_size, stdin);
    
    if (input_length <= 0) {
        free(input);
        return NULL;
    }
    // Strip newline from the end of the input.
    if (input[input_length - 1] == '\n') {
        input[input_length - 1] = '\0';
    }

    return input;
}

int main (void)
{
    char* password = NULL;

    printf("Password: ");
    password = get_input();

    if (strncmp(password, SECRET_PWORD, strlen(SECRET_PWORD)) == 0) {
        printf("Access granted\n");
        crash();
    }
    else {
        printf("Access denied\n");
    }

    free(password);

    return 0;
}
