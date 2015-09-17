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



