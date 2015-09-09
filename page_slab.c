#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "page_slab.h"
#include "page.h"
#include "debug.h"

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


struct page* get_free_page_struct()
{
    struct page_slab *p = global_page_slab;
    struct page *page;

    if( p == NULL ) 
	return NULL;

    while(1) {
	page = p->p;    
	if( p->p == NULL ) {
	    bug();
	    continue;
	}
	if( p->used == PAGE_SLAB_SIZE ) 
	    continue;
	
	for(int i=0;i<PAGE_SLAB_SIZE;++i) {
	    if( (page+i)->struct_in_use == UNUSED ) {
		(page+i)->struct_in_use = USED;
		p->used++;
		return (page+i);
	    }
	}
	if( p->next == NULL ) break; 
	p = p->next;
    }    
    return NULL;
    
}

struct page* new_page_struct()
{
    struct page* page = get_free_page_struct();
    if( page == NULL ) {
	struct page_slab* ps = alloc_page_slab();
	if( ps == NULL ) 
	    return NULL;
	add_page_slab(ps);
	page = get_free_page_struct();
    }
    return page;
}
