	.file	"main.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	lui	a5,%hi(.LC0)
	lw	a5,%lo(.LC0)(a5)
	sw	a5,-20(s0)
	lw	a0,-20(s0)
	call	__extendsfdf2
	mv	a4,a0
	mv	a5,a1
	lui	a3,%hi(.LC1)
	lw	a2,%lo(.LC1)(a3)
	lw	a3,%lo(.LC1+4)(a3)
	mv	a0,a4
	mv	a1,a5
	call	__adddf3
	mv	a4,a0
	mv	a5,a1
	mv	a0,a4
	mv	a1,a5
	call	__truncdfsf2
	mv	a5,a0
	sw	a5,-20(s0)
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.section	.rodata
	.align	2
.LC0:
	.word	1078523331
	.align	3
.LC1:
	.word	2061584302
	.word	1072934420
	.globl	__truncdfsf2
	.globl	__adddf3
	.globl	__extendsfdf2
	.ident	"GCC: (g5115c7e44) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
