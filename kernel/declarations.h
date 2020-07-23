#ifndef DECL
#define DECL

// Types
// ----------------------------------------------------------------------------

typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int  uint32;
typedef unsigned long uint64;

typedef uint64 pde_t;

// System
// ----------------------------------------------------------------------------

// System Parameters
#define NREG        31                  // Number of Registers
#define BSIZE       1024                // Disk Block Size
#define PGSIZE      4096                // Bytes per Page
#define PGSHIFT     12                  // Bits of Offset within a Page
#define FSSIZE    1000                // size of disk in blocks
#define CPUID       0
#define MAXOPBLOCKS 10                  // max # of blocks any op writes

// Machine Status Register, mstatus
#define MSTATUS_MPP_MASK (3L << 11)     // previous mode.
#define MSTATUS_MPP_M (3L << 11)
#define MSTATUS_MPP_S (1L << 11)
#define MSTATUS_MPP_U (0L << 11)
#define MSTATUS_MIE (1L << 3)           // machine-mode interrupt enable.
#define MSTATUS_MPIE (1L << 7)

// Machine-mode Interrupt Enable
#define MIE_MEIE (1L << 11)             // external
#define MIE_MTIE (1L << 7)              // timer
#define MIE_MSIE (1L << 3)              // software

#define SATP_SV39 (8L << 60)
#define MAKE_SATP(pagetable) (SATP_SV39 | (((uint64)pagetable) >> 12))

#define PGROUNDUP(sz)  (((sz)+PGSIZE-1) & ~(PGSIZE-1))
#define PGROUNDDOWN(a) (((a)) & ~(PGSIZE-1))

#define PTE_V (1L << 0) // valid
#define PTE_R (1L << 1)
#define PTE_W (1L << 2)
#define PTE_X (1L << 3)
#define PTE_U (1L << 4) // 1 -> user can access

// shift a physical address to the right place for a PTE.
#define PA2PTE(pa) ((((uint64)pa) >> 12) << 10)
#define PTE2PA(pte) (((pte) >> 10) << 12)
#define PTE_FLAGS(pte) ((pte) & 0x3FF)

// extract the three 9-bit page table indices from a virtual address.
#define PXMASK          0x1FF // 9 bits
#define PXSHIFT(level)  (PGSHIFT+(9*(level)))
#define PX(level, va) ((((uint64) (va)) >> PXSHIFT(level)) & PXMASK)

// one beyond the highest possible virtual address.
// MAXVA is actually one bit less than the max allowed by
// Sv39, to avoid having to sign-extend virtual addresses
// that have the high bit set.
#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))

typedef uint64 pte_t;
typedef uint64 *pagetable_t; // 512 PTEs

// OS Parameters
// ----------------------------------------------------------------------------

#define MAXARG      32                  // max exec arguments
#define NBUF        (MAXOPBLOCKS*3)     // size of disk block cache
#define NCPU        1                   // maximum number of CPUs
#define NPROC       64                  // maximum number of processes

// System Stack
// ----------------------------------------------------------------------------

extern char SystemStack[4096 * NCPU];

// Buffer
// ----------------------------------------------------------------------------

// Single Buffer of Buffer Cache
typedef struct buf {
    int valid;          // has data been read from disk?
    int disk;           // does disk "own" buf?
    uint dev;
    uint blockno;
    uint refcnt;
    struct buf *prev;   // LRU cache list
    struct buf *next;
    struct buf *qnext;
    uchar data[BSIZE];
} buf;

// Buffer Cache
typedef struct BufferCache {
    buf buf[NBUF];
    // Linked list of all buffers, through prev/next.
    // head.next is most recently used.
    buf head;
} BufferCache;

extern BufferCache bcache;

// Console
// ----------------------------------------------------------------------------

#define BACKSPACE 0x100
#define C(x)  ((x)-'@')  // Control-x
#define INPUT_BUF 128

// Console Structure
typedef struct Console {
char buf[INPUT_BUF];
    uint r;  // Read index
    uint w;  // Write index
    uint e;  // Edit index
} Console;

extern Console cons;

// Print
// ----------------------------------------------------------------------------

extern volatile int panicked;
extern char digits[];

// Save Area
// ----------------------------------------------------------------------------

// Kernal SaveArea
typedef struct kernelSaveArea {
uint64 reg[NREG];           // Register Save Area
uint64 epc;                 // Exception Program Counter
uint64 sstatus_value;       // Value of sstatus register
} kernelSaveArea;

// User Save Area
typedef struct UserSaveArea {
    uint64 reg[NREG];           // Register Save Area
    uint64 epc;                 // Exception Program Counter
    pagetable_t pt;             // Page Table Address
} UserSaveArea;

extern kernelSaveArea ksa;

// Processes
// ----------------------------------------------------------------------------

#define NumberOfProcesses 10
#define TimeQuantum 100000

enum ProcessState {Created, Ready, Running, Terminated};

typedef struct ProcessDescriptor {
    struct UserSaveArea sa;
    uint64 timeLeft;
    int slotAllocated;
    enum ProcessState state;
} ProcessDescriptor;

extern ProcessDescriptor pd[NumberOfProcesses];
extern int current_process;

// Memory Allocator
// ----------------------------------------------------------------------------

typedef struct FreePage {
    char *addr_start;
    struct FreePage *nextPage;
} FreePage;

typedef struct FreePageList {
    FreePage *start;
    int num_free_pages;
} FreePageList;

extern FreePageList freePageLists;

// Debug
// ----------------------------------------------------------------------------

#define LOGSTART 900

extern int block_no, off;
extern uint64 temp_reg_state[NREG];

// Memory Layout
// ----------------------------------------------------------------------------

// Physical memory layout
//
// 00001000 -- boot ROM, provided by qemu
// 02000000 -- CLINT
// 0C000000 -- PLIC
// 10000000 -- uart0 
// 10001000 -- virtio disk 
// 80000000 -- boot ROM jumps here in machine mode
//             -kernel loads the kernel here
// unused RAM after 80000000.

// the kernel uses physical memory thus:
// 80000000 -- entry.S, then kernel text and data
// end -- start of kernel page allocation area
// PHYSTOP -- end RAM used by the kernel

// qemu puts UART registers here in physical memory.
#define UART0 0x10000000L
#define UART0_IRQ 10

// virtio mmio interface
#define VIRTIO0 0x10001000
#define VIRTIO0_IRQ 1

// local interrupt controller, which contains the timer.
#define CLINT 0x2000000L
#define CLINT_MTIMECMP(hartid) (CLINT + 0x4000 + 8*(hartid))
#define CLINT_MTIME (CLINT + 0xBFF8) // cycles since boot.

// qemu puts programmable interrupt controller here.
#define PLIC 0x0c000000L
#define PLIC_PRIORITY (PLIC + 0x0)
#define PLIC_PENDING (PLIC + 0x1000)
#define PLIC_MENABLE(hart) (PLIC + 0x2000 + (hart)*0x100)
#define PLIC_SENABLE(hart) (PLIC + 0x2080 + (hart)*0x100)
#define PLIC_MPRIORITY(hart) (PLIC + 0x200000 + (hart)*0x2000)
#define PLIC_SPRIORITY(hart) (PLIC + 0x201000 + (hart)*0x2000)
#define PLIC_MCLAIM(hart) (PLIC + 0x200004 + (hart)*0x2000)
#define PLIC_SCLAIM(hart) (PLIC + 0x201004 + (hart)*0x2000)

// the kernel expects there to be RAM
// for use by the kernel and user pages
// from physical address 0x80000000 to PHYSTOP.
#define KERNBASE 0x80000000L
#define PHYSTOP (KERNBASE + 128*1024*1024)
#define PROCESS_START (PHYSTOP + PGSIZE)
#define PROCESS_END (PHYSTOP + 20 * PGSIZE)

// UART
// ----------------------------------------------------------------------------

#define RHR 0 // receive holding register (for input bytes)
#define THR 0 // transmit holding register (for output bytes)
#define IER 1 // interrupt enable register
#define FCR 2 // FIFO control register
#define ISR 2 // interrupt status register
#define LCR 3 // line control register
#define LSR 5 // line status register

// the UART control registers are memory-mapped
// at address UART0. this macro returns the
// address of one of the registers.
#define RegUART(reg) ((volatile unsigned char *)(UART0 + reg))

#define ReadRegUART(reg) (*(RegUART(reg)))           // Read from register
#define WriteRegUART(reg, v) (*(RegUART(reg)) = (v)) // Write to register

// Disk
// ----------------------------------------------------------------------------

// virtio mmio control registers, mapped starting at 0x10001000.
// from qemu virtio_mmio.h
#define VIRTIO_MMIO_MAGIC_VALUE		    0x000   // 0x74726976
#define VIRTIO_MMIO_VERSION		        0x004   // version; 1 is legacy
#define VIRTIO_MMIO_DEVICE_ID		    0x008   // device type; 1 is net, 2 is disk
#define VIRTIO_MMIO_VENDOR_ID		    0x00c   // 0x554d4551
#define VIRTIO_MMIO_DEVICE_FEATURES	    0x010
#define VIRTIO_MMIO_DRIVER_FEATURES	    0x020
#define VIRTIO_MMIO_GUEST_PAGE_SIZE	    0x028   // page size for PFN, write-only
#define VIRTIO_MMIO_QUEUE_SEL		    0x030   // select queue, write-only
#define VIRTIO_MMIO_QUEUE_NUM_MAX	    0x034   // max size of current queue, read-only
#define VIRTIO_MMIO_QUEUE_NUM		    0x038   // size of current queue, write-only
#define VIRTIO_MMIO_QUEUE_ALIGN		    0x03c   // used ring alignment, write-only
#define VIRTIO_MMIO_QUEUE_PFN		    0x040   // physical page number for queue, read/write
#define VIRTIO_MMIO_QUEUE_READY		    0x044   // ready bit
#define VIRTIO_MMIO_QUEUE_NOTIFY	    0x050   // write-only
#define VIRTIO_MMIO_INTERRUPT_STATUS	0x060   // read-only
#define VIRTIO_MMIO_INTERRUPT_ACK	    0x064   // write-only
#define VIRTIO_MMIO_STATUS		        0x070   // read/write

// status register bits, from qemu virtio_config.h
#define VIRTIO_CONFIG_S_ACKNOWLEDGE	    1
#define VIRTIO_CONFIG_S_DRIVER		    2
#define VIRTIO_CONFIG_S_DRIVER_OK	    4
#define VIRTIO_CONFIG_S_FEATURES_OK	    8

// device feature bits
#define VIRTIO_BLK_F_RO                 5	/* Disk is read-only */
#define VIRTIO_BLK_F_SCSI               7	/* Supports scsi command passthru */
#define VIRTIO_BLK_F_CONFIG_WCE         11	/* Writeback mode available in config */
#define VIRTIO_BLK_F_MQ                 12	/* support more than one vq */
#define VIRTIO_F_ANY_LAYOUT             27
#define VIRTIO_RING_F_INDIRECT_DESC     28
#define VIRTIO_RING_F_EVENT_IDX         29

// this many virtio descriptors.
// must be a power of two.
#define NUM 8

struct VRingDesc {
    uint64 addr;
    uint32 len;
    uint16 flags;
    uint16 next;
};

#define VRING_DESC_F_NEXT  1    // chained with another descriptor
#define VRING_DESC_F_WRITE 2    // device writes (vs read)

struct VRingUsedElem {
    uint32 id;                  // index of start of completed descriptor chain
    uint32 len;
};

// for disk ops
#define VIRTIO_BLK_T_IN  0      // read the disk
#define VIRTIO_BLK_T_OUT 1      // write the disk

struct UsedArea {
    uint16 flags;
    uint16 id;
    struct VRingUsedElem elems[NUM];
};

// the address of virtio mmio register r.
#define RVIRT(r) ((volatile uint32 *)(VIRTIO0 + (r)))

typedef struct Disk {
    // memory for virtio descriptors &c for queue 0.
    // this is a global instead of allocated because it must
    // be multiple contiguous pages, which kalloc()
    // doesn't support, and page aligned.
    char pages[2*PGSIZE];
    struct VRingDesc *desc;
    uint16 *avail;
    struct UsedArea *used;

    // our own book-keeping.
    char free[NUM];  // is a descriptor free?
    uint16 used_idx; // we've looked this far in used[2..NUM].

    // track info about in-flight operations,
    // for use when completion interrupt arrives.
    // indexed by first descriptor index of chain.
    struct {
        buf *b;
        char status;
    } info[NUM];

} __attribute__ ((aligned (PGSIZE))) Disk;

extern Disk disk;

#endif