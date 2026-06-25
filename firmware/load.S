.equ IO_LEDS, 0x1000
.section .text
.global _start

_start:
	li   t0, IO_LEDS 
	li	 t1, 29
	sw	 t1, 0(t0)
	jal  x0, _start
