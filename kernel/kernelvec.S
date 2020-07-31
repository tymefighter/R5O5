# Interrupts in while in machine mode come here
# this code => push all registers, call kerneltrap(), restore, return.
.globl kernelInterruptHandler 
.globl kernelvec   #this will  makes the kernelvec visible to linker or symbol name will be added to symbol table
.globl ksa       # kernel save area.
.align 4        #this will make each instruction of length 4 bytes
kernelvec:
 
        #In the following code t0 register is being used for storing and
        # retrieving registers nothing special about it any register will do the work.
        addi sp, sp, -8                 # make room in the stack to save t0 value as it's going to be used in the process of saving registers.
        sd t0, 0(sp)                    #Now store the to value in sp
        la t0, ksa                      #load the address of kernel save area into to register
              
        sd ra, 0(t0)                    # storing the return address in ksa.
                                        # save All the registers into kernel save area(As ksa address in t0 register).
                                        # don't save sp now
        sd gp, 16(t0)
        sd tp, 24(t0)
                                        #we skipped saving t0 register because t0 being itself used in the process of saving registers.
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
        sd t6, 240(t0)                  # now we saved all registers in ksa except t0 register and sp value.

        ld t1, 0(sp)                    # get value of t0
        addi sp, sp, 8                  # clear stack space that we used for storing the t0 register earlier.
        sd sp, 8(t0)                    # save sp now
        sd t1, 32(t0)                   # store value of t0 into the kernel save area
	                        
        call kernelInterruptHandler     # call the C trap handler in interruptHandler.c
        
        #once we are done with kernel interrupt it will resume from here.

        la t0, ksa                      # load address of kernel save area into t0
                                
        ld ra, 0(t0)                    #restoring the return address.
                                        # restore registers back.
        ld sp, 8(t0)                    # restore sp value.
        ld gp, 16(t0)
        ld tp, 24(t0)
        # same reason for skipping t0 register restoring is because it itself involved in the process.
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
