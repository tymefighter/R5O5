	#
        # code to switch between user and kernel space.
    	#
.globl timeQuantum
.globl mtime
.globl mtimecmp
.globl userInterruptHandler
.globl SystemStack
.globl currentProcess
.globl pd    
.align 4
.globl uservec
uservec:    
        # interruptHandler.c sets mtvec to point here, so
        # traps from user space start here
        
	    # store a0 in mscratch
        csrw mscratch, a0

        la a0, pd		    # process table base address

    	addi sp, sp, -16
    	sd t0, 0(sp)
    	sd t1, 8(sp)

    	la t0, currentProcess
    	ld t0, 0(t0)
    	li t1, 280		    # size of an entry in pd is 280 bytes
    	mul t0, t0, t1
    	add a0, a0, t0		# current process savearea

        la t0, mtime        # get mtime address into t0
        ld t0, 0(t0)        # get mtime value into t0
        sd t0, 268(a0)      # store mtime value in pd[currentProcess].timeElapsed

    	ld t0, 0(sp)
    	ld t1, 8(sp)
    	addi sp, sp, 16		# sp restored
    	
        sd ra, 0(a0)
        sd sp, 8(a0)
        sd gp, 16(a0)
        sd tp, 24(a0)
        sd t0, 32(a0)
        sd t1, 40(a0)
        sd t2, 48(a0)
        sd s0, 56(a0)
    	sd s1, 64(a0)
    	# a0 will be saved later
        sd a1, 80(a0)
        sd a2, 88(a0)
        sd a3, 96(a0)
        sd a4, 104(a0)
        sd a5, 112(a0)
        sd a6, 120(a0)
        sd a7, 128(a0)
        sd s2, 136(a0)
        sd s3, 144(a0)
        sd s4, 152(a0)
        sd s5, 160(a0)
        sd s6, 168(a0)
        sd s7, 176(a0)
        sd s8, 184(a0)
        sd s9, 192(a0)
        sd s10, 200(a0)
        sd s11, 208(a0)
        sd t3, 216(a0)
        sd t4, 224(a0)
        sd t5, 232(a0)
        sd t6, 240(a0)

	    # restore  a0
        csrr t0, mscratch
        sd t0, 72(a0)

    	# switch to the system stack
        la sp, SystemStack
        li a0, 4096
        add sp, sp, a0

    	# mepc and satp will be saved in userInterruptHandler()
        # jump to userInterruptHandler(), which does not return
        j userInterruptHandler

.globl userret
userret:
        # switch from kernel to user.
        # userInterruptReturn() calls here.

        la a0, pd		    # process table base address
        ld t0, 0(t0)
    	li t1, 280		    # size of an entry in pd is 280 bytes
    	mul t0, t0, t1
    	add a0, a0, t0		# current process savearea

        ld t0, 268(a0)      # load timeElapsed
        la t1, mtime        # get address of mtime in t1
        sd t0, 0(t1)        # store time elapsed into mtime
        la t0, timeQuantum  # load address of timeQuantum into t0
        ld t0, 0(t0)        # load timeQuantum value into t0
        la t1, mtimecmp     # get address of mtimecmp in t1
        sd t0, 0(t1)        # store time quantum value into mtimecmp

        # restore all but a0 from savearea
        ld ra, 0(a0)
        ld sp, 8(a0)
        ld gp, 16(a0)
        ld tp, 24(a0)
        ld t0, 32(a0)
        ld t1, 40(a0)
        ld t2, 48(a0)
        ld s0, 56(a0)
    	ld s1, 64(a0)
    	# a0 will be restored later
        ld a1, 80(a0)
        ld a2, 88(a0)
        ld a3, 96(a0)
        ld a4, 104(a0)
        ld a5, 112(a0)
        ld a6, 120(a0)
        ld a7, 128(a0)
        ld s2, 136(a0)
        ld s3, 144(a0)
        ld s4, 152(a0)
        ld s5, 160(a0)
        ld s6, 168(a0)
        ld s7, 176(a0)
        ld s8, 184(a0)
        ld s9, 192(a0)
        ld s10, 200(a0)
        ld s11, 208(a0)
        ld t3, 216(a0)
        ld t4, 224(a0)
        ld t5, 232(a0)
        ld t6, 240(a0)

	    # restore user a0
        ld a0, 72(a0)
        
        # return to user mode and user pc.
        # userInterruptReturn() set up mstatus and mepc.
        mret
