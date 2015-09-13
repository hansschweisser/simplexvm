.PHONY: vm
vm: 
	rm -f *.o vm
	gcc -std=c99 -c page_slab.c page.c cpu.c main.c
	gcc -std=c99 -o vm main.o page_slab.o page.o cpu.o
	rm -f *.o
