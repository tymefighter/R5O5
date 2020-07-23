#include "declarations.h"
#include "functions.h"

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

// write one output character to the UART.
void uartputc(int c) {
    // wait for Transmit Holding Empty to be set in LSR.
    while((ReadRegUART(LSR) & (1 << 5)) == 0)
        ;
    WriteRegUART(THR, c);
}

// read one input character from the UART.
// return -1 if none is waiting.
int uartgetc(void) {
    if(ReadRegUART(LSR) & 0x01) {
        // input data is ready.
        return ReadRegUART(RHR);
    }
    else {
        return -1;
    }
}

// trap.c calls here when the uart interrupts.
void uartintr(void) {
    while(1) {
        int c = uartgetc();
        if(c == -1)
            break;
        consoleintr(c);
    }
}
