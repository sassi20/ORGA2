section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp

LISTA_FIRST EQU 0
LISTA_LAST EQU 8
LISTA_TAM EQU 16

LISTA_ELEM_TAM EQU 24
LIST_E_DATA EQU 0
LIST_E_NEXT EQU 8
LIST_E_PREV EQU 16

OFFPAGO_MONTO EQU 0
OFFPAGO_APRO EQU 1
OFFPAGO_PAGADOR EQU 8
OFFPAGO_COBRADOR EQU 16
OFFPAGO_SIZE EQU 24

OFFSPLT_APRO EQU 0
OFFSPLT_RECHA EQU 1
OFFSLT_PRECHA EQU 8
OFFSLT_PAPRO EQU 16
OFFSLT_SIZE EQU 24

;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
contar_pagos_aprobados_asm:
    ;rdi = list_t* pList. rsi = char* usuario.
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15 

    mov r12, rdi ;r12 = list_t* pList. r13 = char* usuario.
    mov r13, rsi

    xor r14, r14 ; r14 = total de aprobados
    mov r15, [rdi + LISTA_FIRST] ;r15 = indice para recorrer la lista


    ;utilizo r14 para guardar el total y r15 para usar como indice. En cada iteración del loop debo llamar a strcmp,
    ;por ende uso registros no volatiles

    .loop:
        cmp r15, 0x0
        je .fin

        cmp DWORD[r15 + LIST_E_DATA], 0x0
        je .next
        mov rdx, [r15 + LIST_E_DATA] ;rdx = pago_t* data

        mov rdi, [rdx + OFFPAGO_COBRADOR] ; rdi = char* cobrador
        mov rsi, r13 ;rsi = char* usuario

        call strcmp

        ;chequeo si es el mismo usuario
        cmp rax, 0
        jne .next 

        ;chequeo si el pago está aprobado
        mov rdx, [r15 + LIST_E_DATA]
        mov dil, BYTE [rdx + OFFPAGO_APRO]
        cmp dil, 1 ; aprovados
        jne .next

        inc r14b

    .next:
        mov rdx, [r15 + LIST_E_NEXT]
        mov r15, rdx
        jmp .loop

        
    .fin:
        mov al, r14b
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret


;--------------------------------------------------------------------------------------------
; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
    ;rdi = list_t* pList. rsi = char* usuario.
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15 

    mov r12, rdi ;r12 = list_t* pList. r13 = char* usuario.
    mov r13, rsi

    xor r14, r14 ; r14 = total de aprobados
    mov r15, [rdi + LISTA_FIRST] ;r15 = indice para recorrer la lista


    ;utilizo r14 para guardar el total y r15 para usar como indice. En cada iteración del loop debo llamar a strcmp,
    ;por ende uso registros no volatiles

    .loop2:
        cmp r15, 0x0
        je .fin2

        cmp DWORD[r15 + LIST_E_DATA], 0x0
        je .next2
        mov rdx, [r15 + LIST_E_DATA] ;rdx = pago_t* data

        mov rdi, [rdx + OFFPAGO_COBRADOR] ; rdi = char* cobrador
        mov rsi, r13 ;rsi = char* usuario

        call strcmp

        ;chequeo si es el mismo usuario
        cmp rax, 0
        jne .next2 

        ;chequeo si el pago está aprobado
        mov rdx, [r15 + LIST_E_DATA]
        mov dil, BYTE [rdx + OFFPAGO_APRO]
        cmp dil, 0 ; no aprobados 
        jne .next2

        inc r14b

    .next2:
        mov rdx, [r15 + LIST_E_NEXT]
        mov r15, rdx
        jmp .loop2

        
    .fin2:
        mov al, r14b
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret

;-------------------------------------------------------------------------------------------
; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
    ;preservo los parámetros
    mov r12, rdi
    mov r13, rsi

    mov rdi, OFFSLT_SIZE
    call malloc 

    mov r14, rax  ; r14 = pagoSplitted_t *

    mov rdi, r12
    mov rsi, r13
    call contar_pagos_aprobados_asm

    mov BYTE[r14 + OFFSPLT_APRO], al

    mov rdi, r12
    mov rsi, r13
    mov dl, al
    call pagos_aprobados_usuario_asm

    mov [r14 + OFFSLT_PAPRO], rax

    mov rdi, r12
    mov rsi, r13
    call contar_pagos_rechazados_asm

    mov BYTE[R14 + OFFSPLT_RECHA], al


    mov rdi, r12
    mov rsi, r13
    mov dl, al
    call pagos_rechazados_usuario_asm

    mov [r14 + OFFSLT_PRECHA], rax

    mov rax, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


    ;pago_t** pagos_aprobados_usuario_asm(list_t* pList, char* usuario, uint8_t cantidad_pagos_aprobados) 
    pagos_aprobados_usuario_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ;preservo los parámetros
    mov r12, rdi
    mov r13, rsi
    mov r14b, dl

    xor rax, rax
    xor rcx, rcx
    xor rdi, rdi
    mov ax, dx     
    mov cx, 8      
    mul cx         
    mov di, ax     
    call malloc
    ;rax = pago_t**


    mov r15, rax ;preservo el puntero

    cmp r14b, 0x0 ;chequeo si el array debe ser vacío
    je fin3


    mov r14, rax ;uso r14 como indice para recorrer el array


    loop3:
    cmp r12, 0 ;uso r12 como indice para recorrer la pList
    je fin3


    ;chequeo mismo usuario
    mov rdi, r13

    mov rdx, [r12 + LIST_E_DATA]
    mov rsi, [rdx + OFFPAGO_COBRADOR]
    cmp rsi, 0x0
    je next3

    call strcmp
    cmp rax, 0
    jne next3 


    ;chequeo si el pago está aprobado
    mov rdx, [r12 + LIST_E_DATA]
    mov dil, BYTE [rdx + OFFPAGO_APRO]
    cmp dil, 1
    jne next3

    ;copio el puntero al pago_t hallado
    mov r14, [r12 + LIST_E_DATA]


    next3:
    mov rdx, [r12 + LIST_E_NEXT]
    mov r12, rdx
    add r14, 8
    jmp loop3


    fin3:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret







    ;pago_t** pagos_rechazados_usuario_asm(list_t* pList, char* usuario, uint8_t cantidad_pagos_rechazados) 
    pagos_rechazados_usuario_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ;preservo los parámetros
    mov r12, rdi
    mov r13, rsi
    mov r14b, dl

    xor rax, rax
    xor rcx, rcx
    xor rdi, rdi
    mov ax, dx     
    mov cx, 8      
    mul cx         
    mov di, ax     
    call malloc
    ;rax = pago_t**

    mov r15, rax ;preservo el puntero

    cmp r14b, 0x0 ;chequeo si el array debe ser vacío
    je fin4


    mov r14, rax ;uso r14 como indice para recorrer el array

    loop4:
    cmp r12, 0 ;uso r12 como indice para recorrer la pList
    je fin4


    ;chequeo mismo usuario
    mov rdi, r13

    mov rdx, [r12 + LIST_E_DATA]
    mov rsi, [rdx + OFFPAGO_COBRADOR]
    cmp rsi, 0x0
    je next4

    call strcmp
    cmp rax, 0
    jne next4 


    ;chequeo si el pago está aprobado
    mov rdx, [r12 + LIST_E_DATA]
    mov dil, BYTE [rdx + OFFPAGO_APRO]
    cmp dil, 0
    jne next4

    ;copio el puntero al pago_t hallado
    mov r14, [r12 + LIST_E_DATA]


    next4:
    mov rdx, [r12 + LIST_E_NEXT]
    mov r12, rdx
    add r14, 8
    jmp loop4


    fin4:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
