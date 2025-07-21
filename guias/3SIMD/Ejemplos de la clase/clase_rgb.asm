;Esta función pinta un canvas con distintos colores según la posición en la que se encuentra el pixel. 
;A mayor coordenada X, más intenso el color rojo. 
;A mayor coordenada Y, más intenso el color verde. 
;El origen de coordenadas corresponde a la esquina superior izquierda del canvas, el pixel 0. 
;Además el valor del color azul va a aumentando globalmente con el paso del tiempo, representado por el parámetro 'frames'. (La función se llama múltiples veces incrementando el valor de 'frames', generando una animación en la que el azul va ganando intensidad hasta llegar al tope y empezar de nuevo)

section .data

ALIGN 16
x_en_los_r:
	; Un XMM son 16 bytes, cada 4 bytes es un pixel
	;  Rojo | Verde | Azul | Alfa
	db 0,     0xFF,   0xFF,  0xFF
	db 0,     0xFF,   0xFF,  0xFF
	db 0,     0xFF,   0xFF,  0xFF
	db 0,     0xFF,   0xFF,  0xFF
y_en_los_g:
	db 0xFF,     0,   0xFF,  0xFF
	db 0xFF,     0,   0xFF,  0xFF
	db 0xFF,     0,   0xFF,  0xFF
	db 0xFF,     0,   0xFF,  0xFF
t_en_los_b:
	db 0xFF,  0xFF,      0,  0xFF
	db 0xFF,  0xFF,      0,  0xFF
	db 0xFF,  0xFF,      0,  0xFF
	db 0xFF,  0xFF,      0,  0xFF
x_offsets:
	db 0,        0,      0,     0
	db 1,        0,      0,     0
	db 2,        0,      0,     0
	db 3,        0,      0,     0
alfas:
	db    0,     0,      0,  0xFF
	db    0,     0,      0,  0xFF
	db    0,     0,      0,  0xFF
	db    0,     0,      0,  0xFF

section .text
; void asm_rgb_render(rdi: canvas, rsi: width, rdx: height, ecx: frames)
asm_rgb_render:
	; Cargamos los datos
	movdqa xmm0, [x_en_los_r]
	movdqa xmm1, [y_en_los_g]
	movdqa xmm2, [t_en_los_b]
	movdqa xmm3, [x_offsets]
	movdqa xmm4, [alfas]

	; Esto es equivalente a dividir por 16 el t
	shr ecx, 4

	xor r8, r8
	.y_loop:
		xor rax, rax
		.x_loop:
			; Ponemos X, Y, T en registros vectoriales
			movd xmm5, eax
			movd xmm6, r8d
			movd xmm7, ecx

			; Los acomodamos a lo largo de los registros
			pshufb xmm5, xmm0
			pshufb xmm6, xmm1
			pshufb xmm7, xmm2

			; Agregamos los offsets correspondientes de los X
			paddb xmm5, xmm3

			; Juntamos R con G y con B
			por xmm5, xmm6
			por xmm5, xmm7
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
