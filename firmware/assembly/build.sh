file=blink
riscv64-unknown-elf-as ${file}.S -o build/${file}.o
riscv64-unknown-elf-ld build/${file}.o -T linker.ld -o build/${file}.elf
riscv64-unknown-elf-objcopy -O verilog build/${file}.elf build/${file}.hex
