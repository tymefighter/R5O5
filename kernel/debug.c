#include "declarations.h"
#include "functions.h"

// int block_no, off; // current unused log block, offset this current block
// uint64 temp_reg_state[NREG];

void logDataInit() {
    block_no = LOGSTART;
    off = 0;
}

void logData(char *prt_str) {
    Buffer *buff = bread(block_no);

    while((*prt_str) != '\0') {
        if(off == BSIZE) {
            bwrite(buff);
            brelse(buff);
            block_no ++;
            off = 0;
            if(block_no == FSSIZE)
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