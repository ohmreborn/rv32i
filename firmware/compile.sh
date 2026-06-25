file=load
riscv32-unknown-elf-gcc ${file}.c -o build/${file}.elf
riscv32-unknown-elf-objcopy -O binary build/${file}.elf build/${file}.bin
riscv32-unknown-elf-objdump -d build/${file}.elf > build/${file}.decode
hexdump -e '1/4 "%08x\n"' build/${file}.bin > build/${file}.hex 
