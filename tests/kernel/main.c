#include "../../kernel/declarations.h"
#include "../../kernel/functions.h"

// Main - Here is where the control passes
// from entry.S
void main() {
    w_satp(0);                      // Disable Paging

    consoleinit();                  // Set up Console
    kernelInterruptInit();          // Set up Kernel Interrupt Handler
    plicinit();                     // Set up Interrupt Controller
    plicinithart();                 // Set up PLIC to perform device interrupts
    binit();                        // Set up Buffer Cache
    diskInit();                     // Set up the Disk Driver
    logDataInit();                  // Set up Information Logging Mechanism
    pageAllocInit();                // Set up Page Allocator

    testOS();                       // Test the OS

    while(1)
        ; 
}
