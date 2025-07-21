section .rodata
; mascaras para quedarme solo con el canal rojo, verde, azul limpiando otros valores
bytered: db 0x00,0x04,0x08,0x0C,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0
bytegreen: db 0x01,0x05,0x09,0x0D,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0
byteblue: db 0x02,0x06,0x0A,0x0E,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0
bytelumi: db 0x00,0x00,0x00,0xF0,0x01,0x01,0x01,0xF0,0x02,0x02,0x02,0xF0,0x03,0x03,0x03,0xF0

;mascaras coeficientes
mulred: dd 0.2126,0.2126,0.2126,0.2126
mulgreen: dd 0.7152,0.7152,0.7152,0.7152
mulblue: dd 0.0722,0.0722,0.0722,0.0722
alfa: db 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255

SPIXEL EQU 4
;---------------------------------------------------------------------------------------------
section .text
FALSE EQU 0
TRUE  EQU 1

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE 
; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
; ```
;
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
ej1:
	; rdi = rgba_t*  dst
	; rsi  = rgba_t*  src
	; edx = uint32_t width
	; ecx = uint32_t height

	push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

	;usaba directamente mascaras desde direccion de memoria pero me daba error pruebo asignarlarle registros
	movdqu xmm15,[bytered]
	movups xmm14,[mulred]
	movdqu xmm13,[bytegreen]
	movups xmm12,[mulgreen]
	movdqu xmm11,[byteblue]
	movups xmm10,[mulblue]
	movdqu xmm9,[bytelumi]
	movdqu xmm8,[alfa] 

	;voy a procesar de a 4 bits asique me calculo totales
	mov r13d,ecx
	imul r13d,edx
	mov r14d,r13d
	shr r14d, 2
	;miro cuantos me que no proceso de a 4
	mov r15d,r13d
	and r15d, 3 

	xor r12d, r12d

	cmp r14d, 0
	jle .individuales ; si no hay suficientes pixeles para procesar de 4 en 4 paso a individuales

	.de4:
		cmp r12d, r14d
		jge .individuales

		xorps xmm2, xmm2 ; luminosidad
		movdqu xmm0, [rsi] ; cargo 4 pixeles

		;rojo
		movdqu xmm1, xmm0
		pshufb xmm1, xmm15 ; extraigo componente R
		pmovzxbd xmm1, xmm1 ; extiendo a 32
		cvtdq2ps xmm1, xmm1 ; convierto a float
		mulps xmm1, xmm14 ; multiplico por coeficiente rojo
		addps xmm2, xmm1 ; sumo
		;repito tal cual lo que hice con rojo en verde y azul
		;verde
		movdqu xmm1, xmm0
		pshufb xmm1, xmm13
		pmovzxbd xmm1, xmm1
		cvtdq2ps xmm1, xmm1
		mulps xmm1, xmm12
		addps xmm2, xmm1
		;azul
		movdqu xmm1, xmm0
		pshufb xmm1, xmm11
		pmovzxbd xmm1, xmm1
		cvtdq2ps xmm1, xmm1
		mulps xmm1, xmm10
		addps xmm2, xmm1

		;paso res a 8 bits
		cvttps2dq xmm2, xmm2 ; convierto a enteros de 32 bits
		packusdw xmm2, xmm2 ; empaco a enteros de 16 bits
		packuswb xmm2, xmm2 ; empaco a enteros de 8 bits
		pshufb xmm2, xmm9 ; replico el valor de luminosidad
		por xmm2, xmm8 ; pongo alfa en 255

		movdqu [rdi], xmm2 ; guardo 

		add rsi, SPIXEL * 4
		add rdi, SPIXEL * 4
		inc r12d
		jmp .de4

	.individuales:
		test r15d,r15d ; si no quedan pixeles individuales salgo
		jz .fin

		xor r12d, r12d 

	.cicloindividuales:
		cmp r12d, r15d
		jge .fin

		;rojo
		movzx eax, byte [rsi] ; cargo
		cvtsi2ss xmm0,eax
		mulss xmm0, dword [mulred]
		;verde 
		movzx eax, byte [rsi + 1] ; cargo
		cvtsi2ss xmm1,eax
		mulss xmm1, dword [mulgreen]
		addss xmm0, xmm1 ; sumo
		;azul
		movzx eax, byte [rsi + 2] ; cargo
		cvtsi2ss xmm1,eax
		mulss xmm1, dword [mulblue]
		addss xmm0, xmm1 ; sumo
		;
		;paso res a ent
		cvttss2si eax, xmm0

		mov byte[rdi],al
		mov byte[rdi + 1],al
		mov byte[rdi + 2],al
		mov byte[rdi + 3], 255 

		add rsi, SPIXEL ; avanzo al siguiente pixel de la imagen origen
		add rdi, SPIXEL ; avanzo al siguiente pixel de la imagen destino
		inc r12d        ; incremento contador de columnas
		jmp .cicloindividuales

	.fin:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret
