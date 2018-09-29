all:
	mkdir -p bin
	nasm -g -O0 -f elf32 -o bin/main.o src/main.asm
	ld -g -m elf_i386 -o bin/main bin/main.o
