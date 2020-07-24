#include "declarations.h"
#include "functions.h"

void main() {
    w_satp(0);

    consoleinit();
    kernelInterruptInit();          // install kernel trap vector
    plicinit();                     // set up interrupt controller
    plicinithart();                 // ask PLIC for device interrupts
    binit();                        // buffer cache
    virtio_disk_init();             // emulated hard disk
    logDataInit();
    logData("This data would be placed into the disk \
    \nfrom the starting of the log blocks\n");

    printf("done !\n");
    while(1)
        ; 
}