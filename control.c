
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include "page.h"


void load_file(char * file) {
    FILE *f = fopen(file,"r");
    if( !f ) {
	printf("error: cannot open file %s\n", file);
	return;
    }
    vbyte begin;

    fscanf(f,"%" PRIx64 , &begin);

    vbyte byte;
    long i =0;
    while( fscanf(f,"%" PRIx64 , &byte ) == 1){
	write_vbyte( (begin+i) , byte );
	++i;
    }
    fclose(f);
}

void load_data(char *file, vbyte address) {
    FILE *f = fopen(file,"r");
    if( !f ) {
	printf("error: cannot open file %s\n", file);
	return;
    }


    vbyte byte;
    long i =0;
    while( fscanf(f,"%" PRIx64 , &byte ) == 1){
	write_vbyte( (address+i) , byte );
	++i;
    }
    fclose(f);    
}
