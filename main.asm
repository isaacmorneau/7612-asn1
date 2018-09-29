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

divisorTable:
    dd 1000000000
    dd 100000000
    dd 10000000
    dd 1000000
    dd 100000
    dd 10000
    dd 1000
    dd 100
    dd 10
    dd 1
    dd 0

section .bss

buff resb 7
temp resb 2
len resw 1

section .text
global _start

_start:
    push introlen
    push intro
    call print

    call getinput

    ;input value already in eax
    call print_num

    ;newline for a cleaner terminal
    mov eax, 0xa
    call print_char

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
    ret 8


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

print_char:
    push eax
    push ebx
    push ecx
    push edx


    mov [temp], eax
    mov [temp+1],byte 0
    mov ecx, temp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov edx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

;adapted from https://stackoverflow.com/a/13523734, thanks Brendan
print_num:
    push eax
    push ebx
    push ecx
    push edx
    mov ebx,divisorTable
    ;start flag as supressing leading zeros
    mov ecx, 0
    cmp eax, 0
    jge .next_digit
    ;handle printing negatives
    push eax
    mov eax, 0x2d
    call print_char
    pop eax
    neg eax
.next_digit:
    xor edx,edx          ;edx:eax = number
    div dword [ebx]      ;eax = quotient, edx = remainder
    ;if 1 keep all chars
    cmp ecx, 1
    je .keep_char
    cmp eax, 0
    je .sub_zero
    ;if we're here its the first non leading zero
    mov ecx, 1
.keep_char:
    add eax,'0'
    call print_char
.sub_zero:
    mov eax,edx          ;eax = remainder
    add ebx,4            ;ebx = address of next divisor
    cmp dword [ebx],0    ;Have all divisors been done?
    jne .next_digit
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

atoi:
    ;start at zero
    ;assume not negative to start
    xor eax, eax
    push eax
    movzx esi, byte [edi]
    ;is it a negative
    cmp esi, 45
    jne .at_convert
    ;is it actually just empty
    cmp esi, 0xa
    je .at_done
    ;yes
    pop eax
    mov eax, -1
    push eax
    xor eax, eax
    inc edi
    ;no
.at_convert:
    ;next char
    movzx esi, byte [edi]
    ;check for \n
    cmp esi, 0xa
    je .at_done

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
    jmp .at_convert
.at_done:
    ;handle negative
    pop ebx
    test ebx, ebx
    je .at_over
    ;make sure to set it to negative if the flag was set
    neg eax
.at_over:
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

