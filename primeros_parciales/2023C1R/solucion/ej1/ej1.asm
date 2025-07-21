global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

extern calloc 
extern strcmp
extern malloc

;########### SECCION DE TEXTO (PROGRAMA)
section .text
CCLIENT EQU 10
TINT32 EQU 4
OFMONTO EQU 0
OFCOMERCIO EQU 8
OFCLIENTE EQU 16
OFAPROBADO EQU 17
OFNEXT EQU 24

acumuladoPorCliente_asm: ; dil = cantidadDePagos, rsi = arr_pagos
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14

    xor r12, r12
    mov r12b, dil            ; r12b = cantidad de pagos
    mov r13, rsi             ; r13 = puntero a arr_pagos

    mov rdi, 10              ; 10 clientes
    mov rsi, 4               ; sizeof(uint32_t)
    call calloc
    mov r14, rax             ; r14 = puntero al arreglo acumulador

.loop:
    cmp r12b, 0x0
    je .fin

    cmp BYTE [r13 + OFAPROBADO], 1
    jne .siguiente

    xor rcx, rcx
    mov cl, [r13 + OFMONTO]    ; monto
    xor rsi, rsi
    mov sil, [r13 + OFCLIENTE] ; cliente
    mov rax, 4
    mul sil                              ; offset = cliente * 4

    add BYTE [r14 + rax], cl             ; sumamos al acumulador

.siguiente:
    dec r12b
    add r13, OFNEXT
    jmp .loop

.fin:
    mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; rdi: puntero a comercio
; rsi: puntero a la lista de comercios
; dl: tamaño de la lista
en_blacklist_asm:
   push rbp
   mov rbp,rsp
   push r12
   push r13
   push r14
   sub rsp,8

   mov r12,rdi
   mov r13,rsi
   xor r14,r14
   mov r14b,dl

.loop_lista_comercios:
	cmp r14b,0
	je .fin_loop_lista_comercios

	mov rdi,r12
	mov rcx,qword[r13]
	mov rsi,rcx
	call strcmp

	cmp ax,0
	jne .siguiente
	mov rax,1
	jmp .fin_loop_lista_comercios

.siguiente:
	dec r14b
	add r13,8
	xor rax,rax
	jmp .loop_lista_comercios

.fin_loop_lista_comercios:
	add rsp,8
	pop r14
	pop r13   ; ✅ corregido
	pop r12   ; ✅ corregido
	pop rbp
	ret

blacklistComercios_asm:
	push rbp
	mov rbp,rsp
	push rbx     ; ✅ corregido orden
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	xor r12,r12
	mov r12b, dil 
	mov r13,rsi
	mov r14,rdx
	xor r15,r15
	mov r15b,cl
	xor rbx,rbx

	call totalDePagosBlacklist_asm

	mov rdi, rax
	mov rsi, 8
	call calloc

	mov rbx, rax
	mov r8, rax ;uso r8 para recorrer la lista e ir guardando los punteros
	
.loop_pagos:
	cmp r12b, 0x0
	je .fin_loop_pagos

	push r8
	sub rsp, 8
	mov rdi, [r13 + OFCOMERCIO]
	mov rsi, r14
	xor rdx, rdx
	mov dl, r15b
	call en_blacklist_asm
	add rsp, 8
	pop r8
	cmp ax, 1
	jne .siguiente_loop_pagos
	mov [r8], r13
	add r8, 8

.siguiente_loop_pagos:
	dec r12b
	add r13, OFNEXT
	jmp .loop_pagos

.fin_loop_pagos:
	mov rax, rbx
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx     ; ✅ corregido orden
	pop rbp
	ret

totalDePagosBlacklist_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	xor r12, r12
	mov r12b, dil ;r12b = uint8_t cantidad_pagos
	mov r13, rsi ; r13 =  pago_t* pagos
	mov r14, rdx ; r14 = char** arr_comercios
	xor r15, r15 
	mov r15b, cl ;r15b = uint8_t size_comercios

	xor rbx, rbx ; rbx = resultado total
.loop_lista_pagos:
	cmp r12b, 0x0
	je .fin_loop_lista_pagos

	mov rdi, [r13 + OFCOMERCIO]
	mov rsi, r14
	xor rdx, rdx
	mov dl, r15b
	
	call en_blacklist_asm

	cmp ax, 1
	jne .siguiente_loop_lista_pagos
	inc rbx

.siguiente_loop_lista_pagos:
	dec r12b
	add r13, OFNEXT
	jmp .loop_lista_pagos

.fin_loop_lista_pagos:
	mov rax, rbx
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
