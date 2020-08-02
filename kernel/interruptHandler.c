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
    intr_all_off();                 // Switch off all interrupts
    uint64 mcause = r_mcause();     // Get the cause of exception/interrupt

    // Check if is an interrupt or exception
    // 0x8000000000000000L -> 63rd bit is set (0-index based)
    if(mcause & 0x8000000000000000L) {  // Interrupt

        // If not an external interrupt, then error out
        if((mcause & 0xff) != 11)
            error("trap: Exception other than external");
        
        // Handle the device interrupt
        devintr();
    }
    else                            // Exception
        error("trap: Exception Occurred");
}

// Handle a systemcall or timer interrupt from user space
// It is called from uservec.S
void userInterruptHandler(void)
{
    // all interrupts are disabled in the kernel mode
    intr_all_off();
    w_mtvec((uint64)kernelvec);
    
    uint64 mcause = r_mcause();     // Get the cause of exception/interrupt

    if((mcause & MSTATUS_MPP) != 0)
        error("userInterruptHandler: not from user mode");

    // save user page table register
    pd[currentProcess].sa.satp = (PageTable *)r_satp();
    // save user program counter
    pd[currentProcess].sa.epc = r_mepc();
    
    // Check if is an interrupt or exception
    // 0x8000000000000000L -> 63rd bit is set (0-index based)
    if(mcause & 0x8000000000000000L) {  // Interrupt

        if((mcause & 0xff) == 7)  // machine timer interrupt
            ;// dispatcher();
        else
            error("userInterruptHandler: undefined interrupt occured");
    }
    else // Exception
        error("userInterruptHandler: Exception Occurred");
    
    // send syscalls, interrupts, and exceptions to uservec.S
    w_mtvec((uint64)uservec);

    uint64 x = r_mstatus();
    x &= ~MSTATUS_MPP;   // Previous Privilege is User Mode
    x |= MSTATUS_MPIE;   // Indicate that previously interrupts were enabled
    w_mstatus(x);

    // Enables machine mode timer interrupts in user mode
    w_mie(r_mie() | MIE_MTIE);
    
    // Restore satp from pagetable address of current process
    w_satp((uint64)pd[currentProcess].sa.satp);
    // Flush TLB
    sfence_vma();
    // Restore mepc from epc of current process
    w_mepc(pd[currentProcess].sa.epc);

    // Restores user page table and user register values
    // and finally enters user mode using mret.
    userret();
}
