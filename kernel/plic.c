#include "declarations.h"
#include "functions.h"

// The RISCV Platform Level Interrupt Controller - PLIC

// Set up Platfrom Level Interrupt Controller
void plicinit(void) {
    *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
}

// Set up PLIC to perform device interrupts
void plicinithart(void) {
    int hart = CPUID;
    *(uint32*)PLIC_MENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    *(uint32*)PLIC_MPRIORITY(hart) = 0;
}

// Return a Bitmap of which IRQs are waiting to be served
uint64 plic_pending(void) {
    uint64 mask;
    mask = *(uint64*)PLIC_PENDING;
    return mask;
}

// Ask the PLIC what interrupt we should serve
int plic_claim(void) {
    int hart = CPUID;
    int irq = *(uint32*)PLIC_MCLAIM(hart);
    return irq;
}

// Tell the PLIC we've served this IRQ
void plic_complete(int irq) {
    int hart = CPUID;
    *(uint32*)PLIC_MCLAIM(hart) = irq;
}
