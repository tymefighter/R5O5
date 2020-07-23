.globl temp_reg_state
.globl dump_reg_state

dump_reg_state:
    
    addi sp, sp, -8 # Get space in stack
    sd t0, 0(sp)
    la t0, temp_reg_state

    # ra: This won't save ra register since it should be saved by the caller
    # sp: We would save sp at the end
    sd gp, 16(t0)
    sd tp, 24(t0)
    # t0: We would also save t0 at the end
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

    addi t1, sp, 8      # Place original sp into t1
    sd t1, 8(t0)        # Saving sp

    ld t1, 0(sp)        # Place t0's original value into t1
    sd t1, 32(t0)       # Saving t0

    ld t1, 40(t0)       # Load t1 back
    ld t0, 0(sp)        # Load t0 back
    addi sp, sp, 8

    addi sp, sp, -128   # Need to save ra, t0 - t6, a0 - a7, since they are caller saved
    sd ra, 0(sp)
    sd t0, 8(sp)
    sd t1, 16(sp)
    sd t2, 24(sp)
    sd t3, 32(sp)
    sd t4, 40(sp)
    sd t5, 48(sp)
    sd t6, 56(sp)
    sd a0, 64(sp)
    sd a1, 72(sp)
    sd a2, 80(sp)
    sd a3, 88(sp)
    sd a4, 96(sp)
    sd a5, 104(sp)
    sd a6, 112(sp)
    sd a7, 120(sp)

    jal printTempRegState

    ld ra, 0(sp)
    ld t0, 8(sp)
    ld t1, 16(sp)
    ld t2, 24(sp)
    ld t3, 32(sp)
    ld t4, 40(sp)
    ld t5, 48(sp)
    ld t6, 56(sp)
    ld a0, 64(sp)
    ld a1, 72(sp)
    ld a2, 80(sp)
    ld a3, 88(sp)
    ld a4, 96(sp)
    ld a5, 104(sp)
    ld a6, 112(sp)
    ld a7, 120(sp)
    addi sp, sp, 128

    addi sp, sp, 8      # Release the space used
    jr ra               # jump back to caller