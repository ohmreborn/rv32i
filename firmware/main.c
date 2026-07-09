#include <stdint.h>

#define IO_LEDS (*(volatile uint32_t *)0x1000)

void _start() {
    while(1) {
        IO_LEDS = 1;
    }
}