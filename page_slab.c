
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "page_slab.h"
#include "page.h"

struct page_slab* alloc_page_slab()
{
    void *p;
    struct page_slab *s;

    p = malloc( sizeof(struct page_slab) + sizeof(struct page)*PAGE_SLAB_SIZE );
    if( !p ) {
	return NULL;
    }
    
    s = (struct page_slab*)p;
    s->next = NULL;
    s->prev = NULL;
    s->used = 0;
    s->p = p + sizeof(struct page_slab);

    return s;   
}



