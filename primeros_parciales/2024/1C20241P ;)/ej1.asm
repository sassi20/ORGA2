ORDERING_TABLE_TAM EQU 16
ORDERING_TABLE_OFFSET_SIZE EQU 0
ORDERING_TABLE_OFFSET_TABLE EQU 8


NODO_OT_TAM EQU 16
NODO_OT_OFFSET_DISPLAY_ELEMENT EQU 0
NODO_OT_OFFSET_SIGUIENTE EQU 8


NODO_DISPLAY_TAM EQU 24
NODO_DISPLAY_OFFSET_PRIMITIVA EQU 0
NODO_DISPLAY_OFFSET_X EQU 8
NODO_DISPLAY_OFFSET_Y EQU 9
NODO_DISPLAY_OFFSET_Z EQU 10
NODO_DISPLAY_OFFSET_SIGUIENTE EQU 16



section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern calloc
extern free


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size) 
inicializar_OT_asm: ; dil = table_size
    push rbp
    mov rbp, rsp
    push r12
    push r13

    movzx r12, dil        ; r12 = table_size

    mov rdi, ORDERING_TABLE_TAM
    call malloc
    mov r13, rax          ; r13 = puntero a ordering_table_t*

    mov [r13+ORDERING_TABLE_OFFSET_SIZE], r12b
    test r12, r12
    je .nozero
    
    movzx rdi, r12b
    mov rsi, 8
    call calloc
    mov [r13+ORDERING_TABLE_OFFSET_TABLE], rax

    jmp .fin

.nozero:
    mov qword [r13 + ORDERING_TABLE_OFFSET_TABLE], 0

.fin:
    mov rax, r13          ; devolver puntero a ordering_table_t*
    pop r13
    pop r12
    pop rbp
    ret

;-----------------------------------------------------------------------------------------------
; void* calcular_z(nodo_display_list_t* display_list) ;
calcular_z_asm: ;rdi = nodo_display_list_t* display_list, sil = uint8_t z_size
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15

    mov r12,rdi
    movzx r13, sil
    mov r14,rdi

    .loop:
        test r14,r14
        je .fin

        mov rax,[r14+NODO_DISPLAY_OFFSET_PRIMITIVA]
        mov dil,byte[r14+NODO_DISPLAY_OFFSET_X]
        mov sil,byte[r14+NODO_DISPLAY_OFFSET_Y]
        mov dl, r13b
        call rax
        mov [r14+NODO_DISPLAY_OFFSET_Z], al

        mov r14,[r14+NODO_DISPLAY_OFFSET_SIGUIENTE]
        jmp .loop

    
    .fin:
    mov rax,r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
;---------------------------------------------------------------------------------------------
; ordenar_display_list_asm(ordering_table_t* ot, nodo_display_list_t* display_list)
; rdi = ot
; rsi = display_list
ordenar_display_list_asm: ; rdi = ordering_table_t* ot, rsi = nodo_display_list_t* display_list
    push rbp
    mov rbp, rsp

    ; preservar registros no volátiles
    push r12         ; display_list actual
    push r13         ; puntero a ordering_table
    push r14         ; puntero a ot->table
    push r15         ; puntero al nuevo nodo_ot

    ; copiar argumentos a registros más cómodos
    mov r13, rdi     ; r13 = ot
    mov r12, rsi     ; r12 = nodo_display_list actual

    ; llamar a calcular_z_asm (por enunciado)
    mov rdi, r12
    xor rsi, rsi
    mov sil, [r13 + ORDERING_TABLE_OFFSET_SIZE] ; rsi = ot->size
    call calcular_z_asm

.loop_display_list:
    cmp r12, 0
    je .fin

    ; reservar espacio para nuevo nodo_ot
    mov rdi, NODO_OT_TAM
    call malloc
    mov r15, rax     ; r15 = nuevo nodo_ot

    ; inicializar nodo_ot
    mov [r15 + NODO_OT_OFFSET_DISPLAY_ELEMENT], r12
    mov qword [r15 + NODO_OT_OFFSET_SIGUIENTE], 0

    ; obtener z actual
    movzx r14, byte [r12 + NODO_DISPLAY_OFFSET_Z] ; r14 = z (expandido a 64 bits)
    imul r14, 8                                   ; r14 *= sizeof(void*) = 8
    mov rbx, [r13 + ORDERING_TABLE_OFFSET_TABLE]  ; rbx = ot->table
    add rbx, r14                                  ; rbx = &ot->table[z]

    ; si no hay lista en ot->table[z], este será el primer nodo_ot
    cmp qword [rbx], 0
    je .insertar_primero

    ; recorrer lista hasta el último nodo_ot
    mov r14, [rbx]      ; r14 = primer nodo_ot
.loop_nodo_ot:
    mov rax, [r14 + NODO_OT_OFFSET_SIGUIENTE]
    cmp rax, 0
    je .insertar_final
    mov r14, rax
    jmp .loop_nodo_ot

.insertar_final:
    mov [r14 + NODO_OT_OFFSET_SIGUIENTE], r15
    jmp .siguiente

.insertar_primero:
    mov [rbx], r15
    jmp .siguiente

.siguiente:
    mov r12, [r12 + NODO_DISPLAY_OFFSET_SIGUIENTE] ; avanzar al próximo nodo_display
    jmp .loop_display_list

.fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
