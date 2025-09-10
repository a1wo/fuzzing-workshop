#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <openssl/sha.h>

#define BUF_SIZE            8
#define MAX_PASSWORD_LENGTH 10

#define SECRET_PWORD "\xa1\x54\xca\x46\x70\x62\x68\x42\x1e\x1a\x3a\x9b\x57\xbd\x74\x30\xc4\x00" \
                     "\x02\x2f"

#define TRUE  4242
#define FALSE 2424

void crash() {
    int* p = NULL;
    // Dereference null pointer to cause crash
    *p = 42;
}

int check_password (const char* password)
{
    char buf[BUF_SIZE] = {0};
    unsigned char hash[SHA_DIGEST_LENGTH];

    strncpy(buf, password, BUF_SIZE);
    SHA1(password, BUF_SIZE, hash);

    if (strncmp(hash, SECRET_PWORD, SHA_DIGEST_LENGTH) == 0) {
        return 1;
    }

    return 0;
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
    char* raw_key = NULL;
    int* key = NULL;
    int* authorized = malloc(sizeof(int));

    printf("Password: ");
    password = get_input();
    if (password == NULL) {
        free(authorized);
        return 1;
    }

    if (strlen(password) < MAX_PASSWORD_LENGTH) {
        if (check_password(password)) {
            *authorized = TRUE;
        }
    } else {
        printf("Password too long, enter key number to log event: ");
        raw_key = get_input();
        free(authorized);
        if (raw_key == NULL) {
            free(password);
            return 1;
        }
        key = malloc(sizeof(int));
        *key = atoi(raw_key);
    }

    if (authorized != NULL && *authorized == TRUE) {
        printf("Access granted\n");
    } else {
        printf("Access denied\n");
    }

    free(key);
    free(password);

    return 0;
}
