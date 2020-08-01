#include "declarations.h"
#include "functions.h"

// This file contains functions which would be used
// to load disk blocks into buffers and store buffers
// into disk blocks

// Initialize Buffer Cache
void binit(void) {
    Buffer *b;

    bcache.head.prev = &bcache.head;
    bcache.head.next = &bcache.head;
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        bcache.head.next->prev = b;
        bcache.head.next = b;
    }
}

// Get a free Buffer
static Buffer *bget(uint blockno) {
    Buffer *b;

    for(b = bcache.head.next; b != &bcache.head; b = b->next){
        if(b->blockno == blockno){
            b->refcnt++;
            return b;
        }
    }

    for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
        if(b->refcnt == 0) {
            b->blockno = blockno;
            b->valid = 0;
            b->refcnt = 1;
            return b;
        }
    }

    error("bget: no buffers");
}

// Read a disk block specified by blockno into the buffer and return
// the address of that buffer
Buffer *bread(uint blockno) {
    Buffer *b = bget(blockno);

    if(!b->valid) {
        diskRW(b, 0);
        b->valid = 1;
    }

    return b;
}

// Write the buffer back to the block to which it corresponds to
void bwrite(Buffer *b) {
    diskRW(b, 1);
}

// Release the buffer - return the buffer back to the buffer free list
void brelse(Buffer *b) {
    b->refcnt--;
    if (b->refcnt == 0) {
        b->next->prev = b->prev;
        b->prev->next = b->next;
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        bcache.head.next->prev = b;
        bcache.head.next = b;
    }
}

// Read `nBytes` bytes from disk block `diskBlockNum` at offset `offset`
// to the memory location specified by `memoryLocation`
void readBytes(
    uint64 diskBlockNum,
    uint64 offset,
    uint64 nBytes,
    uchar *memoryLocation
) {
    if(diskBlockNum >= DISKSIZE)
        error("readBytes: block exceeds disk size");

    uint64 nextBytePosToRead = offset;
    uint64 bytesRead = 0;
    Buffer* b = bread(diskBlockNum);

    while(bytesRead < nBytes) {
        if(nextBytePosToRead == BSIZE) {
            brelse(b);      // release the buffer
            diskBlockNum ++;
            if(diskBlockNum >= DISKSIZE)
                error("readBytes: block exceeds disk size");

            b = bread(diskBlockNum);
            nextBytePosToRead = 0;
        }

        *memoryLocation = (b -> data)[nextBytePosToRead];
        nextBytePosToRead ++;
        memoryLocation ++;
        bytesRead ++;
    }

    brelse(b);				// release the buffer
}

// Write `nBytes` bytes to disk block `diskBlockNum` at offset `offset`
// from the memory location specified by `memoryLocation`
void writeBytes(
    uint64 diskBlockNum,
    uint64 offset,
    uint64 nBytes,
    uchar *memoryLocation
) {
    if(diskBlockNum >= DISKSIZE)
        error("writeBytes: block exceeds disk size");

    uint64 nextBytePosToWrite = offset;
    uint64 bytesWritten = 0;
    Buffer* b = bread(diskBlockNum);

    while(bytesWritten < nBytes) {
        if(nextBytePosToWrite == BSIZE) {
	  		bwrite(b);  // write changes made in the buffer to the disk block
            brelse(b);  // release the buffer
            diskBlockNum ++;
            if(diskBlockNum >= DISKSIZE)
                error("writeBytes: block exceeds disk size");

            b = bread(diskBlockNum);
            nextBytePosToWrite = 0;
        }

        (b -> data)[nextBytePosToWrite] = *memoryLocation;
        nextBytePosToWrite ++;
        memoryLocation ++;
        bytesWritten ++;
    }

    bwrite(b);      // write changes made in the buffer to the disk block
    brelse(b);      // release the buffer
}

// function which reads `nBytes` bytes from the disk starting from the virtual
// address `memoryLocation`, every incremented virtual address is checked
// for its validity using `virtualToPhysical` function
void readBytesVirtual(
    uint64 diskBlockNum,
    uint64 offset,
    uint64 nBytes,
    uchar *memoryLocation,
    PageTable *pagetable
) {
    if(diskBlockNum >= DISKSIZE)
        error("readBytesVirtual: block exceeds disk size");

    uint64 nextBytePosToRead = offset;
    uint64 bytesRead = 0;
    Buffer* b = bread(diskBlockNum);

    while(bytesRead < nBytes) {
        if(nextBytePosToRead == BSIZE) {
            brelse(b);      // release the buffer
            diskBlockNum ++;
            if(diskBlockNum >= DISKSIZE)
                error("readBytesVirtual: block exceeds disk size");

            b = bread(diskBlockNum);
            nextBytePosToRead = 0;
        }

        VirtualAddress virtualaddr = (VirtualAddress)memoryLocation;
        PhysicalAddress physicaladdr = virtualToPhysical(pagetable, virtualaddr);
        uchar* physicalAddrLocation = (uchar*)physicaladdr;
        *physicalAddrLocation = (b -> data)[nextBytePosToRead];

        nextBytePosToRead ++;
        memoryLocation ++;
        bytesRead ++;
    }

    brelse(b);				// release the buffer
}

// function which writes `nBytes` bytes to the disk starting from the virtual
// address `memoryLocation`, every incremented virtual address is checked
// for its validity using `virtualToPhysical` function
void writeBytesVirtual(
    uint64 diskBlockNum,
    uint64 offset,
    uint64 nBytes,
    uchar *memoryLocation,
    PageTable* pagetable
) {
    if(diskBlockNum >= DISKSIZE)
        error("writeBytesVirtual: block exceeds disk size");

    uint64 nextBytePosToWrite = offset;
    uint64 bytesWritten = 0;
    Buffer* b = bread(diskBlockNum);

    while(bytesWritten < nBytes) {
        if(nextBytePosToWrite == BSIZE) {
	  		bwrite(b);  // write changes made in the buffer to the disk block
            brelse(b);  // release the buffer
            diskBlockNum ++;
            if(diskBlockNum >= DISKSIZE)
                error("writeBytesVirtual: block exceeds disk size");

            b = bread(diskBlockNum);
            nextBytePosToWrite = 0;
        }

        VirtualAddress virtualaddr = (VirtualAddress)memoryLocation;
        PhysicalAddress physicaladdr = virtualToPhysical(pagetable, virtualaddr);
        uchar* physicalAddrLocation = (uchar*)physicaladdr;
        (b -> data)[nextBytePosToWrite] = *physicalAddrLocation;

        nextBytePosToWrite ++;
        memoryLocation ++;
        bytesWritten ++;
    }

    bwrite(b);      // write changes made in the buffer to the disk block
    brelse(b);      // release the buffer
}