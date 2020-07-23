#include "declarations.h"
#include "functions.h"

// set up to take exceptions and traps while in the kernel.
void trapinithart(void) {
    intr_all_off();
    w_mtvec((uint64)kernelvec); // must be 4-byte aligned to fit in stvec.
}

void devintr() {
    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ)
        uartintr();
    else if(irq == VIRTIO0_IRQ)
        diskIntr();

    plic_complete(irq);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void kernelTrap() {
    uint64 mcause = r_mcause();
    if(mcause & (1ull << 63ull)) {
        if((mcause & ((1ull << 63ull) - 1)) != 11)
            error("kernelTrap: Exception other than external");
        
        devintr();
    }
    else
        error("kernalTrap: Exception Occurred");
}