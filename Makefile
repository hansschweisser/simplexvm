.PHONY: vm
vm: 
	rm -f *.o vm
	gcc -std=c99 -c page_slab.c page.c cpu.c main.c control.c
	gcc -std=c99 -o vm main.o page_slab.o page.o cpu.o control.o
	rm -f *.o
