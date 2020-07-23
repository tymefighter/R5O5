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
kernelSaveArea ksa;

// Disk
// ----------------------------------------------------------------------------

// Contains All information about the disk
Disk disk;

// Print
// ----------------------------------------------------------------------------
volatile int errorOccurred = 0;

// Debug
// ----------------------------------------------------------------------------

int block_no, off; // current unused log block, offset this current block