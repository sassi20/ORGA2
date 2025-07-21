; Presentamos en clase estas dos implementaciones de funciones que dado un canvas lo pintan todo de un mismo color. La primer solución no utiliza instrucciones SIMD, la segunda sí.

section .data

ALIGN 16
motivo:
	; Un XMM son 16 bytes, cada 4 bytes es un pixel
	;  Rojo | Verde | Azul | Alfa
	db 255,   255,    255,   255
	db 255,   255,    255,   255
	db 255,   255,    255,   255
	db 255,   255,    255,   255

section .text

; void asm_pantalla_render_NOSIMD(rdi: canvas, rsi: width, rdx: height)
asm_pantalla_render_NOSIMD:
	;          A  B  G  R
	mov r9d, 0xFF_FF_FF_FF

	xor r8, r8
	.y_loop:
		xor rax, rax
		.x_loop:
			; Escribimos el valor de estos 4 píxeles a memoria
			mov [rdi], r9d
			add rdi, 4
			add rax, 1
			cmp rax, rsi
			jb .x_loop

		add r8, 1
		cmp r8, rdx
		jb .y_loop
	ret

; void asm_pantalla_render(rdi: canvas, rsi: width, rdx: height)
asm_pantalla_render:
	movdqa xmm0, [motivo]

	xor r8, r8
	.y_loop:
		xor rax, rax
		.x_loop:
			; Escribimos el valor de estos 4 píxeles a memoria
			movdqu [rdi], xmm0
			add rdi, 16
			add rax, 4
			cmp rax, rsi
			jb .x_loop

		add r8, 1
		cmp r8, rdx
		jb .y_loop
	ret
