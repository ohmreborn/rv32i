file=opcode
riscv32-unknown-elf-as ${file}.S -o build/${file}.o
riscv32-unknown-elf-objcopy -O binary build/${file}.o build/${file}.bin
hexdump -e '1/4 "%08x\n"' build/${file}.bin > build/${file}.hex 