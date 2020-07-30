#include "declarations.h"
#include "functions.h"

// Memory Allocator for Pages

/*  The `pages` array is a stack of free pages implemented
    using a fixed length array of length `NUM_PAGES`

    Example of a snapshot of the `pages` stack: -

    array idx   |---------|
    0           | invalid |
    1           | invalid |
    .           |    .    |
    .           |    .    |
    24          | invalid |                     _
    25          |   12    | <- `currFreePageNode`|
    26          |   203   |                      |
    27          |   110   |                      |
    28          |   111   |                      | - `numFreePages` Valid entries
    29          |   112   |                      |
    .           |    .    |                      |
    .           |    .    |                      |
    NUM_PAGES-1 |   450   |                      |
                |---------|                     -

        The values 12, 203, 110, 111, 112 are EXAMPLE page numbers
*/

// Initialize Linked List of Free Pages
void pageAllocInit() {
    for(int i = 0; i < NUM_PAGES; i ++) 
        pages[i] = START_PAGE + i;

    currFreePageNode = 0;
    numFreePages = NUM_PAGES;
}

// Allocate Single Page
// Remove Node from the head of the free page linked list
// and place it in used page list, and return free page's number
uint64 allocatePage() {
    if(numFreePages == 0) {
        error("allocatePage: No Free Page");
        return 0;
    }
    
    uint64 pageNum = pages[currFreePageNode];
    currFreePageNode ++;
    numFreePages --;

    return pageNum;
}

// Allocate n Pages and place them in a page
// list whose address is passed as input
// If less than n pages are present, then we raise
// an error
void allocatePages(uint64 n, uint64 allocatedPages[]) {
    if(n <= 0)
        error("allocatePages: Invalid n value");

    if(n > numFreePages) {
        error("allocatePages: Less than n pages");
        return;
    }

    for(int i = 0; i < n; i ++)
        allocatedPages[i] = allocatePage();
}

// Free a Single Page
// Insert the provided page at the head
void freePage(uint64 pageNum) {
    
    if(numFreePages == NUM_PAGES)
        error("freePage: All Free pages were already returned");
    
    currFreePageNode --;
    pages[currFreePageNode] = pageNum;
    numFreePages ++;
}

// Free all the pages in the supplied page list
void freePages(uint64 n, uint64 pagesToFree[]) {
    if(n <= 0)
        error("allocatePages: Invalid n value");

    for(int i = 0;i < n;i++)
        freePage(pagesToFree[i]);
}