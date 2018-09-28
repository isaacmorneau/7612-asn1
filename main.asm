;constants

SYS_EXIT  equ 1
SYS_WRITE equ 4
SYS_READ  equ 3

STDIN     equ 0
STDOUT    equ 1
STDERR    equ 2

section     .data

intro        db '7612 Asn 1',0xa,0
introlen     equ $-intro

intprompt    db 'Please enter a number: '
intpromptlen equ $-intprompt


section .bss

buff resb 6

section .text
global _start


_start:
    push introlen
    push intro
    call print

    call getinput

    jmp exit


print:
    push ebp
    mov ebp, esp

    mov ecx, [ebp + 8]
    mov edx, [ebp + 12]

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    int 0x80

    mov esp, ebp
    pop ebp
    ret


getinput:
    push ebp
    mov ebp, esp

    push intpromptlen
    push intprompt
    call print

    mov esp, ebp
    pop ebp
    ret

exit:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

