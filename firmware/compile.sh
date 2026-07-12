file=main
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -T linker.ld -nostdlib -nostartfiles ${file}.c -o build/${file}.elf -Wl,-Map,build/${file}.map
riscv64-unknown-elf-objdump -d build/${file}.elf > build/${file}.out
riscv64-unknown-elf-objcopy -O verilog build/${file}.elf build/${file}.hex
