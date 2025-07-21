section .rodata
; Máscaras para extraer canales de color
bytered: db 0x00,0x04,0x08,0x0C,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0
bytegreen: db 0x01,0x05,0x09,0x0D,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0
byteblue: db 0x02,0x06,0x0A,0x0E,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0

; Constantes para los cálculos
divisor: dd 3.0, 3.0, 3.0, 3.0
sumagreen: dd 64, 64, 64, 64
sumablue: dd 128, 128, 128, 128
alfa: db 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; Constantes para la función f(x)
const_192: dd 192, 192, 192, 192
const_4: dd 4, 4, 4, 4
const_384: dd 384, 384, 384, 384
const_255: dd 255, 255, 255, 255

; Máscara para reordenar los bytes en el resultado final
reordenar: db 0x0C,0x08,0x04,0x00, 0x0D,0x09,0x05,0x00, 0x0E,0x0A,0x06,0x00, 0x0F,0x0B,0x07,0x00

TAMANO_PIXEL EQU 4

section .text
FALSE EQU 0
TRUE  EQU 1
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Aplica un efecto de "mapa de calor" sobre una imagen dada (`src`). Escribe la
; imagen resultante en el canvas proporcionado (`dst`).
;
; Para calcular el mapa de calor lo primero que hay que hacer es computar la
; "temperatura" del pixel en cuestión:
; ```
; temperatura = (rojo + verde + azul) / 3
; ```
;
; Cada canal del resultado tiene la siguiente forma:
; ```
; |          ____________________
; |         /                    \
; |        /                      \        Y = intensidad
; | ______/                        \______
; |
; +---------------------------------------
;              X = temperatura
; ```
;
; Para calcular esta función se utiliza la siguiente expresión:
; ```
; f(x) = min(255, max(0, 384 - 4 * |x - 192|))
; ```
;
; Cada canal esta offseteado de distinta forma sobre el eje X, por lo que los
; píxeles resultantes son:
; ```
; temperatura  = (rojo + verde + azul) / 3
; salida.rojo  = f(temperatura)
; salida.verde = f(temperatura + 64)
; salida.azul  = f(temperatura + 128)
; salida.alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.

global ej2
ej2:
	; rdi = rgba_t*  dst
    ; rsi = rgba_t*  src
    ; edx = uint32_t width
    ; ecx = uint32_t height
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	;cargo mascaras y constantes para utilizar luego
	movdqu xmm15, [bytered]
	movdqu xmm14, [bytegreen]
	movdqu xmm13, [byteblue]
	movdqu xmm12, [divisor]
	movdqu xmm11, [sumagreen]
	movdqu xmm10, [sumablue]
	movdqu xmm9, [reordenar]
	movdqu xmm8, [alfa]
	movdqu xmm7, [const_192]
	movdqu xmm6, [const_4]
	movdqu xmm5, [const_384]
	movdqu xmm4, [const_255]

	xor r12d,r12d ;contador	
	
	.filas:
		cmp r12d, ecx
		jge .fin_filas ; Si r12 >= height
		
		xor r13d,r13d

	.columnas:
		cmp r13d, edx
		jge .fin_columnas ; Si r13 >= width

		movdqu xmm0, [rsi] ; agarro pixel actual

		;calculo (r+v+a)/3
		pxor xmm3,xmm3
		;rojo
		movdqa xmm1, xmm0
    	pshufb xmm1, xmm15
    	pmovzxbd xmm1, xmm1
    	paddd xmm3, xmm1
		;verde
		movdqa xmm1, xmm0
    	pshufb xmm1, xmm14
    	pmovzxbd xmm1, xmm1
    	paddd xmm3, xmm1
		;azul
		movdqa xmm1, xmm0
		pshufb xmm1, xmm13
		pmovzxbd xmm1, xmm1
		paddd xmm3, xmm1
		;/3
		cvtdq2ps xmm3, xmm3
		divps xmm3, xmm12
		cvttps2dq xmm3, xmm3 ; Convertir a entero

		;calculo f(x)
		;para mi aca quedaba mucho mas "limpio" si haciamos una func auxiliar (lo deje en un commit anterior xq me dijeron que no era la idea pero andaba)
		pxor xmm2,xmm2
		;rojo
		movdqa xmm0, xmm3
		psubd xmm0, xmm7
		pabsd xmm0, xmm0  ; |x - 192|
		pmulld xmm0, xmm6 ; 4 * |x - 192|
		movdqa xmm1, xmm5
		psubd xmm1, xmm0  ; 384 - 4 * |x - 192|
		pxor xmm0, xmm0
		pmaxsd xmm1, xmm0 ; max(0, 384 - 4 * |x - 192|)
		pminsd xmm1, xmm4
		movdqa xmm0, xmm1
		packusdw xmm0, xmm0
		packuswb xmm0, xmm0
		pslldq xmm0, 12
		psrldq xmm0, 12
		por xmm2, xmm0
		pslldq xmm2, 4
		;verde
		movdqa xmm0, xmm3
		paddd xmm0, xmm11 ; Sumar 64
		psubd xmm0, xmm7
		pabsd xmm0, xmm0  ; |x - 192|
		pmulld xmm0, xmm6 ; 4 * |x - 192|
		movdqa xmm1, xmm5
		psubd xmm1, xmm0  ; 384 - 4 * |x - 192|
		pxor xmm0, xmm0
		pmaxsd xmm1, xmm0 ; max(0, 384 - 4 * |x - 192|)
		pminsd xmm1, xmm4
		movdqa xmm0, xmm1
		packusdw xmm0, xmm0
		packuswb xmm0, xmm0
		pslldq xmm0, 12
		psrldq xmm0, 12
		por xmm2, xmm0
		pslldq xmm2, 4
		;azul
		movdqa xmm0, xmm3
		paddd xmm0, xmm10 ; Sumar 128
		psubd xmm0, xmm7
		pabsd xmm0, xmm0  ; |x - 192|
		pmulld xmm0, xmm6 ; 4 * |x - 192|
		movdqa xmm1, xmm5
		psubd xmm1, xmm0  ; 384 - 4 * |x - 192|
		pxor xmm0, xmm0
		pmaxsd xmm1, xmm0 ; max(0, 384 - 4 * |x - 192|)
		pminsd xmm1, xmm4
		movdqa xmm0, xmm1
		packusdw xmm0, xmm0
		packuswb xmm0, xmm0
		pslldq xmm0, 12
		psrldq xmm0, 12
		por xmm2, xmm0
		pslldq xmm2, 4

		por xmm2, xmm8     ; Añadir canal alfa (255)
		pshufb xmm2, xmm9 ; Reordenar los bytes
		movdqu [rdi], xmm2 

		add r13d, 4 ; Incremento columnas
		add rsi, TAMANO_PIXEL * 4 ; Avanzar al siguiente pixel de la imagen origen
		add rdi, TAMANO_PIXEL * 4 ; Avanzar al siguiente pixel de la imagen destino
		jmp .columnas ; Volver al inicio del bucle de columnas
	
	.fin_columnas:
		inc r12d ; Incremento filas
		jmp .filas
	
	.fin_filas:
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret	