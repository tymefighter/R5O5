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
    int diskBlockNum,
    int offset,
    int nBytes,
    char *memoryLocation
) {

}

// Write `nBytes` bytes to disk block `diskBlockNum` at offset `offset`
// from the memory location specified by `memoryLocation`
void writeBytes(
    int diskBlockNum,
    int offset,
    int nBytes,
    char *memoryLocation
) {
    
}