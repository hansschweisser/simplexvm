#include "page.h"
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <inttypes.h>
#include <stdint.h>


#include "cpu.h"


vbyte cmd_copy(vbyte address) {
    vbyte from = read_vbyte(address+1);
    vbyte to = read_vbyte(address+2);
    
    vbyte from_value = read_vbyte(from);
    write_vbyte(to,from_value);

    return address+3;
}

vbyte cmd_not(vbyte address) {
    vbyte from = read_vbyte(address+1);
    vbyte to = read_vbyte(address+2);
    
    vbyte from_value = read_vbyte(from);
    write_vbyte(to, ~from_value);
    return address+2;
}

vbyte cmd_or(vbyte address) {

    vbyte va = read_vbyte(read_vbyte(address+1));
    vbyte vb = read_vbyte(read_vbyte(address+2));
    vbyte to = read_vbyte(address+3);

    vbyte result = va | vb; 
    write_vbyte(to, result );

printf("debug.cmd_or  [%" PRIx64 " rv%" PRIx64 "] [%" PRIx64 " rv%" PRIx64 "] [%" PRIx64 " wv%" PRIx64 "] \n", 
	read_vbyte(address+1), va, read_vbyte(address+2), vb, to, result ); 



    return address+4;
    
}

vbyte cmd_and(vbyte address) {
    write_vbyte( read_vbyte(address+3) , 
	read_vbyte(read_vbyte(address+1)) & read_vbyte(read_vbyte(address+2)) );
    return address+4;
}

vbyte cmd_ifjmp(vbyte address) {
    if( read_vbyte(read_vbyte(address+1)) == read_vbyte(read_vbyte(address+2)) )
	return read_vbyte(address+3);
    else
	return address+4;
}

vbyte cmd_ifjmp2(vbyte address) {
    if( read_vbyte(read_vbyte(address+1)) == read_vbyte(read_vbyte(address+2)) )
	return read_vbyte(read_vbyte(address+3));
    else
	return address+4;
}

vbyte cmd_idle(vbyte address) {
    return address+1;
}


int loop = 1;

vbyte cmd_exit(vbyte address){
    return address;
}


struct command {
    vbyte cmd;
    vbyte (*execute)(vbyte);
};

struct command commands[] = {
    { 1, cmd_copy },
    { 2, cmd_not },
    { 3, cmd_or },
    { 4, cmd_and },
    { 5, cmd_ifjmp },
    { 6, cmd_idle },
    { 7, cmd_exit },
    { 8, cmd_ifjmp2 }
};



vbyte execute_cmd(vbyte address) {
    vbyte cmd = read_vbyte(address);
//printf("debug.execute_cmd(%016" PRIx64 ")\n",address);
//printf("debug.execute_cmd sizeof(commands) = %d\n", (int)(sizeof(commands)/sizeof(commands[0])));
    for(int i=0;i<sizeof(commands)/sizeof(commands[0]);++i){
//printf("debug.execute_cmd i=%d\n",i);
	if( cmd == commands[i].cmd ) {
//printf("debug.execute_cmd executing command %016" PRIx64 "\n",cmd);
	    return (commands[i].execute)(address);
	}
    }
    return address+1;

}    



int pausecpu = 0 ;
int sleeptime = 0;
int onestep = 0;

void one_step() {
    onestep = 1;
    pausecpu = 0;
}


vbyte ep = 0;

void execute_cmd_once() {
    ep = execute_cmd(ep);
}

void execute_cmd_n(int n){
    for(int i=0;i<n;++i){
	ep = execute_cmd(ep);
    }
}

void main_loop() {

    while(loop) { 
	if( pausecpu ) continue;
	if( onestep == 1) {
	    ep = execute_cmd(ep);
	    onestep = 0;
	    pausecpu = 1;
	}else{
	    ep = execute_cmd(ep);
	}
	sleep(sleeptime);

    }
}


