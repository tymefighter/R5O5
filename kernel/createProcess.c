#include "declarations.h"
#include "functions.h"

// Program Loader
// Loads the program stored in the disk at a particular
// location into the memory

// Takes as input the start block `startBlock`, offset into the
// start block `startOffset` where the program starts. Also takes
// as input `endBlock` and offset into the end block `endBlock` where
// the program ends (both are inclusive) and pid of process
// `pid` which would be correspond to the program being loaded
// This would allocate page table, load the program, initialize
// entry point of program and stack of the program
// Returns `True` if the loading was succesful, else returns `False`
Bool programLoader(
    uint64 startBlock,
    uint64 startOffset,
    uint64 endBlock,
    uint64 endOffset,
    Pid pid
) {
    ElfreadList elfReadList; // Linked List which would be provided by ELF header
    elfReader(startBlock, startOffset, endBlock, endOffset, &elfReadList);
    if(elfReadList.head == NULL) // If head is null then some error occurred
        return False;

    
    PageTable *pagetable = allocatePageTable();
    pd[pid].sa.satp = MAKE_SATP(pagetable);  // Allocate Page Table
    pd[pid].sa.epc = elfReadList.entry;     // Entry Point into the program

    // Virtual Page Number where stack would begin
    // We get the largest virtual address + 1 value
    // and assign that virtual address page to this so that
    // there would be no allocated virtual address after this
    uint64 stackBeginVirtPage = 0;

    Elfread *elfNode = elfReadList.head; // Current ELF Node
    while(elfNode != NULL) { // Iterate over the linked list provided by ELF reader
        VirtualAddress virtualAddress = (VirtualAddress)elfNode->vaddr;
        uint64 off = elfNode->off + startOffset;
        uint64 memSize = elfNode->memsz;
        uint64 fileSize = elfNode->filesz;

        // This would allocate physical pages for all those virtual
        // addresses whose virtual pages have not been allocated
        // physical pages - Current implementation is slow
        for(int i = 0;i < memSize;i++) {
            VirtualAddress currVirt = virtualAddress + i;
            uint64 currVirtPage = getVirtPage(currVirt);
            if(!isVirtualPageAllocated(pagetable, currVirtPage))
                allocateVirtualPage(
                    pagetable,
                    currVirtPage,
                    True,   // Currently allow all permissions
                    True,   // i.e read, write and exec
                    True
                );

            printf("%l %l||||\n", currVirtPage, getPhyPage(virtualToPhysical(pagetable, currVirt)));
        }

        // Block and offset within the block where current
        // program section starts
        uint64 blockNum = startBlock + (off / BSIZE);
        uint64 blockOff =  off % BSIZE;

        // Load the Current Program Section from disk to memory
        readBytesVirtual(
            blockNum,   // Block in which section starts
            blockOff,   // Offset where section starts in block `blockNum`
            fileSize,                // Size of section in the disk
            (uchar *)virtualAddress, // Virt Addr of start of section
            pagetable   // Page Table of process into which program is loaded
        );

        stackBeginVirtPage = max(
            stackBeginVirtPage,
            ceilDiv((uint64)(virtualAddress + memSize), PGSIZE)
        );

        elfNode = elfNode->next;
    }

    // Allocate two pages for the stack
    // For now give all permissions to these pages
    allocateVirtualPage(pagetable, stackBeginVirtPage, True, True, True);
    allocateVirtualPage(pagetable, stackBeginVirtPage + 1, True, True, True);

    // Assign SP register the address of top stack
    pd[pid].sa.reg[1] = (stackBeginVirtPage << 12) + 2 * PGSIZE;

    return True;
}

// Takes as input the start block `startBlock`, offset into the
// start block `startOffset` where the program starts. Also takes
// as input `endBlock` and offset into the end block `endBlock` where
// the program ends. It then creates a process using the given program
// and returns the pid of the created process
Pid createProcess(
    uint64 startBlock,
    uint64 startOffset,
    uint64 endBlock,
    uint64 endOffset
) {
    Pid pid;
    for(pid = 0;pid < NPROC;pid++) { // Search for free entry
        if(!pd[pid].slotAllocated)
            break;
    }

    if(pid == NPROC) // No Free Entry Found
        error("createProcess: Process Table Filled");

    // Program was unsuccessful in loading into memory
    if(!programLoader(
        startBlock,
        startOffset,
        endBlock,
        endOffset,
        pid
    )) {
        error("createProcess: Program Loading was unsuccesful");
    }

    pd[pid].slotAllocated = True;   // Slot has been allocated now
    pd[pid].state = READY;          // Process is Ready to be run
    pd[pid].timeLeft = TimeQuantum; // Time the process is allowed to run for
    return pid;
}