#include <stdint.h>

typedef struct {
  uint8_t LED1;
  uint8_t LED2;
  uint8_t LED3;
  uint8_t LED4;
  uint8_t LED5;
} LED_Typedef;
#define IO_LEDS ((volatile LED_Typedef *)(0x1000))

void blink(void) {
  IO_LEDS->LED3 = 0;
  IO_LEDS->LED4 = 0;
  IO_LEDS->LED5 = 0;
  IO_LEDS->LED1 = 1;
  return;
}

__attribute__((interrupt("machine"))) void LED_IRQ_Handler(void) {
  IO_LEDS->LED2 = 1;
  IO_LEDS->LED3 = 1;
  IO_LEDS->LED4 = 1;
  IO_LEDS->LED5 = 1;
  return;
}

int main(void) {
  blink();
  while (1)
    ;
  return 0;
}
