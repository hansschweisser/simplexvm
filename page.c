#include "page.h"
#include "debug.h"
#include "core.h"


vbyte end_of_page(vbyte begin) {
    
}

struct page* new_page(vbyte begin) {
    void *p;
    struct page* page;
    
    p = malloc(sizeof(vbyte) * (1<<(PAGE_SIZE*8)) );
    page = new_page_struct();
    page->p = p;
    page->next = NULL;
    page->prev = NULL;
    page->begin = begin;
    page->end = end_of_page(begin);
    return page;
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
    struct page * global_page_list;
    if( page == NULL ) 
	return NULL;
    while(1) {
	if( is_in( page->begin, page->end, address) ) {
	    return page;
	}
	if( page->next != NULL ) {
	    page = page->next;
	    continue;
	}
	break;
    }
    return NULL;
    
}

long long int tolong(vbyte address) { 
    long long int n = 0;
    for(int i=VBYTE_SIZE-1;i>=0;--i) {
	n *= 256;
	n += address.byte[i];
    }
    return n;
}

long long int index(vbyte begin, vbyte address) {
    return tolong(address) - tolong(begin); 
}


vbyte read_vbyte(vbyte address){
    struct page *page = find_page(address);
    if( page == NULL ) 
	return 0; 
    return *( page->p + index( page->begin, address ) );
    
}

vbyte page_begin(vbyte address) {
    for(int i=0;i<PAGE_SIZE;++i) {
	address.byte[i] = 0;
    }
    return address;
}

void write_vbyte(vbyte address, vbyte value){
    struct page *page = find_page(address);
    if( page == NULL ) {
	page = new_page( page_begin(address) );
	if( page == NULL ) 
	    bug(); // cannot allocate memory
	add_page(page);	
    }
    *(page->p + index(page->begin, address) ) = value;
}

