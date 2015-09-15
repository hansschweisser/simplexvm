	copy arg1 tmp
	and tmp one tmp2
	ifjmp tmp2 zero even
odd:	?

	exit

even:	or arg1 one out1
	exit



arg1:	db 0x0
out1:	db 0x0

one:	db 0x1
zero:	db 0x0

tmp:	db 0x0
tmp2: 	db 0x0