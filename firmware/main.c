#include <stdint.h>

typedef struct
{
    uint8_t LED1;
    uint8_t LED2;
    uint8_t LED3;
    uint8_t LED4;
    uint8_t LED5;
} LED_Typedef;
#define IO_LEDS ((volatile LED_Typedef *)(0x1000))

void _start() {
    IO_LEDS->LED1 = 1;
    while(1) ;
}