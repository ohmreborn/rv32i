
// The compiler automatically saves/restores required registers and adds mret

int main(void) {
  while (1)
    ;
  return 0;
}

__attribute__((interrupt("machine"))) void LED_IRQ_Handler(void) { main(); }
