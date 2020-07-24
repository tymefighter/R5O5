#include "declarations.h"
#include "functions.h"

// set up to take exceptions and traps while in the kernel.
void kernelInterruptInit(void) {
    intr_all_off();
    w_mtvec((uint64)kernelvec); // must be 4-byte aligned to fit in mtvec.
}

void devintr() {
    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ)
        uartintr();
    else if(irq == VIRTIO0_IRQ)
        virtio_disk_intr();

    plic_complete(irq);
}

void kernelInterruptHandler() {
    uint64 mcause = r_mcause();
    if(mcause & (1ull << 63ull)) {
        if((mcause & ((1ull << 63ull) - 1)) != 11)
            panic("trap: Exception other than external");
        
        devintr();
    }
    else
        panic("trap: Exception Occurred");
}