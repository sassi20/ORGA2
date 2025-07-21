global templosClasicos
global cuantosTemplosClasicos
global templovintage
extern malloc



;########### SECCION DE TEXTO (PROGRAMA)
section .text
OFFCL EQU 0
OFFNOM EQU 8
OFFCC EQU 16
OFFTEMPLO EQU 24

;----------------------------------
templovintage:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    xor r12,r12
    xor r13,r13


    movzx r13, byte[rdi + OFFCC]
    imul r13, r13, 2              
    add r13, 1                    

    movzx r12, byte [rdi + OFFCL]

    xor rax, rax
    cmp r13,r12
    jne .fin        ; Si no son iguales, salto a .fin
    mov rax, 1      ; Si son iguales, rax = 1 (es templo clásico)

.fin:
    pop r13
    pop r12
    pop rbp
    ret


;----------------------------------
cuantosTemplosClasicos:
    push rbp
    mov rbp,rsp
    push rbx
    push r12
    push r13
    sub rsp,8

    mov rbx,rdi
    mov r12,rsi
    xor r13,r13
    xor rcx,rcx

    .loop:
        cmp rcx,r12
        jge .fin

        mov rdx, rcx
        imul rdx, OFFTEMPLO           ; offset = índice * tamaño struct
        lea rdi, [rbx + rdx]  

        call templovintage

        cmp rax,1
        jne .skip
        inc r13

    .skip:
        inc rcx
        jmp .loop


    .fin:
        mov eax,r13d
        add rsp,8
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret

;------------------------------------------------------------------------
templosClasicos:
    templosClasicos:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi          ; arreglo original
    mov r12, rsi          ; longitud

    mov rdi, rbx
    mov rsi, r12
    call cuantosTemplosClasicos
    mov r13, rax          ; cantidad clásicos

    test r13, r13
    je .nohayclasicos

    imul rdi, r13, OFFTEMPLO
    call malloc
    mov r14, rax          ; nuevo arreglo
    xor rcx, rcx          ; índice original
    xor r13, r13          ; offset nuevo arreglo

.bucle:
    cmp rcx, r12
    jge .finbucle

    imul rdx, rcx, OFFTEMPLO
    lea rsi, [rbx + rdx]
    mov rdi, rsi
    call templovintage
    test rax, rax
    jz .continuar

    movzx r8, byte [rsi + OFFCL]
    mov [r14 + r13 + OFFCL], r8b

    mov r8, [rsi + OFFNOM]
    mov [r14 + r13 + OFFNOM], r8

    movzx r8, byte [rsi + OFFCC]
    mov [r14 + r13 + OFFCC], r8b

    add r13, OFFTEMPLO

.continuar:
    inc rcx
    jmp .bucle

.finbucle:
    mov rax, r14
    jmp .fin

.nohayclasicos:
    xor rax, rax

.fin:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret