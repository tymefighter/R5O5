#include "declarations.h"
#include "functions.h"

void logDataInit() {
    block_no = LOGSTART;
    off = 0;
}

void logData(char *prt_str) {
    Buffer *buff = bread(-1, block_no);

    while((*prt_str) != '\0') {
        if(off == BSIZE) {
            bwrite(buff);
            brelse(buff);
            block_no ++;
            off = 0;
            if(block_no == DISKSIZE)
                error("logData: log blocks filled");

            buff = bread(-1, block_no);
        }
        buff->data[off] = *prt_str;
        prt_str ++;
        off ++;
    }

    bwrite(buff);
    brelse(buff);
}