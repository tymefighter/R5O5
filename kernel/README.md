## The following files do not interact with the system yet: -

- proc_table.h
- kernelSaveArea.h

## For Printing the register state, do as follows: -

- save the 'ra' register in the save area: -

```c
asm("addi sp, sp, -8\n"
  "sd t0, 0(sp)\n"
  "la t0, temp_reg_state\n"
  "sd ra, 0(t0)\n"
  "ld t0, 0(sp)\n"
  "addi sp, sp, 8\n"
  "jal dump_reg_state\n"
  "addi sp, sp, -8\n"
  "sd t0, 0(sp)\n"
  "la t0, temp_reg_state\n"
  "ld ra, 0(t0)\n"
  "ld t0, 0(sp)\n"
  "addi sp, sp, 8\n");
```

- call dump_reg_state

## For printing log information, use the 'log_data' function