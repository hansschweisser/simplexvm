#ifndef _PAGE_SLAB_
#define _PAGE_SLAB_

#include "page.h"

#define PAGE_SLAB_SIZE 1024

struct page_slab
{
    struct page_slab *next;
    struct page_slab *prev;
    struct page *p;
    int used;
};


struct slab *global_page_slab; 


#endif
