# R5O5 - An Educational Operating System for RISCV Architecture

This repository contains the following: -

- `kernel`      : Directory containing source files of the OS
- `user`        : Direcotry containing user programs to be run on the OS
- `logs`        : Directory containing a C program which extracts the
logged information from the OS and places it in a log file r5o5.log in the
`logs` direcotry itself
- `mkfs`        : Directory which contains a C program which builds the disk image
`fs.img` of the Simulated System.
- `Makefile`    : File to build the binary of the OS and run it on the simulated
RISCV hardware using QEMU
- `information`   : Directory which would contain the blocks and offsets of the
user programs that would be loaded into the (emulated) disk. It basically
contains the information of the location of the user programs stored in
the emulated disk. This directory is initially empty, and would be populated
by `mkfs/r5o5_mkfs.c` when provided the binaries of the user programs.