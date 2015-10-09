#ifndef _CPU_
#define _CPU_

#define CMD_COPY 1
#define CMD_NOT 2
#define CMD_OR 3
#define CMD_AND 4
#define CMD_IFJMP 5
#define CMD_IDLE 6
#define CMD_EXIT 7
#define CMD_IFJMP2 8



void main_loop();
void execute_tillexit();

extern vbyte ep;

#endif
