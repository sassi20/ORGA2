section .rodata
align 16
mascara_unos: dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF

section .text
SRCPSIZE EQU 1  ; 8 bits = 1 byte por píxel en src
DSTPSIZE EQU 4  ; 32 bits = 4 bytes por píxel en ds

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	; rdi = int32_t* dst_depth
	; rsi = uint8_t* src_depth
	; edx = int32_t  scale
	; ecx = int32_t  offset
	; r8d = int      width
	; r9d = int      height
   ; rdi = destino (int32_t*)
    ; rsi = origen (uint8_t*)
    ; edx = factor de escala
    ; ecx = factor de desplazamiento
    ; r8d = ancho
    ; r9d = alto
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; Guardar parámetros importantes
	mov r12d, edx        ; r12d = escala
	mov r13d, ecx        ; r13d = offset
	mov r14d, r8d        ; r14d = ancho

	xor r15d, r15d       ; r15d = fila actual

	.filas:
		cmp r15d,r9d
		jge .fin               ; si ya vi todas las filas salgo

		mov rax, r15
		mul r14                ; rax = fila * ancho
		mov r10, rsi
		add r10, rax           ; r10 = puntero a inicio de fila en origen
		lea r11, [rdi + rax*4] ; r11 = puntero a inicio de fila en destino

		xor ecx, ecx           ; ecx = columna actual
	
	.columnas:
		cmp ecx, r14d
		jge .sigfila     ; si ya vi todas las columnas salgo

		mov eax, r14d
		sub eax, ecx

		cmp eax, 4
		jl .casoespecial

	
		movd xmm0, dword [r10 + rcx]
		pmovzxbd xmm0, xmm0 ; converti de 8 bits sin signo a 32 bits con signo

		; Preparar escala en xmm1 (4 copias)
		movd xmm1, r12d
		pshufd xmm1, xmm1, 0

		pmulld xmm0, xmm1 ; multiplico por escala

		; Preparar offset en xmm1 (4 copias)
		movd xmm1, r13d
		pshufd xmm1, xmm1, 0

		paddd xmm0, xmm1
		movdqu [r11 + rcx*4], xmm0 ; ; Guardar el resultado en destino

		add ecx, 4              ; Avanzar 4 píxeles
		jmp .columnas           ; Volver al inicio del bucle de columnas

	.casoespecial:
		test eax, eax
		jz .sigfila      ; Si no quedan píxeles, saltar

	.especial:
		movzx r8d,byte [r10 + rcx] ; Cargar el píxel actual (8 bits sin signo)
		imul r8d, r12d            ; Escalar el píxel (32 bits con signo)
		add r8d, r13d             
		lea r9,[r11+rcx*4]        ; Calcular la dirección de destino
		mov [r9], r8d             ; Guardar el resultado en destino

		;avanzo
		inc ecx
		dec eax
		jnz .especial              

	.sigfila:
		inc r15d                ; incremento filas
		jmp .filas              ; Volver al inicio del bucle de filas

	.fin:
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

;---------------------------------------------------------------------------------
; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; rdi = rgba_t*  dst
	; rsi = rgba_t*  a
	; rdx = int32_t* depth_a
	; rcx = rgba_t*  b
	; r8 = int32_t* depth_b
	; r9 = int      width
	; rbp +16 = int      height
	
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	;guardo height,width y mascara
	mov r13,[rbp+16]
	mov r12d,r9d 
	movdqu xmm15, [mascara_unos]

	xor r14d, r14d     ; i

	.filas:
		cmp r14d, r13d
		jge .fin

		xor r15d, r15d   ; j

	.columnas:
		cmp r15d, r12d
		jge .sigfila

		movdqu xmm0, [rsi] ; A
		movdqu xmm1, [rdx] ; depth A
		movdqu xmm2, [rcx] ; B
		movdqu xmm3, [r8]  ; depth B

		
		pcmpgtd xmm3, xmm1 ; xmm3 = depth B > depth A
		pand xmm0, xmm3    ; uso A

		
		pandn xmm3, xmm15 ; xmm3 = depth A <= depth B
		pand xmm2, xmm3   ; uso B

		por xmm0, xmm2 ;uno
		movdqu [rdi], xmm0 ; guardo

		; avanzo
		add r15d, 4
		add rdi, 16
		add rsi, 16
		add rdx, 16
		add rcx, 16
		add r8,  16
		jmp .columnas
	
	.sigfila:
		inc r14d
		jmp .filas
	
	.fin:
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret
