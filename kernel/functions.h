#include "declarations.h"

// buffer.c
void            binit(void);
Buffer *        bread(uint);
void            brelse(Buffer *);
void            bwrite(Buffer *);
void            bpin(Buffer *);
void            bunpin(Buffer *);
void            readBytes(int, int, int, uchar *);
void            writeBytes(int, int, int, uchar *);

// console.c
void            consoleinit(void);
void            consoleintr(int);
void            consputc(int);

// print.c
void            printf(char*, ...);
void            error(char*) __attribute__((noreturn));
void            printfinit(void);

// string.c
void*           memset(void*, int, uint);

// interruptHandler.c
void            kernelInterruptInit(void);

// uart.c
void            uartinit(void);
void            uartintr(void);
void            uartputc(int);
int             uartgetc(void);

// plic.c
void            plicinit(void);
void            plicinithart(void);
uint64          plic_pending(void);
int             plic_claim(void);
void            plic_complete(int);

// disk.c
void            diskInit(void);
void            diskRW(Buffer *, int);
void            diskIntr();

// debug.c
void            logDataInit(void);
void            logData(char *prt_str);

// memoryAllocator.c
void            pageAllocInit(void);
Page *          allocatePage();
void            allocatePages(int, PageList *);
void            freePage(Page *);
void            freePages(PageList *);

// kernelvec.S
void            kernelvec(void);

// System Functions

// get current core
static inline 
uint64 r_mhartid() {
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r" (x) );
    return x;
}

static inline
uint64 r_mstatus() {
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    return x;
}

static inline
void w_mstatus(uint64 x) {
    asm volatile("csrw mstatus, %0" : : "r" (x));
}

// machine exception program counter, holds the
// instruction address to which a return from
// exception will go.
static inline
void w_mepc(uint64 x) {
    asm volatile("csrw mepc, %0" : : "r" (x));
}

static inline
uint64 r_mepc() {
    uint64 x;
    asm volatile("csrr %0, mepc" : "=r" (x) );
    return x;
}

static inline 
uint64 r_mie() {
    uint64 x;
    asm volatile("csrr %0, mie" : "=r" (x) );
    return x;
}

static inline 
void w_mie(uint64 x) {
    asm volatile("csrw mie, %0" : : "r" (x));
}

static inline 
uint64 r_mcause() {
    uint64 x;
    asm volatile("csrr %0, mcause" : "=r" (x) );
    return x;
}

static inline 
uint64 r_mip() {
    uint64 x;
    asm volatile("csrr %0, mip" : "=r" (x) );
    return x;
}

static inline 
void w_mip(uint64 x) {
    asm volatile("csrw mip, %0" : : "r" (x));
}

// Machine-mode interrupt vector
static inline 
void w_mtvec(uint64 x) {
    asm volatile("csrw mtvec, %0" : : "r" (x));
}

static inline 
uint64 r_mtvec() {
    uint64 x;
    asm volatile("csrr %0, mtvec" : "=r" (x) );
    return x;
}

// supervisor address translation and protection;
// holds the address of the page table.
static inline 
void w_satp(uint64 x) {
    asm volatile("csrw satp, %0" : : "r" (x));
}

static inline 
uint64 r_satp()
{
    uint64 x;
    asm volatile("csrr %0, satp" : "=r" (x) );
    return x;
}

// Supervisor Scratch register, for early trap handler in trampoline.S.
static inline 
void w_sscratch(uint64 x) {
    asm volatile("csrw sscratch, %0" : : "r" (x));
}

static inline 
void w_mscratch(uint64 x) {
    asm volatile("csrw mscratch, %0" : : "r" (x));
}

// Machine-mode Counter-Enable
static inline 
void w_mcounteren(uint64 x) {
    asm volatile("csrw mcounteren, %0" : : "r" (x));
}

static inline 
uint64 r_mcounteren() {
    uint64 x;
    asm volatile("csrr %0, mcounteren" : "=r" (x) );
    return x;
}

// machine-mode cycle counter
static inline
uint64 r_time() {
    uint64 x;
    asm volatile("csrr %0, time" : "=r" (x) );
    return x;
}

// enable device interrupts
static inline 
void intr_all_on() {
    w_mie(r_mie() | MIE_MEIE | MIE_MTIE | MIE_MSIE);
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_dev_on() {
    w_mie(r_mie() | MIE_MEIE);
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_timer_on() {
    w_mie(r_mie() | MIE_MTIE);
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_software_on() {
    w_mie(r_mie() | MIE_MSIE);
    w_mstatus(r_mstatus() | MSTATUS_MIE);
}

static inline 
void intr_all_off() {
    w_mstatus(r_mstatus() & ~(MSTATUS_MIE | MSTATUS_MPIE));
    w_mie(r_mie() & (~(MIE_MEIE | MIE_MTIE | MIE_MSIE)));
}

// are device interrupts enabled?
static inline 
int intr_get() {
    uint64 x = r_mstatus();
    return (x & MSTATUS_MIE) != 0;
}

static inline 
uint64 r_sp() {
    uint64 x;
    asm volatile("mv %0, sp" : "=r" (x) );
    return x;
}

// read and write tp, the thread pointer, which holds
// this core's hartid (core number), the index into cpus[].
static inline 
uint64 r_tp() {
    uint64 x;
    asm volatile("mv %0, tp" : "=r" (x) );
    return x;
}

static inline 
void w_tp(uint64 x) {
    asm volatile("mv tp, %0" : : "r" (x));
}

static inline 
uint64 r_ra() {
    uint64 x;
    asm volatile("mv %0, ra" : "=r" (x) );
    return x;
}

// flush the TLB.
static inline 
void sfence_vma() {
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
}
