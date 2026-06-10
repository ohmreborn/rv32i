.global _start
_start:
    addi x1, x2, 3
    auipc x2, 4
    lui x3, 10
    add x1, x2, x3
    jal x1, _next
_next:
    lb x4, 4(x1)
    sb x1, 5(x3)
    beq x3, x4, _start
    jalr x2, 0(x3)
