#include "declarations.h"
#include "functions.h"

void init_free_page()
{
    fp_list.start = NULL;
    fp_list.num_free_pages = 0;

    for(uint64 addr = PROCESS_START;addr <= PROCESS_END;addr += PGSIZE)
    {
        FreePage *free_page = (FreePage *)addr;
        
        free_page->addr_start = addr;
        free_page->nextPage = fp_list.start;
        
        fp_list.start = free_page;
        fp_list.num_free_pages ++;
    }
}

// Takes start of free page address as input
void free_page(char *addr)
{
    FreePage *new_free_page = (FreePage *)addr;

    new_free_page->addr_start = addr;
    new_free_page->nextPage = fp_list.start;

    fp_list.start = new_free_page;
    fp_list.num_free_pages ++;
}

char *get_free_page()
{
    if(fp_list.num_free_pages == 0)
        return NULL;

    FreePage *ret_free_page = fp_list.start;

    fp_list.start = fp_list.start->nextPage;
    fp_list.num_free_pages --;

    return ret_free_page->addr_start;
}