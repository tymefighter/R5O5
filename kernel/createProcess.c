#include "declarations.h"
#include "functions.h"

// Program Loader
// Loads the program stored in the disk at a particular
// location into the memory

// Takes as input the start block `startBlock`, offset into the
// start block `startOffset` where the program starts. Also takes
// as input `endBlock` and offset into the end block `endBlock` where
// the program ends (both are inclusive) and address of page table
// `pagetable` which would be correspond to the program being loaded
// Returns `True` if the loading was succesful, else returns `False`
Bool programLoader(
    uint64 startBlock,
    uint64 startOffset,
    uint64 endBlock,
    uint64 endOffset,
    PageTable *pagetable
) {
    ElfreadList elfReadList; // Linked List which would be provided by ELF header
    elfReader(startBlock, startOffset, endBlock, endOffset, &elfReadList);
    if(elfReadList.head == NULL) // If head is null then some error occurred
        return False;

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

        elfNode = elfNode->next;
    }

    return True;
}
