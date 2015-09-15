		and arg1 firstbit out
		ifjmp out zero	even
		ifjmp zero zero odd
even:		exit	

odd:		exit




arg1:		db 0xabcdef0

firstbit:	db 0x1
zero:		db 0x0

out:		db 0xabcdef