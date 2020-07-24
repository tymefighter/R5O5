#include "declarations.h"
#include "functions.h"

// Disable All Interrupts and place location of the 
// kernel interrupt vector into the mtvec register
void kernelInterruptInit(void) {
    intr_all_off();
    w_mtvec((uint64)kernelvec);
}

// External Device Interrupt Handler
void devintr() {
    int irq = plic_claim();         // irq indicates which device interrupted

    if(irq == UART0_IRQ)            // UART Device
        uartintr();
    else if(irq == VIRTIO0_IRQ)     // Disk Device
        diskIntr();

    plic_complete(irq);
}

// Interrupt Handler for Kernel Mode Interrupts
// Currenlty Supports only device interrupts
void kernelInterruptHandler() {
    uint64 mcause = r_mcause();     // Get the cause of exception/interrupt

    // Check if is an interrupt or exception
    if(mcause & (1ull << 63ull)) {  // Interrupt

        // If not an external interrupt, then error out
        if((mcause & ((1ull << 63ull) - 1)) != 11)
            error("trap: Exception other than external");
        
        // Handle the device interrupt
        devintr();
    }
    else                            // Exception
        error("trap: Exception Occurred");
}