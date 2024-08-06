all:
	as -32 matriz.s -o matriz.o
	ld -m elf_i386 matriz.o -lc -dynamic-linker /lib/ld-linux.so.2 -o matriz