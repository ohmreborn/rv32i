CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
COPY = riscv64-unknown-elf-objcopy
DUMP = riscv64-unknown-elf-objdump

BUILD_DIR = build
LINKER = startup/linker.ld

# Compiler flags for RV32I
CFLAGS = -march=rv32i -mabi=ilp32
ASFLAGS = -march=rv32i -mabi=ilp32
LDFLAGS = -m elf32lriscv

# Find source files safely (avoiding 'ls')
SOURCES_C  = $(wildcard *.c)
SOURCES_AS = $(wildcard startup/*.s)

# Define generated assembly files from C files
OBJECTS = $(patsubst %.c, $(BUILD_DIR)/obj/%.o, $(SOURCES_C)) \
		$(patsubst startup/%.s, $(BUILD_DIR)/obj/%.o, $(SOURCES_AS))

# Target binary
TARGET = $(BUILD_DIR)/firmware.elf
HEX = build/firmware.hex
DEBUG = build/firmware.dump

.PHONY: all clean

all: $(TARGET)
	$(COPY) -O verilog $(TARGET) $(HEX)
	$(DUMP) -d $(TARGET) > $(DEBUG)

# Rule to link the final ELF binary
$(TARGET): $(OBJECTS) $(LINKER)
	@mkdir -p $(@D)
	$(LD) $(LDFLAGS) -T $(LINKER) $(OBJECTS) -o $@

$(BUILD_DIR)/obj/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/obj/%.o: startup/%.s
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf $(BUILD_DIR)