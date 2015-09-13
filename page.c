#include "page.h"
#include "page_slab.h"
#include "debug.h"
#include "core.h"
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

struct page * global_page_list = NULL;

vbyte end_of_page(vbyte begin) {
    return begin + ((1<<(PAGE_SIZE))-1);
}

struct page* new_page(vbyte begin) {
    void *p;
    struct page* page;
    
    p = malloc(sizeof(vbyte) * (1<<PAGE_SIZE) );
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
    if( new_page == NULL )
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
    return (a == b);
}

int is_gr(vbyte a, vbyte b){
    return ( a < b );
}

int is_ge(vbyte a, vbyte b){
    if( is_eq(a,b) ) return 1;
    if( is_gr(a,b) ) return 1;
    return 0;
}


int is_in(vbyte start, vbyte end, vbyte address){
    if( ( start<=address) && (address<=end) ) return 1;
    return 0;
}


struct page* find_page(vbyte address){
    struct page * page = global_page_list;
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



vbyte read_vbyte(vbyte address){
    struct page *page = find_page(address);
    if( page == NULL ) 
	return 0; 
    return *( page->p + ( address - page->begin ) );
    
}

vbyte page_begin(vbyte address) {
    return ((address>>PAGE_SIZE)<<PAGE_SIZE);
}

void write_vbyte(vbyte address, vbyte value){
    struct page *page = find_page(address);
    if( page == NULL ) {
	page = new_page( page_begin(address) );
	if( page == NULL ) 
	    bug(); // cannot allocate memory
	add_page(page);	
    }
    *(page->p + (address - page->begin) ) = value;
}


void show_page_list() {
    struct page* page = global_page_list;

    int count=0;
    printf("Page list: \n");
    while(page) {

	printf ("page[%d]= %8" PRIx64 " - %8" PRIx64 " %d %p\n", count, page->begin, page->end, page->struct_in_use,page->p ); 

	count ++;
	if( page->next != NULL ) {
	    page = page->next;
	    continue;
	}else{
	    break;	
	}
    }

}


void show_page(struct page* page){
    int perline = 8;


    for(int i=0;i<(1<<PAGE_SIZE);++i){	
	printf("%8" PRIx64 " ", *(page->p + i ) );
	if( (i+1) % perline  == 0 ) printf("\n");
    }
    printf("\n");
}

void dump_all_pages() {
    struct page* page = global_page_list;

    int count=0;
    printf("Pages dump: \n");
    while(page) {

	printf ("page[%d]= %016" PRIx64 "-%16" PRIx64 " %d %p\n", count, page->begin, page->end, page->struct_in_use,page->p ); 
	show_page(page);

	count ++;
	if( page->next != NULL ) {
	    page = page->next;
	    continue;
	}else{
	    break;	
	}
    }
    
}
