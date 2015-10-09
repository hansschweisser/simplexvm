#ifndef _PAGE_
#define _PAGE_


#include "core.h"
#include <stdlib.h>

#define UNUSED 0
#define USED 1

#define PAGE_SIZE 8 // bits shift

struct page 
{
    struct page *next;
    struct page *prev;

    vbyte begin;
    vbyte end;

    vbyte* p;

    int struct_in_use;
};


vbyte read_vbyte(vbyte address);
vbyte read_vbyte_notrap(vbyte address);

void write_vbyte(vbyte address,vbyte value);

void show_page_list();
void dump_all_pages();
void show_page(struct page*);
void dump_page(struct page*);

extern struct page* global_page_list;

struct page * find_page_index(int);
#endif
