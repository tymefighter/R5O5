# Interrupts in while in machine mode come here
# this code => push all registers, call kerneltrap(), restore, return.
.globl kernelTrap
.globl kernelvec
.globl ksa
.align 4
kernelvec:
 
        addi sp, sp, -8         # make room in the stack to save t0 value
        sd t0, 0(sp)
        la t0, ksa
              
        sd ra, 0(t0)            # save the registers.
                                # don't save sp now
        sd gp, 16(t0)
        sd tp, 24(t0)

        sd t1, 40(t0)
        sd t2, 48(t0)
        sd s0, 56(t0)
        sd s1, 64(t0)
        sd a0, 72(t0)
        sd a1, 80(t0)
        sd a2, 88(t0)
        sd a3, 96(t0)
        sd a4, 104(t0)
        sd a5, 112(t0)
        sd a6, 120(t0)
        sd a7, 128(t0)
        sd s2, 136(t0)
        sd s3, 144(t0)
        sd s4, 152(t0)
        sd s5, 160(t0)
        sd s6, 168(t0)
        sd s7, 176(t0)
        sd s8, 184(t0)
        sd s9, 192(t0)
        sd s10, 200(t0)
        sd s11, 208(t0)
        sd t3, 216(t0)
        sd t4, 224(t0)
        sd t5, 232(t0)
        sd t6, 240(t0)

        ld t1, 0(sp)            # get value of t0
        addi sp, sp, 8          # clear stack space
        sd sp, 8(t0)            # save sp now
        sd t1, 32(t0)           # store value of t0 into the save area
	                        
        call kernelTrap               # call the C trap handler in trap.c

        la t0, ksa              # load address of kernel save area into t0
                                
        ld ra, 0(t0)            # restore registers.
        ld sp, 8(t0)
        ld gp, 16(t0)
        ld tp, 24(t0)

        ld t1, 40(t0)
        ld t2, 48(t0)
        ld s0, 56(t0)
        ld s1, 64(t0)
        ld a0, 72(t0)
        ld a1, 80(t0)
        ld a2, 88(t0)
        ld a3, 96(t0)
        ld a4, 104(t0)
        ld a5, 112(t0)
        ld a6, 120(t0)
        ld a7, 128(t0)
        ld s2, 136(t0)
        ld s3, 144(t0)
        ld s4, 152(t0)
        ld s5, 160(t0)
        ld s6, 168(t0)
        ld s7, 176(t0)
        ld s8, 184(t0)
        ld s9, 192(t0)
        ld s10, 200(t0)
        ld s11, 208(t0)
        ld t3, 216(t0)
        ld t4, 224(t0)
        ld t5, 232(t0)
        ld t6, 240(t0)

        ld t0, 32(t0)           # load t0's value into t0

        mret                    # return to whatever we were doing in the kernel.