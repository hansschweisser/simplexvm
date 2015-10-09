#ifndef _TRAP_
#define _TRAP_

#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <inttypes.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "page_slab.h"
#include "page.h"
#include "debug.h"
#include "core.h"
#include "cpu.h"
#include "control.h"


#include "trap.h"


struct trap {
    struct trap *next,*prev;
    vbyte from, to;
    FILE* file;
};

struct dump {
    struct dump *next,*prev;
    vbyte from, to;
    FILE* file;
    char name[1000];
};


struct trap *traps = NULL;
struct dump *dumps = NULL;


struct trap* new_trap(vbyte from, vbyte to){
	struct trap* t = malloc(sizeof(struct trap));
	if( t == NULL ) { 
	    printf("error: cannot allocate memory for struct trap\n");
	    exit(1);
	}
	t->next = t->prev = NULL;
	t->from = from;
	t->to = to;
	return t;
}

void add_trap(struct trap* t){
	if( traps == NULL ) {
	    traps = t;
	    return;
	}
	traps->prev = t;
	t->next = traps;
	traps = t;
	t->prev = NULL;
}


void execute_traps(vbyte addr,vbyte before, vbyte after, char* type){
	if( traps == NULL ) return;
	struct trap * curr = traps;
	while(curr != NULL ) {
	    if( ( curr->from <= addr) && ( addr <= curr->to) ) {
		if(strcmp(type,"read") == 0){
		    fprintf(curr->file,"%s, addr: 0x%" PRIx64 ", value: 0x%" PRIx64 "\n", type, addr, after); 
		}else if(strcmp(type,"write") == 0){
		    fprintf(curr->file,"%s, addr: 0x%" PRIx64 ", value: 0x%" PRIx64 ", 0x%" PRIx64 "\n", type, addr, before, after); 
		}else
		    printf("bug: unknown type '%s'\n",type);
	    }
	    curr = curr->next;
	}
}







struct dump* new_dump(char *name,vbyte from, vbyte to){
	struct dump* d = malloc(sizeof(struct dump));
	if( d == NULL ) { 
	    printf("error: cannot allocate memory for struct dump\n");
	    exit(1);
	}
	d->next = d->prev = NULL;
	d->from = from;
	d->to = to;
	strcpy(d->name,name);
	return d;
}

void add_dump(struct dump* d){
	if( dumps == NULL ) {
	    dumps = d;
	    return;
	}
	dumps->prev = d;
	d->next = dumps;
	dumps = d;
	d->prev = NULL;
}


void execute_dumps(){
	if( dumps == NULL ) return;
	struct dump * curr = dumps;
	while(curr != NULL ) {
	    vbyte from = curr->from;
	    vbyte to = curr->to;
	    fprintf(curr->file, "%s [0x%" PRIx64 "]:", curr->name, from);
	    for( vbyte i=from;i<=to;++i ){
		fprintf(curr->file, " 0x%"PRIx64,read_vbyte_notrap(i));
	    }
	    fprintf(curr->file,"\n");
	    curr = curr->next;
	}
}





#endif
