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

    

    uint64 addr = (uint64)kernelvec;
    uint64 page = getPhyPage(addr);
    pd[0].slotAllocated = True;
    PageTable *abc = allocatePageTable();
    printf("%p|||\n", abc);
    pd[0].sa.epc = addr;
    pd[0].state = READY;
    pd[0].sa.reg[1] = (allocatePage() << 12) + PGSIZE;
    mapVirtualPage(abc, page, page, True, True, True);
    pd[0].sa.satp = MAKE_SATP(abc);
    dispatcher();

    while(1)
        ; 
}
