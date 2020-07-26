#include "declarations.h"
#include "functions.h"

// Memory Allocator for pages
// Linked List of pages which is used in stack fashion -
// i.e. both insertion and deletion at the head

// Initialize Linked List of Free Pages
void pageAllocInit() {
    pages[0].prev = NULL;
    pages[NUM_PAGES - 1].next = NULL;

    for(int i = 1; i < NUM_PAGES - 1; i ++) {
        pages[i].pageNum = START_PAGE + i;
        pages[i].prev = &pages[i - 1];
        pages[i].prev->next = &pages[i];
    }

    freePageList.head = &pages[0];
    freePageList.tail = &pages[NUM_PAGES - 1];
    numFreePages = NUM_PAGES;
}

// Allocate Single Page
// Remove Node from the head of the linked list
Page *allocatePage() {
    if(numFreePages == 0) {
        error("allocatePage: No Free Page");
        return NULL;
    }
    else if(numFreePages == 1) {
        Page *page = freePageList.head;
        page->prev = NULL;
        page->next = NULL;
        freePageList.head = NULL;
        freePageList.tail = NULL;
        numFreePages = 0;
        return page;
    }
    else {
        Page* page = freePageList.head;
        freePageList.head = freePageList.head->next;
        freePageList.head->prev = NULL;
        page->prev = NULL;
        page->next = NULL;
        numFreePages = numFreePages - 1;
        return page;
    }
}

// Allocate n Pages and place them in a page
// list whose address is passed as input
// If less than n pages are present, then we raise
// an error
void allocatePages(int n, PageList *allocatedPages) {
    if(n <= 0)
        error("allocatePages: Invalid n value");

    if(n > numFreePages) {
        error("allocatePages: Less than n pages");
        allocatedPages->head = allocatedPages->tail = NULL;
        return;
    }

    allocatedPages->tail = allocatedPages->head = allocatePage();

    // Get new node and place it at the top of the current
    // head and make it the new head
    for(int i = 1; i < n; i ++) {
        Page* curr = allocatePage();
        curr->next = allocatedPages->head;
        allocatedPages->head->prev = curr;
        allocatedPages->head = curr;
    }
}

// Free a Single Page
// Insert the provided page at the head
void freePage(Page *page) {
    page->next = page->prev = NULL;

    if(freePageList.head == NULL && freePageList.tail == NULL) {
        freePageList.head = page;
        freePageList.tail = page;
    }
    else {
        page->next = freePageList.head;
        freePageList.head->prev = page;
        freePageList.head = page;
    }

    numFreePages = numFreePages + 1;
}

// Free all the pages in the supplied page list
void freePages(PageList *pagesToFree) {
    if(pagesToFree->head == NULL) return;

    while(pagesToFree->head != NULL){
        freePage(pagesToFree->head);
        pagesToFree->head = pagesToFree->head->next;
    }

    pagesToFree->tail = NULL;
}