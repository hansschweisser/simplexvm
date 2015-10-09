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
#include "core.h"



#define LOG 1



struct trap {
    struct trap *next,*prev;
    vbyte from, to;
    FILE *file;
};


struct dump {
    struct dump* next, *prev;
    vbyte from,to;
    FILE* file;
    char* name;
};


struct trap* traps;
struct dump* dumps;

struct trap* new_trap(vbyte , vbyte );
void add_trap(struct trap*);
struct dump* new_dump(char*,vbyte,vbyte);
void add_dump(struct dump*);
void execute_traps(vbyte,vbyte,vbyte,char* );
void execute_dumps();



#endif
