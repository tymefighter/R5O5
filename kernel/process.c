#include "declarations.h"
#include "functions.h"

// Initialize Process Desciptor Table
void procesDescriptorInit() {
    currentProcess = 0;
    for(int i = 0;i < NPROC;i++)
        pd[i].slotAllocated = False;
}

// Select a process to run based on round-robin scheduling
// method, the PID of the process selected to be run would
// be present in `currentProcess`
void selectProcessToRun() {

    if(
        pd[currentProcess].slotAllocated    // Slot is Allocated
        &&
        pd[currentProcess].state == READY   // Process is READY
        && 
        pd[currentProcess].timeLeft > 0     // Process has time left to run
    ) {
        pd[currentProcess].state = RUNNING; // Run `currentProcess` itself
        return;
    }

    currentProcess = (currentProcess + 1) % NPROC; // Start with next Process
    for(int i = 0; i < NPROC; i++){
        if(
            pd[currentProcess].slotAllocated    // Slot is Allocated
            &&
            pd[currentProcess].state == READY   // Process is READY
        ) {
            pd[currentProcess].timeLeft = TimeQuantum;  // Assign `TimeQuantum` time
            pd[currentProcess].state = RUNNING;         // Run `currentProcess` itself
            return;
        }
        
        currentProcess = (currentProcess + 1) % NPROC;  // Check next Process
    }

    error("selectProcessToRun: No Process To Run"); // No Process Found to Run
}

// Run the process with PID `currentProcess`
void runProcess() {
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

// First select a process to run, then run that process
void dispatcher() {
    selectProcessToRun();   // Select Process to Run
    runProcess();           // Run the process `currentProcess`
}
