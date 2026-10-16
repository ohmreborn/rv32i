
CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
COPY = riscv64-unknown-elf-objcopy
DUMP = riscv64-unknown-elf-objdump

BUILD_DIR = build

# Compiler flags for RV32I
MARCH = rv32i_zicsr
CFLAGS = -march=$(MARCH) -mabi=ilp32
ASFLAGS = -march=$(MARCH) -mabi=ilp32
LDFLAGS = -m elf32lriscv

# Find source files safely (avoiding 'ls')
SOURCES = .
SOURCES_C  = $(wildcard $(SOURCES)/*.c)
SOURCES_AS = $(wildcard $(SOURCES)/startup/*.s)
LINKER = $(SOURCES)/startup/linker.ld

# Define generated assembly files from C files
OBJECTS = $(patsubst %.c, $(BUILD_DIR)/obj/%.o, $(SOURCES_C)) \
		$(patsubst %.s, $(BUILD_DIR)/obj/%.o, $(SOURCES_AS))

# Target binary
TARGET = $(BUILD_DIR)/firmware.elf
HEX = $(BUILD_DIR)/firmware.hex
DEBUG = $(BUILD_DIR)/firmware.dump

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

$(BUILD_DIR)/obj/%.o: %.s
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf $(BUILD_DIR)
