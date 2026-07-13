OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    BRAM (xrw)      : ORIGIN = 0x0, LENGTH = 4K
}


SECTIONS
{
    . = 0x0; 
  .everything : 
  { 
    *(.text.start) 
    *(.*) 
    } > BRAM
}

