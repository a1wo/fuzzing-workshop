CC ?= gcc

CFLAGS = -O0 -g
LIBS = -lcrypto
EXTRA_LIBS = -I/opt/homebrew/opt/openssl@3/include -L/opt/homebrew/opt/openssl@3/lib

TARGET_NAME = vulnerable
SOURCE_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/$(TARGET_NAME)

SOURCE_FILES = $(wildcard $(SOURCE_DIR)/*.c)


all: $(BUILD_DIR) $(TARGET)

$(TARGET): $(SOURCE_FILES)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS) $(EXTRA_LIBS)

$(BUILD_DIR):
	@mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)/


.PHONY: clean
