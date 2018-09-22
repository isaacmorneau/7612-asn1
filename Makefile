all:
	nasm -f elf32 *.asm
	ld -m elf_i386 -o main *.o
