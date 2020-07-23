	#
        # interrupts and exceptions while in supervisor
        # mode come here.
        #
        # push all registers, call kerneltrap(), restore, return.
        #
err: .string "uservec"
.globl userTrap
.globl uservec
.globl current_process
.globl pd
.globl SystemStack
.align 4
uservec:

        csrw mscratch, sp       # save user stack pointer into mscratch
        la sp, SystemStack      # load system stack pointer into sp, we have changed the stack from user to kernel
        addi sp, sp, -16
        sd t1, 0(sp)
        sd t0, 8(sp)

        la t0, current_process
        ld t0, 0(t0)            # get PID into t0
        li t1, 280              # sizeof each pd entry - 280
        mul t0, t0, t1          # get offset into pd (i.e. process table)
        la t1, pd
        add t0, t1, t0          # t0 <- addr(pd) + 280 * current_process
        ld t1, 0(sp)            # get back value of t1
        addi sp, sp, 8          # increment sp because we no longer store t1

        sd ra, 0(t0)            # save the registers.
                                # value of sp lies in mscratch, so save it in the last
        sd gp, 16(t0)
        sd tp, 24(t0)
                                # save t0 later, since we are using it now
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

        csrr t1, mscratch
        sd t1, 8(t0)            # store value of user stack pointer into the user save area
        csrr t1, mepc
        sd t1, 248(t0)          # store machine mode exception program counter
        csrr t1, satp
        sd t1, 256(t0)          # store page table address

        ld t1, 0(sp)            # load value of t0 from stack
        addi sp, sp, 8          # clear stack area
        sd t1, 32(t0)           # store value of t0 into the process table's save area

        call userTrap               # call the C trap handler in trap.c
        la a0, err              # we should never come back, in case we do panic !
        call panic

# DONT FORGET TO SET PREVIOUS PRIVILEGE TO USER
.globl ret_to_user
ret_to_user:

        la t0, current_process
        ld t0, 0(t0)            # get PID into t0
        li t1, 280              # sizeof each pd entry - 280
        mul t0, t0, t1          # get offset into pd (i.e. process table)
        la t1, pd
        add t0, t1, t0          # t0 <- addr(pd) + 280 * current_process

        ld t1, 248(t0)          # get mepc value
        csrw mepc, t1           # write mepc value
        ld t1, 256(t0)          # get page table address
        csrw satp, t1           # write page table address
        
        ld ra, 0(t0)
        ld sp, 8(t0)            # Load user sp value - stack would change after this
        ld gp, 16(t0)
        ld tp, 24(t0)
                                # Don't load process's t0 value yet since we are using it
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
        
        ld t0, 32(t0)           # Load process's t0 value now
        mret                    # Go to user space !