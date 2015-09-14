	ifjmp2 A B LABEL
	ifjmp2 zero zero LABEL2

label:	copy flag out
	ifjmp2 zero zero END

label2: copy galf out
	ifjmp2 zero zero END

end:	copy quit out2


A:	db 0x0
B:	db 0x0

zero:	db 0x0
one:	db 0x1
two:	db 0x2
flag:	db 0xffffffff
galf:	db 0x77777777
quit:	db 0xaaaaaaaa

out:	db 0x0
out2:	db 0x0

LABEL:	db label
LABEL2: db label2
END:	db end