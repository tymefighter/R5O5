#include "declarations.h"
#include "functions.h"

// Main - Here is where the control passes
// from entry.S
void main() {

    consoleinit();                  // Set up Console
    printf("\nR5O5 kernel is booting\n\n");
    kernelInterruptInit();          // Set up Kernel Interrupt Handler
    plicinit();                     // Set up Interrupt Controller
    plicinithart();                 // Set up PLIC to perform device interrupts
    binit();                        // Set up Buffer Cache
    diskInit();                     // Set up the Disk Driver
    logDataInit();                  // Set up Information Logging Mechanism
    pageAllocInit();                // Set up Page Allocator
    procesDescriptorInit();         // Set up Process Descriptor Table

    logData("This data would be placed into the disk \
    \nfrom the starting of the log blocks\n");
    printf("done !\n");

    #define SATP_SV39 (8L << 60)
    #define MAKE_SATP(pagetable) (SATP_SV39 | (((uint64)pagetable) >> 12))

    uint64 addr = (uint64)kernelvec;
    uint64 page = getPhyPage(addr);
    pd[0].slotAllocated = True;
    pd[0].sa.satp = allocatePageTable();
    pd[0].sa.epc = addr;
    pd[0].state = READY;
    pd[0].sa.reg[1] = (allocatePage() << 12) + PGSIZE;
    mapVirtualPage(pd[0].sa.satp, page, allocatePage(), True, True, True);
    pd[0].sa.satp = (PageTable *)MAKE_SATP(pd[0].sa.satp);
    dispatcher();

    while(1)
        ; 
}
