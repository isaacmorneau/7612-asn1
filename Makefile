all:
	nasm -g -f elf64 *.asm
	ld -g -m elf_x86_64 -o main *.o
