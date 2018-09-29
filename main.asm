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

buff resb 7
len resb 1

section .text
global _start

_start:
    push introlen
    push intro
    call print

    call getinput

    mov edi, buff
    ;input value already in eax
    call itoa

    push eax
    push buff
    call print

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
    mov edx, 7
    int 0x80
    ;eax has length

    ;too long,
    cmp eax, 7
    je errout
    ;too short
    cmp eax, 1
    je errout

    ;its terminated by \n
    mov edi, buff
    call atoi
    ;eax has the int

    mov esp, ebp
    pop ebp
    ret


itoa:
    ;start at... something
    ;next char
    mov edx, 5
    ;start at the end of the buffer
    add edi, 5

    ;check if its negative
    cmp eax, 0
    jge it_digits

    ;start one higher for - sign at the end
    inc edi
    inc edx
    ; add a negative sign


it_digits:
    cmp eax, 10000
    jge it_5
    dec edi
    dec edx
    cmp eax, 1000
    jge it_4
    dec edi
    dec edx
    cmp eax, 100
    jge it_3
    dec edi
    dec edx
    cmp eax, 10
    jge it_2
    dec edi
    dec edx
    cmp eax, 0
    jge it_1
    jmp errout

it_5:
    push edx
    mov edx, 0
    ;eax already is number to devide
    mov ecx, 10
    idiv ecx
    ;convert digit to printable
    add edx, 48
    mov [edi], edx
    dec edi
    pop edx
it_4:
    push edx
    mov edx, 0
    ;eax already is number to devide
    mov ecx, 10
    idiv ecx
    ;convert digit to printable
    add edx, 48
    mov [edi], edx
    dec edi
    pop edx
it_3:
    push edx
    mov edx, 0
    ;eax already is number to devide
    mov ecx, 10
    idiv ecx
    ;convert digit to printable
    add edx, 48
    mov [edi], edx
    dec edi
    pop edx
it_2:
    push edx
    mov edx, 0
    ;eax already is number to devide
    mov ecx, 10
    idiv ecx
    ;convert digit to printable
    add edx, 48
    mov [edi], edx
    dec edi
    pop edx
it_1:
    push edx
    mov edx, 0
    ;eax already is number to devide
    mov ecx, 10
    idiv ecx
    ;convert digit to printable
    add edx, 48
    mov [edi], edx

    ;pop edx into eax as its how long this string is
    pop eax
    ret

atoi:
    ;start at zero
    mov eax, 0
at_convert:
    ;next char
    movzx esi, byte [edi]
    ;check for \n
    cmp esi, 0xa
    je at_done

    ;less than '0' is invalid
    cmp esi, 48
    jl errout

    ;greater than '9' is invalid
    cmp esi, 57
    jg errout

    ;convert to actual number
    sub esi, 48
    ;multiply by 10
    imul eax, 10
    ;add to total
    add eax, esi

    ;get address of next char
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

