#include "page.h"
#include "debug.h"
#include "core.h"


vbyte end_of_page(vbyte begin) {
    
}

struct page* new_page(vbyte begin) {
    void *p;
    struct page* page;
    
    p = malloc(sizeof(vbyte) * PAGE_SIZE);
    page = new_page_struct();
    page->p = p;
    page->next = NULL;
    page->prev = NULL;
    page->begin = begin;
    page->end = end_of_page(begin);
    
}

void add_page(struct page *new_page)
{
    if( new_page == NUL )
	bug();

    if( global_page_list == NULL ) {
	global_page_list = new_page;
	new_page->next = NULL;
	new_page->prev = NULL;	
    }else{
	struct page *p = global_page_list;
	while(1) {
	    if( p->next != NULL ) {
		p = p->next;
	    }else{
		break;
	    }
	}
	p->next = new_page;
	new_page->prev = p;
	new_page->next = NULL;
    }
}

int is_eq(vbyte a, vbyte b){
    for(int i=0;i<VBYTE_SIZE;++i){
	if( a.byte[i] != b.byte[i] ) 
	    return 0;
    }
    return 1;
}

int is_gr(vbyte a, vbyte b){
    for(int i=VBYTE_SIZE-1;i>=0;--i){
	if( a.byte[i] > b.byte[i] )
	    return 1;
	if( a.byte[i] < b.byte[i] )
	    return 0;
	
    }
    return 0;
}

int is_ge(vbyte a, vbyte b){
    if( is_eq(a,b) ) return 1;
    if( is_gr(a,b) ) return 1;
    return 0;
}


int is_in(vbyte start, vbyte end, vbyte address){
    if( is_ge(address,start) && is_ge(end,address) ) return 1;
    return 0;
}


struct page* find_page(vbyte address){
    
}

vbyte read_vbyte(vbyte address){
    
}

vbyte write_vbyte(vbyte address){
}

