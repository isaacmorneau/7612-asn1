;Isaac Morneau
;A00958405
;constants
SYS_EXIT  equ 1
SYS_WRITE equ 4
SYS_READ  equ 3

STDIN     equ 0
STDOUT    equ 1
STDERR    equ 2

section     .data

intro db '7612 Asn 1',0xa,'Number order: nvalue, val1, val2, val3',0xa
introlen equ $-intro

intprompt db 'Please enter a number: '
intpromptlen equ $-intprompt

pcase0 db 'Case 0: '
pcase0len equ $-pcase0
pcase1 db 'Case 1: '
pcase1len equ $-pcase1
pcase2 db 'Case 2: '
pcase2len equ $-pcase2
pcase3 db 'Case 3: '
pcase3len equ $-pcase3
pcasedefault db 'Default'
pcasedefaultlen equ $-pcasedefault

errinval db 'Invalid input detected',0xa
errinvallen equ $-errinval

errrange db 'Only numbers between 0 and 65535 allowed in values',0xa
errrangelen equ $-errrange

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

buff resb 11
temp resb 1
nvalue resd 1
val1 resd 1
val2 resd 1
val3 resd 1

section .text
global _start

_start:
    push introlen
    push intro
    call print

    ;get nvalue
    call getinput
    mov [nvalue], eax

    ;get and bounds check val1-3
    call getinput
    mov [val1], eax
    cmp eax, 0xffff
    jg eerrrange
    cmp eax, 0
    jl eerrrange

    call getinput
    mov [val2], eax
    cmp eax, 0xffff
    jg eerrrange
    cmp eax, 0
    jl eerrrange

    call getinput
    mov [val3], eax
    cmp eax, 0xffff
    jg eerrrange
    cmp eax, 0
    jl eerrrange

    mov eax, [nvalue]
    inc eax; ++nvalue

    cmp eax, 0 ;case0
    je case0
    cmp eax, 1 ;case1
    je case1
    cmp eax, 2 ;case2
    je case2
    cmp eax, 3 ;case3
    je case3
    jmp casedefault;default

;switch
case0:
    push pcase0len
    push pcase0
    call print
    mov eax, [val1]
    imul eax, [val2]
    call print_num
    jmp exit
case1:
    push pcase1len
    push pcase1
    call print
    mov eax, [val2]
    imul eax, [val3]
    call print_num
    jmp exit
case2:
    push pcase2len
    push pcase2
    call print
    mov eax, [val3]
    sub eax, [val1]
    call print_num
    jmp exit
case3:
    push pcase3len
    push pcase3
    call print
    mov eax, [val1]
    sub eax, [val3]
    call print_num
    jmp exit
casedefault:
    push pcasedefaultlen
    push pcasedefault
    call print
    jmp exit

;print out a string with the length and string pushed to the stack
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

;read input into a buffer and convert it to an int
getinput:
    push ebp
    mov ebp, esp

    push intpromptlen
    push intprompt
    call print

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, buff
    mov edx, 11
    int 0x80
    ;eax has length

    ;too long,
    cmp eax, 11
    je eerrinval
    ;too short
    cmp eax, 1
    je eerrinval

    ;its terminated by \n
    mov edi, buff
    call atoi
    ;eax has the int

    mov esp, ebp
    pop ebp
    ret

;print the char in eax
print_char:
    push eax
    push ebx
    push ecx
    push edx


    mov [temp], eax
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
;print the char in eax
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

;convert edi to an int and return it in eax
atoi:
    xor eax, eax
    push eax
    movzx esi, byte [edi]
    ;is it a negative
    cmp esi, 45
    jne .at_convert
    ;is it actually just empty
    cmp esi, 0xa
    je .at_done
    ;-
    pop eax
    mov eax, -1
    push eax
    xor eax, eax
    inc edi
    ;+
.at_convert:
    ;next char
    movzx esi, byte [edi]
    ;check for \n
    cmp esi, 0xa
    je .at_done
    ;less than '0' is invalid
    cmp esi, 48
    jl eerrinval
    ;greater than '9' is invalid
    cmp esi, 57
    jg eerrinval

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

;input was fatally incorrect
eerrinval:
    push errinvallen
    push errinval
    call print
    jmp exit
;input failed bounds check
eerrrange:
    push errrangelen
    push errrange
    call print
;cleanly exit
exit:
    ;newline for a cleaner terminal after
    mov eax, 0xa
    call print_char

    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

