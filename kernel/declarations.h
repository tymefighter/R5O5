#ifndef DECL
#define DECL

// Global

#define NULL 0
typedef enum Bool {True = 1, False = 0} Bool;

// Types
// ----------------------------------------------------------------------------

typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int  uint32;
typedef unsigned long uint64;

// System
// ----------------------------------------------------------------------------

// System Parameters
#define NREG        31                  // Number of Registers
#define BSIZE       1024                // Disk Block Size
#define PGSIZE      4096                // Bytes per Page
#define PGSHIFT     12                  // Bits of Offset within a Page
#define DISKSIZE    1000                // size of disk in blocks
#define CPUID       0
#define MAXOPBLOCKS 10                  // max # of blocks any op writes

// Bits in Machine Status Register, mstatus
#define MSTATUS_MPP_MASK (3L << 11) // previous mode.
#define MSTATUS_MPP_M (3L << 11)    // machine-mode previous privilege is machine
#define MSTATUS_MPP_S (1L << 11)    // machine-mode previous privilege is superv
#define MSTATUS_MPP_U (0L << 11)    // machine-mode previous privilege is user
#define MSTATUS_MIE (1L << 3)       // machine-mode interrupt enable
#define MSTATUS_MPIE (1L << 7)      // machine-mode previous interrupt enable

// Bits in Machine-mode Interrupt Enable, mie
#define MIE_MEIE (1L << 11)             // external interrupt
#define MIE_MTIE (1L << 7)              // timer interrupt
#define MIE_MSIE (1L << 3)              // software interrupt

// Paging
// ----------------------------------------------------------------------------

// Number of Page Table Entries per Page Directory
#define NUM_PTE 512

// Page Table Entry Flags
#define PTE_V (1L << 0) // Entry is valid
#define PTE_R (1L << 1) // Read Access
#define PTE_W (1L << 2) // Write Access
#define PTE_X (1L << 3) // Execute Access
#define PTE_U (1L << 4) // User can access

typedef uint64 VirtualAddress;      // 64 bit Virtual Address
typedef uint64 PhysicalAddress;     // 64 bit Physical Address
typedef uint64 PageTableEntry;      // Page Table Entry (64 - bit)

typedef struct PageDirectory {      // Page Directory (512 Page Table Entries)
    PageTableEntry pageTableEntry[NUM_PTE];
} __attribute__((packed)) PageDirectory;
// attribute: Pack it completely (no padding)

typedef PageDirectory PageTable;    // Page Table - Root Page Directory

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
typedef struct Buffer {
    int valid;          // has data been read from disk?
    int disk;           // does disk "own" buf?
    uint blockno;
    uint refcnt;
    struct Buffer *prev;   // LRU cache list
    struct Buffer *next;
    struct Buffer *qnext;
    uchar data[BSIZE];
} Buffer;

// Buffer Cache
typedef struct BufferCache {
    Buffer buf[NBUF];
    // Linked list of all buffers, through prev/next.
    // head.next is most recently used.
    Buffer head;
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

extern volatile int errorOccurred;
extern char digits[];

// Save Area
// ----------------------------------------------------------------------------

// Kernal SaveArea
typedef struct KernelSaveArea {
    uint64 reg[NREG];           // Register Save Area
    uint64 epc;                 // Exception Program Counter
    uint64 mstatus;             // Value of mstatus register
} __attribute__((packed)) KernelSaveArea;

extern KernelSaveArea ksa;

// user Save area
typedef struct UserSaveArea {
    uint64 ia;                  // program counter
    uint psw;                   // program status word
                                // [bit 0 indicates user[0] or kernel[1] mode]
                                // [bit 1 indicates interrupts disabled[0] or enabled]
    // PageTable* pagetable;
    uint64 reg[NREG];           // SOS mentions 32 but NREG is 31, okay?
} UserSaveArea;

// Debug
// ----------------------------------------------------------------------------

#define LOGSTART 900

extern int block_no, off;

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
extern char end[];  // Location where kernel ends (from here free pages start)

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
        Buffer *b;
        char status;
    } info[NUM];

} __attribute__ ((aligned (PGSIZE))) Disk;

extern Disk disk;

// Memory Allocator
// ----------------------------------------------------------------------------

// A linked list node which would represent
// a memory page

// Ceil of end divided by PGSIZE
#define START_PAGE (((uint64)end + PGSIZE - 1) / PGSIZE)
// End of free page area (but we use only 500 pages and not entire free area)
#define END_PAGE (PHYSTOP / PGSIZE)
// Number of Free Pages
#define NUM_PAGES (500)

typedef uint64 PageNode;

extern PageNode pages[NUM_PAGES];
extern int currFreePageNode, numFreePages;

// ELF
// -----------------------------------------------------------------------------

// Format of an ELF executable file

#define ELF_MAGIC 0x464C457FU  // "\x7FELF" in little endian

// File header
typedef struct Elfhdr {
  uint magic;       // must equal ELF_MAGIC
  uchar elf[12];
  ushort type;
  ushort machine;
  uint version;
  uint64 entry;
  uint64 phoff;
  uint64 shoff;
  uint flags;
  ushort ehsize;
  ushort phentsize;
  ushort phnum;
  ushort shentsize;
  ushort shnum;
  ushort shstrndx;
} Elfhdr;

// Program section header
typedef struct Proghdr {
  uint32 type;
  uint32 flags;
  uint64 off;   // Offset of program section within ELF file
  uint64 vaddr; // Virtual Address where corresponding section must be loaded
  uint64 paddr; // Physical Address - To Be Ignored
  uint64 filesz;// Size of program section
  uint64 memsz; // Size of memory of program section
  uint64 align;
} Proghdr;

// ELF Reader - Doubly Linked List Node of the Linked List
// which would be returned by elf reader function
typedef struct Elfread {
  uint64 off;   // Offset of program section within ELF file
  uint64 vaddr; // Virtual Address where corresponding section must be loaded
  uint64 filesz;// Size of program section
  uint64 memsz; // Size of memory of program section
  struct Elfread *prev, *next;
} Elfread;

// ELF Reader List - Doubly Linked List
typedef struct ElfreadList {
  Elfread *head, *tail;
} ElfreadList;

// maximum number of ElfRead nodes that can be
// allocated
#define ELFSIZE                 30

// Values for Proghdr type
#define ELF_PROG_LOAD           1

// Flag bits for Proghdr flags
#define ELF_PROG_FLAG_EXEC      1
#define ELF_PROG_FLAG_WRITE     2
#define ELF_PROG_FLAG_READ      4

extern Elfread elfNodes[ELFSIZE];

#endif
