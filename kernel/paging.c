#include "declarations.h"
#include "functions.h"

// This file contains all the functions which would be
// help in paging

/*
    Virtual Address
    -----------------------------------------------------------
    |  unused: 25 | L2 (root): 9 | L1: 9 | L0: 9 | offset: 12 |
    -----------------------------------------------------------
    L2: Root page directory
    L1: Second level page directory
    L0: Final level page directory

    Virtual Page Number
    ---------------------------------------
    |  unused: 37 | L2: 9 | L1: 9 | L0: 9 |
    ---------------------------------------
    L2, L1 and L0 together determine the Virtual Page Number

    Physical Address
    -------------------------------------------------------
    |  unused: 8 | Physical Page Number : 44 | offset: 12 |
    -------------------------------------------------------

    Page Table Entry
    -------------------------------------------------------
    |  unused: 10  | Physcial Page Number: 44 | flags: 10 |
    -------------------------------------------------------
*/

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Waddress-of-packed-member"

// Get offset into a page, it is valid for both physical and virtual addresses
// Get least 12 bits
uint64 getOffset(uint64 addr) {
    return addr & 0x0000000000000fff;
}

// 27 bits left of Least 12 bits
uint64 getVirtPage(VirtualAddress virtualAddress) {
    return (virtualAddress & 0x0000007ffffff000) >> 12;
}

// 44 bits left of Least 12 bits
uint64 getPhyPage(PhysicalAddress physicalAddress) {
    return (physicalAddress & 0x00fffffffffff000) >> 12;
}

// Get L2 - Root page directory page table entry 
uint64 getL2(VirtualAddress virtualAddress) {
    return (virtualAddress & 0x0000007fc0000000) >> 30;
}

// Get L1 - Intermediate page directory page table entry 
uint64 getL1(VirtualAddress virtualAddress) {
    return (virtualAddress & 0x000000003fe00000) >> 21;
}

// Get L0 - Final page directory page table entry 
uint64 getL0(VirtualAddress virtualAddress) {
    return (virtualAddress & 0x00000000001ff000) >> 12;
}

// Get flags of a page table entry
uint64 getFlags(PageTableEntry pageTableEntry) {
    return pageTableEntry & 0x00000000000003ff;
}

// Get page number stored in a page table entry
uint64 getPageNum(PageTableEntry pageTableEntry) {
    return (pageTableEntry & 0x003ffffffffffc00) >> 10;
}

// Given address of page table entry, modify the
// contents of the address to set the page flag
// of the provided page table entry
// A thing to note: if any of the provided arguments
// are False, and if the flags were set, it would NOT
// unset the flags
// Eg. `addReadPermission` was False, and page table
// entry had read flag set, then after this function is called
// it would still have it set
void setFlags(
    PageTableEntry *pageTableEntry,
    Bool addReadPermission,
    Bool addWritePermission,
    Bool addExecutePermission
) {
    uint64 pageTableEntryValue = *pageTableEntry;

    if(addReadPermission)
        pageTableEntryValue |= PTE_R;
    if(addWritePermission)
        pageTableEntryValue |= PTE_W;
    if(addExecutePermission)
        pageTableEntryValue |= PTE_X;

    *pageTableEntry = pageTableEntryValue;
}

// Given address of page table entry, modify the
// contents of the address to set the page number
// of the provided page table entry, the flags are
// NOT changed (i.e. previous flags are maintained)
void setPageNum(PageTableEntry *pageTableEntry, uint64 pageNum) {
    *pageTableEntry = (pageNum << 10) | getFlags(*pageTableEntry);
}

// Allocate a page directory and initialize it with
// all empty page table entries by setting up
// page table entry flags
PageDirectory *allocatePageDirectory() {
    uint64 pageNum = allocatePage();
    PageDirectory *pageDir = (PageDirectory *)(pageNum << 12);

    // Make each page table entry INVALID
    for(int i = 0;i < NUM_PTE;i++)
        pageDir->pageTableEntry[i] &= (~PTE_V);

    return pageDir;
}

// Allocate a page directory and initialize it, then
// cast it as the page table
PageTable *allocatePageTable() {
    PageDirectory *pageDir = allocatePageDirectory();
    return (PageTable *)pageDir;
}

Bool isVirtualPageAllocated(
    PageTable *pagetable,
    uint64 virtualPageNum
) {
    VirtualAddress virtualAddress = (VirtualAddress) (virtualPageNum << 12);
    uint64 pteL2 = getL2(virtualAddress);
    
    if(!(getFlags(pagetable->pageTableEntry[pteL2]) & PTE_V))
        return False;

    PageDirectory *level1 = 
        (PageDirectory *)(getPageNum(pagetable->pageTableEntry[pteL2]) << 12);
    uint64 pteL1 = getL1(virtualAddress);

    if(!(getFlags(level1->pageTableEntry[pteL1]) & PTE_V))
        return False;

    PageDirectory *level0 = 
        (PageDirectory *)(getPageNum(level1->pageTableEntry[pteL1]) << 12);
    uint64 pteL0 = getL0(virtualAddress);

    if(!(getFlags(level0->pageTableEntry[pteL0]) & PTE_V))
        return False;
    
    return True;
}

// Map a virtual page of virtual page number `virtualPageNum`
// to a physical page of physical page number `physicalPageNum`
// in the page table 
void mapVirtualPage(
    PageTable *pagetable,
    uint64 virtualPageNum,
    uint64 physicalPageNum,
    Bool readPermission,
    Bool writePermission,
    Bool executePermission
) {
    VirtualAddress virtualAddress = (VirtualAddress) (virtualPageNum << 12);
    uint64 pteL2 = getL2(virtualAddress);
    
    if(!(getFlags(pagetable->pageTableEntry[pteL2]) & PTE_V)) {
        uint64 pageNum = allocatePage();
        // Reset page table entry with flags set to 0 and page number to the
        // page just allocated
        pagetable->pageTableEntry[pteL2] = 
            (PageTableEntry)((pageNum << 10) | PTE_V);
        setFlags(&(pagetable->pageTableEntry[pteL2]), True, False, False);
    }

    PageDirectory *level1 = 
        (PageDirectory *)(getPageNum(pagetable->pageTableEntry[pteL2]) << 12);
    uint64 pteL1 = getL1(virtualAddress);

    if(!(getFlags(level1->pageTableEntry[pteL1]) & PTE_V)) {
        uint64 pageNum = allocatePage();
        // Reset page table entry with flags set to 0 and page number to the
        // page just allocated
        level1->pageTableEntry[pteL1] = 
            (PageTableEntry)((pageNum << 10) | PTE_V);
        setFlags(&(level1->pageTableEntry[pteL1]), True, False, False);
    }

    PageDirectory *level0 = 
        (PageDirectory *)(getPageNum(level1->pageTableEntry[pteL1]) << 12);
    uint64 pteL0 = getL0(virtualAddress);

    if(!(getFlags(level0->pageTableEntry[pteL0]) & PTE_V)) {
        uint64 pageNum = allocatePage();
        // Reset page table entry with flags set to 0 and page number to the
        // page just allocated
        level0->pageTableEntry[pteL0] = 
            (PageTableEntry)((pageNum << 10) | PTE_V);
        setFlags(
            &(level0->pageTableEntry[pteL0]),
            readPermission,
            writePermission,
            executePermission
        );
    }
}

// Given a virtual page number, allocate a physical page and map it to
// that virtual page if not already mapped, else error occurs
void allocateVirtualPage(
    PageTable *pagetable,
    uint64 virtualPageNum,
    Bool readPermission,
    Bool writePermission,
    Bool executePermission
) {
    if(isVirtualPageAllocated(pagetable, virtualPageNum))
        error("allocateVirtualPage: Virtual Page Already given a physical page");

    uint64 pageNum = allocatePage();
    mapVirtualPage(
        pagetable,
        virtualPageNum,
        pageNum,
        readPermission,
        writePermission,
        executePermission
    );
}

// Convert provided virtual address `virtualAddress` into physical address
// if that address was allocated, else error would be called
PhysicalAddress virtualToPhysical(
    PageTable *pagetable,
    VirtualAddress virtualAddress
) {

    if(!isVirtualPageAllocated(pagetable, getVirtPage(virtualAddress)))
        error("virtualToPhysical: virtual address not valid");

    uint64 pteL2 = getL2(virtualAddress);

    PageDirectory *level1 = 
        (PageDirectory *)(getPageNum(pagetable->pageTableEntry[pteL2]) << 12);
    uint64 pteL1 = getL1(virtualAddress);

    PageDirectory *level0 = 
        (PageDirectory *)(getPageNum(level1->pageTableEntry[pteL1]) << 12);
    uint64 pteL0 = getL0(virtualAddress);
    
    uint64 physicalPageNum = getPageNum(level0->pageTableEntry[pteL0]);
    PhysicalAddress physicalAddress =
        (PhysicalAddress) (physicalPageNum << 12);

    return physicalAddress;
}

void deallocatePageTable(PageTable *pagetable) {
    for(int i = 0;i < NUM_PTE;i++) {
        if(getFlags(pagetable->pageTableEntry[i]) & PTE_V) {
            PageDirectory *level1 =
                (PageDirectory *)
                (getPageNum(pagetable->pageTableEntry[i]) << 12);

            for(int j = 0;j < NUM_PTE;j++) {
                if(getFlags(level1->pageTableEntry[j]) & PTE_V) {
                    PageDirectory *level0 =
                        (PageDirectory *)
                        (getPageNum(level1->pageTableEntry[j]) << 12);

                    for(int k = 0;k < NUM_PTE;k++) {
                        if(getFlags(level0->pageTableEntry[k]) & PTE_V) {
                            uint64 pageNum =
                                getPageNum(level0->pageTableEntry[k]);

                            // Physical page corresponding to virt page
                            freePage(pageNum);
                            level0->pageTableEntry[k] = 0; // Invalidate entry
                        }
                    }

                    uint64 pageNum =
                        getPageNum(level1->pageTableEntry[j]);

                    // Final Level (L0) Page Directory
                    freePage(pageNum);
                    level1->pageTableEntry[j] = 0; // Invalidate entry
                }
            }

            uint64 pageNum =
                getPageNum(pagetable->pageTableEntry[i]);
            
            // Middle Level (L1) Page Directory
            freePage(pageNum);
            pagetable->pageTableEntry[i] = 0; // Invalidate entry
        }
    }

    // Root Page Directory - Page Table itself
    uint64 pageNum = ((uint64)pagetable) >> 12;
    freePage(pageNum);
}

#pragma GCC diagnostic pop
