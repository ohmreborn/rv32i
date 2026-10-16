OUTPUT_ARCH( "riscv")
ENTRY(Reset_Handler)

MEMORY
{
    BRAM (xrw)      : ORIGIN = 0x0, LENGTH = 4K
}

_sp = ORIGIN(BRAM) + LENGTH(BRAM);

SECTIONS
{
    . = 0x0; 
  .everything : 
  { 
    *(.text.start) 
    *(.isr_vector) 
    *(.*) 
    } > BRAM
}

