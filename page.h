#ifndef _PAGE_
#define _PAGE_

#define UNUSED 0
#define USED 1

#define PAGE_SIZE 16 // bits shift

struct page 
{
    struct page *next;
    struct page *prev;

    vbyte begin;
    vbyte end;

    vbyte* p;

    int struct_in_use;
};

struct page *global_page_list = NULL;

vbyte read_vbyte(vbyte address);
void write_vbyte(vbyte address,vbyte value);

long long int tolong(vbyte address);

#endif
