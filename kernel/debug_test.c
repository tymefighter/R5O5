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

// This is called by dump_reg_state function
void printTempRegState() {
    // Just print the registers here
    printf("The register content is: \n");
    printf("ra %l\n",temp_reg_state[0]);
    printf("sp %l\n",temp_reg_state[1]);
    printf("gp = %l\n",temp_reg_state[2]);
    printf("tp = %l\n",temp_reg_state[3]);
    printf("t0 = %l\n",temp_reg_state[4]);
    printf("t1 = %l\n",temp_reg_state[5]);
    printf("t2 = %l\n",temp_reg_state[6]);
    printf("s0 = %l\n",temp_reg_state[7]);
    printf("s1 = %l\n",temp_reg_state[8]);
    printf("a0 = %l\n",temp_reg_state[9]);
    printf("a1 = %l\n",temp_reg_state[10]);
    printf("a2 = %l\n",temp_reg_state[11]);
    printf("a3 = %l\n",temp_reg_state[12]);
    printf("a4 = %l\n",temp_reg_state[13]);
    printf("a5 = %l\n",temp_reg_state[14]);
    printf("a6 = %l\n",temp_reg_state[15]);
    printf("a7 = %l\n",temp_reg_state[16]);
    printf("s2 = %l\n",temp_reg_state[17]);
    printf("s3 = %l\n",temp_reg_state[18]);
    printf("s4 = %l\n",temp_reg_state[19]);
    printf("s5 = %l\n",temp_reg_state[20]);
    printf("s6 = %l\n",temp_reg_state[21]);
    printf("s7 = %l\n",temp_reg_state[22]);
    printf("s8 = %l\n",temp_reg_state[23]);
    printf("s9 = %l\n",temp_reg_state[24]);
    printf("s10 = %l\n",temp_reg_state[25]);
    printf("s11 = %l\n",temp_reg_state[26]);
    printf("s12 = %l\n",temp_reg_state[27]);
    printf("t3 = %l\n",temp_reg_state[28]);
    printf("t4 = %l\n",temp_reg_state[29]);
    printf("t5 = %l\n",temp_reg_state[30]);
    printf("t6 = %l\n",temp_reg_state[31]);
    return;
}

// example usage of dump register state
//   asm("addi sp, sp, -8\n"
//   "sd t0, 0(sp)\n"
//   "la t0, temp_reg_state\n"
//   "sd ra, 0(t0)\n"
//   "ld t0, 0(sp)\n"
//   "addi sp, sp, 8\n"
//   "jal dump_reg_state\n"
//   "addi sp, sp, -8\n"
//   "sd t0, 0(sp)\n"
//   "la t0, temp_reg_state\n"
//   "ld ra, 0(t0)\n"
//   "ld t0, 0(sp)\n"
//   "addi sp, sp, 8\n")