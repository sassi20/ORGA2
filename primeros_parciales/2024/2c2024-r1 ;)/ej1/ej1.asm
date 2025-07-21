extern malloc
extern free
section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

FILAS EQU 255
COLUMNAS EQU 255


global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ;

global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
optimizar:
	; rdi = mapa_t           mapa
	; rsi = attackunit_t*    compartida
	; rdx = uint32_t*        fun_hash(attackunit_t*)

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8 ; pila alineada porque son pares

	mov r12, rdi ; mapa
	mov r13, rsi ; compartida
	mov r14, rdx ; fun_hash
	xor r15, r15 ; iterador

	mov r12, rdi ; mapa
	mov r13, rsi ; compartida
	mov r14, rdx ; fun_hash
	xor r15, r15 ; iterador

	; calculo en hash de la unidad compartida
	mov rdi, r13
	call r14 ; devuelve en rax pero en parte baja asique podemos usar eax 
	mov ebx, eax ; hash compartida

.loop:
	mov rdi, [r12 + 8 * r15] ; unidad actual
	cmp rdi, 0 ; ¿Es un null pointer?
	je .nextIteration

	cmp rdi, r13 ; ¿Es compartida == actual?
	je .nextIteration

	call r14 ; la unidad actual ya está en rdi
	cmp eax, ebx ; ¿Es hash_compartida == hash_actual?
	jne .nextIteration

	; actualizo los contadores de referencias
	inc BYTE [r13 + ATTACKUNIT_REFERENCES] ; compartida->references++
	mov rdi, [r12 + 8 * r15] ; unidad actual
	dec BYTE [rdi + ATTACKUNIT_REFERENCES] ; actual->references--
	mov [r12 + 8 * r15], r13 ; mapa[i][j] = compartida

	; ¿tengo que borrar la unidad que acabo de reemplazar?
	cmp BYTE [rdi + ATTACKUNIT_REFERENCES], 0
	jne .nextIteration
	call free ; la unidad actual ya está en rdi

.nextIteration:
	inc r15
	cmp r15, FILAS * COLUMNAS
	jl .loop

	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

;-------------------------------------------------------------------------------------------------
global contarCombustibleAsignado
contarCombustibleAsignado:
	; rdi = mapa_t           mapa
	; rsi = uint16_t*        fun_combustible(char* clase)
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi         ; mapa_t
    mov r13, rsi         ; función combustible
    xor r14d, r14d       ; r14 = total de combustible
    
    xor r8d,r8d         ; fila = 0
.loop:
    mov r15, [r12 + 8 * r8] ; unidad actual
    test r15, r15
    je .nextIteration

    movzx ebx, WORD [r15 + ATTACKUNIT_COMBUSTIBLE] ; actual->combustible

    ; rdi = puntero a clase (sumar offset)
    lea rdi, [r15 + ATTACKUNIT_CLASE] 
    push r8
    push r9
    call r13                 ; llamada a función combustible
    pop r9
    pop r8
    movzx eax, ax            ; resultado 16 bits
    sub ebx, eax             ; combustible_utilizado = actual->combustible - combustible_base
    add r14d, ebx            ; acumular total

.nextIteration:
    inc r8d
    cmp r8d, FILAS * COLUMNAS
    jl .loop

    mov eax, r14d

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
	
;---------------------------------------------------------------------------------
global modificarUnidad
modificarUnidad:
	; rdi = mapa_t           mapa
	; sil  = uint8_t          x
	; dl  = uint8_t          y
	; rcx = void*            fun_modificar(attackunit_t*)
modificarUnidad:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; mapa -> rdi
    ; x    -> sil
    ; y    -> dl
    ; fun_modificar -> rcx

    movzx r12d, sil        ; r12d = x
    imul r12d, 255         ; r12d *= COLUMNAS
    add r12d, edx          ; r12d += y
    mov r13, rdi           ; r13 = mapa
    mov r14, rcx           ; r14 = fun_modificar
    mov r15, r12           ; offset en unidades
    shl r15, 3             ; r15 = r15 * 8 -> offset en bytes

    mov r12, [r13 + r15]   ; r12 = unidad en mapa[x][y]
    test r12, r12
    je .fin                ; si no hay unidad, salir

    ; si references > 1, hay que clonar
    movzx eax, byte [r12 + ATTACKUNIT_REFERENCES]
    cmp al, 1
    jbe .modificar         ; si <= 1 no hace falta clonar

    ; Hay que clonar
    mov edi, ATTACKUNIT_SIZE
    call malloc
    test rax, rax
    je .fin                ; si malloc falla, salir

    ; rax = puntero a nueva unidad
    mov rbx, rax           ; rbx = nueva unidad

    ; copiar contenido
    mov rcx, ATTACKUNIT_SIZE
    mov rsi, r12           ; origen = unidad original
    mov rdi, rbx           ; destino = nueva unidad
    rep movsb

    ; nueva->references = 1
    mov byte [rbx + ATTACKUNIT_REFERENCES], 1

    ; original->references--
    dec byte [r12 + ATTACKUNIT_REFERENCES]

    ; guardar nueva en el mapa
    mov [r13 + r15], rbx
    mov r12, rbx           ; r12 ahora apunta a la nueva unidad

.modificar:
    mov rdi, r12           ; pasar la unidad como argumento
    call r14               ; llamar a fun_modificar(unidad)

.fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
