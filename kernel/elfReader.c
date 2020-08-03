#include "declarations.h"
#include "functions.h"

// ELF Reader
// ----------------------------------------------------------------------------

// Returns a doubly connected linked list
// of elf program headers containing
// off, vaddr, filesz and memsz in elfRead

// elfRead -> head = elfRead -> tail = NULL means
// some error occured.
void elfReader(
    uint64 startBlock,
    uint64 startOff,
	uint64 endBlock,
    uint64 endOff,
    ElfreadList *elfRead
) {

    elfRead -> head = elfRead -> tail = NULL;

    // invalid start block
    if(startBlock >= DISKSIZE)
        return;

    // cnt stores the index of the next available ELFRead element
    int i, cnt = 0, flag = 1, off = startOff;
    Elfhdr elf;
    Proghdr ph;
    
    // read ELF header
    readBytes(startBlock, off, sizeof(elf), (uchar*)&elf);

    if(elf.magic != ELF_MAGIC)
        return;

    elfRead->entry = elf.entry; // Get Entry point of the process

    // Read the program headers and stores in a list.
    uint64 blockNum = startBlock;
    for(
        i = 0, off += elf.phoff;
        i < elf.phnum;
        i++, off += sizeof(ph), cnt++
    ) {

        blockNum += (off / BSIZE);
	    off = off % BSIZE;
        
        // program headers should not exceed endBlock
        if(blockNum * BSIZE + off > endBlock * BSIZE + endOff) {
            flag = 0;
            break;
        }
        
        // Read Program Header
        readBytes(blockNum, off, sizeof(ph), (uchar*)&ph);
        
        if(ph.type != ELF_PROG_LOAD)
            continue;

        if(ph.memsz < ph.filesz) {flag = 0; break;}
        if(ph.vaddr + ph.memsz < ph.vaddr) {flag = 0; break;}
        if(ph.vaddr % PGSIZE != 0) {flag = 0; break;}
        if(cnt >= ELFSIZE) {flag = 0; break;}

        // appends a new node in the list at the tail end
        allocateELFReader(
            elfRead,
            &cnt,
            ph.off,
            ph.vaddr,
            ph.filesz,
            ph.memsz
        );
    }

    if(flag == 0)
        elfRead -> head = elfRead -> tail = NULL;
    
    return;
}

// inserts a new elf program header's data at the tail end
void allocateELFReader(
    ElfreadList *elfRead, 
    int* cnt, 
    uint64 off,
    uint64 vaddr,
    uint64 filesz,
    uint64 memsz
) {

    if(elfRead -> head == NULL) {
        elfRead -> head = elfRead -> tail = &elfNodes[0];
        elfRead -> head -> next = elfRead -> head -> prev = NULL;
        *cnt = 1;
    }
    else {
        Elfread *new = &elfNodes[*cnt];
        elfRead -> tail -> next = new;
        new -> prev = elfRead -> tail;
        new -> next = NULL;
        elfRead -> tail = new;
        (*cnt)++;
    }
    
    elfRead->tail->off = off;
    elfRead->tail->vaddr = vaddr;
    elfRead->tail->filesz = filesz;
    elfRead->tail->memsz = memsz;

    return;
}
