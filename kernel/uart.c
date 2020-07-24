#include "declarations.h"
#include "functions.h"

// Low-Level Driver Routines for 16550a UART

// Initialize UART
void uartinit(void) {
    // disable interrupts.
    WriteRegUART(IER, 0x00);

    // special mode to set baud rate.
    WriteRegUART(LCR, 0x80);

    // LSB for baud rate of 38.4K.
    WriteRegUART(0, 0x03);

    // MSB for baud rate of 38.4K.
    WriteRegUART(1, 0x00);

    // leave set-baud mode,
    // and set word length to 8 bits, no parity.
    WriteRegUART(LCR, 0x03);

    // reset and enable FIFOs.
    WriteRegUART(FCR, 0x07);

    // enable receive interrupts.
    WriteRegUART(IER, 0x01);
}

// Write one output character to the UART
void uartputc(int c) {
    // wait for Transmit Holding Empty to be set in LSR.
    while((ReadRegUART(LSR) & (1 << 5)) == 0)
      ;
    WriteRegUART(THR, c);
}

// Read one input character from the UART
// Return -1 if none is waiting
int uartgetc(void) {
    if(ReadRegUART(LSR) & 0x01){
        // input data is ready.
        return ReadRegUART(RHR);
    }
    else {
        return -1;
    }
}

// `devintr` calls here when the uart interrupts
void uartintr(void) {
    while(1){
        int c = uartgetc();
        if(c == -1)
            break;
        consoleintr(c);
    }
}
