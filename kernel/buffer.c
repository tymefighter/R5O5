#include "declarations.h"
#include "functions.h"

void binit(void) {
    Buffer *b;

    // Create linked list of buffers
    bcache.head.prev = &bcache.head;
    bcache.head.next = &bcache.head;
    for(b = bcache.buf; b < bcache.buf+NBUF; b++){
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        bcache.head.next->prev = b;
        bcache.head.next = b;
    }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
Buffer* bget(uint dev, uint blockno) {
    Buffer *b;

    // Is the block already cached?
    for(b = bcache.head.next; b != &bcache.head; b = b->next) {
        if(b->dev == dev && b->blockno == blockno){
            b->refcnt++;
            return b;
        }
    }

    // Not cached; recycle an unused buffer.
    for(b = bcache.head.prev; b != &bcache.head; b = b->prev) {
        if(b->refcnt == 0) {
            b->dev = dev;
            b->blockno = blockno;
            b->valid = 0;
            b->refcnt = 1;
            return b;
        }
    }

    error("bget: no buffers");
    return 0;
}

// Return a locked buf with the contents of the indicated block.
Buffer* bread(uint dev, uint blockno) {
    Buffer *b;

    b = bget(dev, blockno);
    if(!b->valid) {
        diskRW(b, 0);
        b->valid = 1;
    }
    return b;
}

// Write b's contents to disk.    Must be locked.
void bwrite(Buffer *b) {
    diskRW(b, 1);
}

// Release a locked buffer.
// Move to the head of the MRU list.
void brelse(Buffer *b) {

    b->refcnt--;
    if (b->refcnt == 0) {
        // no one is waiting for it.
        b->next->prev = b->prev;
        b->prev->next = b->next;
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        bcache.head.next->prev = b;
        bcache.head.next = b;
    }

}

void bpin(Buffer *b) {
    b->refcnt++;
}

void bunpin(Buffer *b) {
    b->refcnt--;
}