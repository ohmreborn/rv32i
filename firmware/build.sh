file=opcode
riscv32-unknown-elf-as ${file}.S -o build/${file}.o
riscv32-unknown-elf-objcopy -O binary build/${file}.o build/${file}.bin