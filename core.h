#ifndef _CORE_
#define _CORE_

#include <stdint.h>



#define VBYTE_SIZE 8

typedef uint64_t vbyte;

void execute_cmd_once();
void execute_cmd_n(int n);

#endif
