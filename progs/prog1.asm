	ifjmp2 A B label1
	copy true out
	exit
label:	copy false out
	exit

A: 	db 0x1
B:	db 0x0

out:	db 0x0

true:	db 0x1
false:	db 0x0

	db 0x666
	db 0x666
	db 0x666
label1: db label
