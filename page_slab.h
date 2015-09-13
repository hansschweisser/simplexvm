#ifndef _PAGE_SLAB_
#define _PAGE_SLAB_

#include "page.h"
#include <unistd.h>
#include <stdlib.h>

#define PAGE_SLAB_SIZE 2

struct page_slab
{
    struct page_slab *next;
    struct page_slab *prev;
    struct page *p;
    int used;
};



struct page* new_page_struct();
void show_page_slab_list();


#endif
