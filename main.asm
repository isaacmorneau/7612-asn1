section     .data

intro db  '7612 Asn 1',0xa
introlen     equ $ - intro

intprompt db 'Please enter a number: '
intpromptlen equ $ - intprompt

section .text
global _start

print:
    push rbp
    mov rbp, rsp

    mov rcx, [rsp + 4]
    mov rdx, [rsp + 8]

    mov rax, 4
    mov rbx, 1
    syscall

    pop rbp
    ret

getinput:
    push rbp
    mov rbp, rsp

    push intprompt
    push intpromptlen
    call print

    pop rbp
    ret

_start:
    mov rax, 1
    syscall

    ;push intro
    ;push introlen
    ;call print

    ;call getinput
    ;call exit



