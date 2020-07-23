#include "declarations.h"
#include "functions.h"

void
main()
{
    w_satp(0);

    consoleinit();
    printf("\n");
    printf("xv6 kernel is booting\n");
    printf("\n");
    trapinithart();                 // install kernel trap vector
    plicinit();                     // set up interrupt controller
    plicinithart();                 // ask PLIC for device interrupts
    binit();                        // buffer cache
    virtio_disk_init();             // emulated hard disk
    log_data_init();
    log_data("This data would be placed into the disk\nfrom the starting of the log blocks\n");

    printf("done !\n");
    while(1); 
}