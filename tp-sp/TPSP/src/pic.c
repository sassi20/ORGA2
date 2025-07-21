/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
   // ICW1: Inicia configuración, modo cascada, espera ICW4
    outb(PIC1_PORT, 0x11); // PIC1
    outb(PIC2_PORT, 0x11); // PIC2

    // ICW2: Vector base de interrupciones
    outb(PIC1_PORT + 1, 0x20); // PIC1: IRQ0–IRQ7 → INT 32–39
    outb(PIC2_PORT + 1, 0x28); // PIC2: IRQ8–IRQ15 → INT 40–47

    // ICW3: Conexión entre PICs
    outb(PIC1_PORT + 1, 0x04); // PIC1: Slave en IRQ2
    outb(PIC2_PORT + 1, 0x02); // PIC2: Conectado al IRQ2 del PIC1

    // ICW4: Modo 8086, fin de interrupción normal
    outb(PIC1_PORT + 1, 0x01); // PIC1
    outb(PIC2_PORT + 1, 0x01); // PIC2

    // OCW1: Deshabilitar todas las IRQs por ahora
    outb(PIC1_PORT + 1, 0xFF); // PIC1
    outb(PIC2_PORT + 1, 0xFF); // PIC2
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
