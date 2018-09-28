all:
	nasm -g -O0 -f elf32 *.asm
	ld -g -m elf_i386 -o main *.o
