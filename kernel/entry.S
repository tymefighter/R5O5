.section .data
.globl SystemStack
.section .text
.globl main
.section .text
.globl _entry
_entry:
	# set up the kernel stack
        la sp, SystemStack
        li a0, 4096
        add sp, sp, a0
        call main
junk:
        j junk
