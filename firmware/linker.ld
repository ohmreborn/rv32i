OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x0; 
  .everything : 
  { 
    *(.text) 
    } 
}

