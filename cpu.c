#include "page.h"



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

    write_vbyte(to, va | vb );
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

vbyte cmd_idle(vbyte address) {
    return address+1;
}


int loop = 1;

vbyte cmd_exit(vbyte address){
    loop = 0;
    return address+1;
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
    { 7, cmd_exit }
};



vbyte execute_cmd(vbyte address) {
    vbyte cmd = read_vbyte(address);

    for(int i=0;i<sizeof(commands);++i){
	if( cmd == commands[i].cmd ) {
	    return (commands[i].execute)(address);
	}
    }

}    

void main_loop() {
    vbyte ep = 0;

    while(loop) { 
	ep = execute_cmd(ep);
    }
}


