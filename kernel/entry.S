.section .data
.globl SystemStack
.section .text
.globl main
.section .text
.globl _entry
_entry:
	# set up the kernel stack
        la sp, SystemStack
        li a0, 1024*4
	csrr a1, mhartid
        addi a1, a1, 1
        mul a0, a0, a1
        add sp, sp, a0
        call main
junk:
        j junk
