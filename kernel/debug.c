#include "declarations.h"
#include "functions.h"

// Initialize Information Logging Mechanism
void logDataInit() {
    block_no = LOGSTART;
    off = 0;
}

// Write the string prt_str in the log area
// Successive writes would append the string
// to the strings written in the previous
// writes 
void logData(char *prt_str) {
    Buffer *buff = bread(block_no);

    while((*prt_str) != '\0') {
        if(off == BSIZE) {
            bwrite(buff);
            brelse(buff);
            block_no ++;
            off = 0;
            if(block_no == DISKSIZE)
                error("logData");

            buff = bread(block_no);
        }
        buff->data[off] = *prt_str;
        prt_str ++;
        off ++;
    }
    bwrite(buff);
    brelse(buff);
}