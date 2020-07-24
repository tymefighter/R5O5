#include "declarations.h"
#include "functions.h"

// int block_no, off; // current unused log block, offset this current block
// uint64 temp_reg_state[NREG];

void log_data_init() {
    block_no = LOGSTART;
    off = 0;
}

void log_data(char *prt_str) {
    struct buf *buff = bread(-1, block_no);

    while((*prt_str) != '\0') {
        if(off == BSIZE) {
            bwrite(buff);
            brelse(buff);
            block_no ++;
            off = 0;
            if(block_no == FSSIZE)
                panic("log_data");

            buff = bread(-1, block_no);
        }
        buff->data[off] = *prt_str;
        prt_str ++;
        off ++;
    }
    bwrite(buff);
    brelse(buff);
}