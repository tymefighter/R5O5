#include "functions.h"

void main() {
    w_satp(0);          // Disable paging

    consoleinit();      // initialize console
    trapinithart();     // install kernel trap vector
    plicinit();         // set up interrupt controller
    plicinithart();     // ask PLIC for device interrupts
    binit();            // buffer cache
    diskInit();         // emulated hard disk
    logDataInit();      // Initialize logging mechanism

    printf("Done\n");
    while(1); 
}