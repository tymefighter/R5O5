#include "declarations.h"

// System Stack
// ----------------------------------------------------------------------------

__attribute__ ((aligned (16))) char SystemStack[4096 * NCPU];

// Buffer
// ----------------------------------------------------------------------------

// The Buffer Cache
BufferCache bcache;

// Console
// ----------------------------------------------------------------------------

// Contains all information about the console
Console cons;

// Print
// ----------------------------------------------------------------------------

char digits[] = "0123456789abcdef";

// Save Area
// ----------------------------------------------------------------------------

// Kernel Save Area
KernelSaveArea ksa;

// Disk
// ----------------------------------------------------------------------------

// Contains All information about the disk
Disk disk;

// Print
// ----------------------------------------------------------------------------
volatile int errorOccurred = 0;

// Debug
// ----------------------------------------------------------------------------

uint64 block_no, off; // current unused log block, offset this current block

// Memory Allocator
// ----------------------------------------------------------------------------

// Stack of Pages implemented using a fixed length array
PageNode pages[NUM_PAGES];
// Number of Available Free Pages
uint64 numFreePages;
// Index of page node at the top of the stack of pages
uint64 currFreePageNode;

// ELF Reader
// ----------------------------------------------------------------------------

Elfread elfNodes[ELFSIZE];

// Process Table
// ----------------------------------------------------------------------------

ProcessDescriptor pd[NPROC];
uint64 currentProcess = 0;
