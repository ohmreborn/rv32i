file=load
riscv32-unknown-elf-as ${file}.S -o build/${file}.o
riscv32-unknown-elf-ld build/${file}.o -T linker.ld -o build/${file}.elf
# riscv32-unknown-elf-objcopy -O binary build/${file}.o build/${file}.bin
# hexdump -e '"%08x\n"' build/${file}.bin > build/${file}.hex
riscv32-unknown-elf-objcopy -O verilog build/${file}.elf build/${file}.hex
