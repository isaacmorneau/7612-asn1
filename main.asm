;constants

SYS_EXIT  equ 1
SYS_WRITE equ 4
SYS_READ  equ 3

STDIN     equ 0
STDOUT    equ 1
STDERR    equ 2

section     .data

intro db '7612 Asn 1',0xa,0
introlen equ $-intro

intprompt db 'Please enter a number: '
intpromptlen equ $-intprompt

errprompt db 'Only numbers between 0 and 65535 allowed',0xa,0
errpromptlen equ $-errprompt

section .bss

buff resb 6
len resb 1

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

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, buff
    mov edx, 6
    int 0x80
    ;eax has length
    cmp eax, 6
    jge errout

    ;its terminated by \n
    mov edi, buff
    call atoi

    mov esp, ebp
    pop ebp
    ret

atoi:
    ; start at zero
    mov eax, 0
at_convert:
    ; next char
    movzx esi, byte [edi]
    ; check for \n
    cmp esi, 0xa
    je at_done

    ; less than '0' is invalid
    cmp esi, 48
    jl errout

    ; greater than '9' is invalid
    cmp esi, 57
    jg errout

    ; convert to actual number
    sub esi, 48
    ; multiply by 10
    imul eax, 10
    ; add to total
    add eax, esi

    ; get address of next char
    inc edi
    jmp at_convert
at_done:
    ;return total
    ret

errout:
    push errpromptlen
    push errprompt
    call print
exit:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

