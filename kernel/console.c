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

// send one character to the uart.
void consputc(int c) {
    extern volatile int errorOccurred;

    if(errorOccurred) {
        for(;;)
          ;
    }

    if(c == BACKSPACE){
        // if the user typed backspace, overwrite with a space.
        uartputc('\b'); uartputc(' '); uartputc('\b');
    }
    else {
        uartputc(c);
    }
}

// the console input interrupt handler.
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
void consoleintr(int c) {
    switch(c){
    case C('U'):  // Kill line.
        while(cons.e != cons.w &&
              cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
          cons.e--;
          consputc(BACKSPACE);
        }
        break;
        
    case C('H'): // Backspace
    case '\x7f':
        if(cons.e != cons.w){
            cons.e--;
            consputc(BACKSPACE);
        }
        break;
        
    default:
      if(c != 0 && cons.e-cons.r < INPUT_BUF){
            c = (c == '\r') ? '\n' : c;

            // echo back to the user.
            consputc(c);

            // store for consumption by consoleread().
            cons.buf[cons.e++ % INPUT_BUF] = c;

            if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
                // wake up consoleread() if a whole line (or end-of-file)
                // has arrived.
                cons.w = cons.e;
            }
        }

        break;
    }
}

void consoleinit(void) {
    uartinit();
}
