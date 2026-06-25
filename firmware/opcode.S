.global _start
_start:
    addi x1, x2, 3
    jal x1, _next
    auipc x2, 4
    lui x3, 10
    add x1, x2, x3
_next:
    li x3, 0
    li x4, 0
    beq x3, x4, _start
    jalr x0, x1, 0 
    lb x4, 4(x1)
    sb x1, 5(x3)
