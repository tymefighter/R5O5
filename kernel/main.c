#include "declarations.h"
#include "functions.h"

// Main - Here is where the control passes
// from entry.S
void main() {
    w_satp(0);                      // Disable Paging

    consoleinit();                  // Set up Console
    printf("\nR5O5 kernel is booting\n\n");
    kernelInterruptInit();          // Set up Kernel Interrupt Handler
    plicinit();                     // Set up Interrupt Controller
    plicinithart();                 // Set up PLIC to perform device interrupts
    binit();                        // Set up Buffer Cache
    diskInit();                     // Set up the Disk Driver
    logDataInit();                  // Set up Information Logging Mechanism
    pageAllocInit();                // Set up Page Allocator

    logData("This data would be placed into the disk \
    \nfrom the starting of the log blocks\n");
    printf("done !\n");

    while(1)
        ; 
}
