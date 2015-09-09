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

int is_unused_page(struct page* page)
{
    for(int i=0;i<sizeof(struct page);++i){
	if(  (((char*)page)+i) != 0 )
	    return 0;
    }
    return 1;
}

struct page* find_free_page_struct()
{
    struct page_slab *p = global_page_slab;
    struct page *page;

    if( p == NULL ) 
	return NULL;

    while(1) {
	page = p->p;    
	for(int i=0;i<PAGE_SLAB_SIZE;++i) {
	    if( is_unused_page(page+i) {
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
    struct page* page = find_free_page();
    if( page == NULL ) {
    }else{
	
    }
}
