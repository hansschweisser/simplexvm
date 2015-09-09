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

void add_page_slab(struct page_slab* new_page)
{
    struct page_slab *p = global_page_slab;
    
    if( global_page_slab == NULL ) {
	global_page_slab = new_page;
	new_page->next = NULL;
	new_page->prev = NULL;
	return;
    }
    
    while( p->next ) p = p->next;
    
    new_page->next = NULL;
    new_page->prev = p;
    p->next = new_page;
}

struct page* find_free_page()
{
    struct page_slab *p = global_page_slab;
    struct page *page;

    if( p == NULL ) 
	return NULL;

    while(1) {
	page = p->p;    
	for(int i=0;i<PAGE_SLAB_SIZE;++i) {
	    if( (page+i) == NULL) {
		return (page+i);
	    }
	}
	if( p->next == NULL ) break; 
	p = p->next;
    }    
    return NULL;
    
}

