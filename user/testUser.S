.globl main
main:

    li t0, 0
    csrw mstatus, t0
    j main