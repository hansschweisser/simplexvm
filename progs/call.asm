main:	idle
	
	copy A proc_arg1
	copy back proc_return
	ifjmp zero zero proc
backl:	idle
	copy proc_out1 B

	exit

zero:	db 0x0

A:	db 0x12
B:	db 0x0
back: 	db backl




proc_arg1:	db 0x0
proc_out1:	db 0x0

proc_return:	db 0x0

proc:	idle

	

	ifjmp2 zero zero proc_return


var A 0x0
var A
var A = 10; var B = 10;
var A,B = 10;



%call proc(X Y) O1 O2



%function proc(arg1 arg1) out1 out2
	copy
	or 
	...
%endfunction proc


