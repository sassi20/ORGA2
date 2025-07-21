; Esta función dibuja un círculo en el canvas, su centro se alinea con el del canvas.

section .data

ALIGN 16
d_en_los_canales:
	; Un XMM son 16 bytes, cada 4 bytes es un pixel
	;  Rojo | Verde | Azul | Alfa
	db  0,       0,      0,  0xFF
	db  4,       4,      4,  0xFF
	db  8,       8,      8,  0xFF
	db 12,      12,     12,  0xFF
x_offsets: dd 0.0, 1.0, 2.0, 3.0
alfas:
	db    0,     0,      0,  0xFF
	db    0,     0,      0,  0xFF
	db    0,     0,      0,  0xFF
	db    0,     0,      0,  0xFF
; Posición del círculo
pos:
	.x: dd 256.0
	.y: dd 256.0

section .text
; void asm_circulo_render(rdi: canvas, rsi: width, rdx: height, ecx: frames)
asm_circulo_render:
	; Cargamos los datos
	movss xmm0, [pos.x]
	movss xmm1, [pos.y]
	movdqa xmm2, [x_offsets]
	movdqa xmm3, [d_en_los_canales]
	movdqa xmm4, [alfas]

	; Cuando calculamos el X lo hacemos con 4 X distintos
	shufps xmm0, xmm0, 0b00_00_00_00

	xor r8, r8
	.y_loop:
		xor rax, rax
		.x_loop:
			; Ponemos X, Y en registros vectoriales y los convertimos a floats
			cvtsi2ss xmm5, eax
			cvtsi2ss xmm6, r8d

			; En realidad estamos procesando 4 X distintos, corrijamos eso
			shufps xmm5, xmm5, 0b00_00_00_00
			addps xmm5, xmm2

			; Calculamos la distancia al centro del círculo en cada eje
			subps xmm5, xmm0
			subss xmm6, xmm1

			; Elevamos cada componente al cuadrado
			mulps xmm5, xmm5
			mulss xmm6, xmm6

			; Broadcasteamos el Y al resto del registro
			shufps xmm6, xmm6, 0b00_00_00_00

			; Sumamos las componentes
			addps xmm5, xmm6

			; Calculamos la raíz cuadrada
			sqrtps xmm5, xmm5

			; Pasamos a enteros
			cvttps2dq xmm5, xmm5

			; Cargamos el radio del círculo
			mov r9d, 200
			movd xmm6, r9d
			pshufd xmm6, xmm6, 0b00_00_00_00

			; Nos fijamos si la distancia cae adentro o no
			pcmpgtd xmm5, xmm6

			; Copiamos los 8 bits menos significativos a cada canal
			pshufb xmm5, xmm3

			;mov r9d, 0xFF_FF_88_88
			;movd xmm6, r9d
			;pshufd xmm6, xmm6, 0b00_00_00_00

			;mov r9d, 0xFF_88_FF_FF
			;movd xmm7, r9d
			;pshufd xmm7, xmm7, 0b00_00_00_00

			;pand xmm6, xmm5			
			;pandn xmm5, xmm7

			;por xmm5, xmm6

			; Fixeamos el alfa
			por xmm5, xmm4

			; Escribimos el resultado a memoria
			movdqu [rdi], xmm5
			add rdi, 16
			add rax, 4
			cmp rax, rsi
			jb .x_loop

		add r8, 1
		cmp r8, rdx
		jb .y_loop
	ret
