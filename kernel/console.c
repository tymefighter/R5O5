#include <stdarg.h>
#include "declarations.h"
#include "functions.h"

// Console input and output, to the uart.
// Reads are line at a time.
// Implements special input characters:
//   newline -- end of line
//   control-h -- backspace
//   control-u -- kill line
//   control-d -- end of file
//   control-p -- print process list

// Sends one character to UART
void consputc(int c) {
    extern volatile int errorOccurred;

    if(errorOccurred) {
        for(;;)
          ;
    }

    if(c == BACKSPACE) {
        uartputc('\b');
        uartputc(' ');
        uartputc('\b');
    }
    else
        uartputc(c);
}

// Console Input Interrupt Handler
void consoleintr(int c) {
    switch(c){
    case C('U'):
        while(cons.e != cons.w &&
              cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
          cons.e--;
          consputc(BACKSPACE);
        }
        break;
        
    case C('H'):
    case '\x7f':
        if(cons.e != cons.w){
            cons.e--;
            consputc(BACKSPACE);
        }
        break;
        
    default:
      if(c != 0 && cons.e-cons.r < INPUT_BUF){
            c = (c == '\r') ? '\n' : c;

            consputc(c);
            cons.buf[cons.e++ % INPUT_BUF] = c;

            if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF)
                cons.w = cons.e;
        }

        break;
    }
}

// Initialize Console
void consoleinit(void) {
    uartinit();
}
