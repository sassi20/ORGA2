extern malloc
extern free
extern fprintf

section .data

section .rodata
nullStr: db "NULL", 0 ;lo agrego para poder usar fprint pero ni idea la verdad
formatStr: db "%s", 0


section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	;prologo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	sub rsp,8
	
	mov r12, rdi
	mov r13, rsi

	.for:
		movzx r14,byte[r12]
		movzx r15,byte[r13]
	
		cmp r14,r15
		jne .diffs ;si son diferentes salto a diferente

		cmp r14,0   ;si a = 0 no tengo mas para procesar
		je .iguales ;si son iguales pero cero termine cadena
		
		inc r12
		inc r13
		jmp .for 

	.iguales:
		xor eax,eax
		jmp .epilogo
	
	.diffs:
		cmp r14,r15
		jl .peque
		mov eax,-1
		jmp .epilogo
	
	.peque:
		mov eax,1

	.epilogo:
		add rsp,8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
	ret

; char* strClone(char* a)
strClone:
 ; Prólogo
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    ; no muevo rsp porque ya esta bien posicionado porque son 4 -> 32
    
    mov rbx, rdi    ;lo teng que mover porque despues voy a tener que usar rdi para strlen
    call strLen     ; que esto me devuelve long en rax
    inc rax ;le sumo uno para el '/0'

    mov rdi, rax
    call malloc
    mov r12, rax  ;puntero al rax
    mov r13, r12  ;puntero que yo voy a ir usando para avanzar 
    
    .copiar:
        mov r14b, byte[rbx]
        mov [r13], r14b
        cmp r14b, 0
        je .termino
        inc rbx
        inc r13
        jmp .copiar
    
    .termino:
        mov rax, r12 ; no entiendo porque pero sino explota
        
        pop r14
        pop r13
        pop r12
        pop rbx 
        pop rbp
        ret

; void strDelete(char* a)
strDelete:
	extern free
global strDelete
section .text

strDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret


; void strPrint(char* a, FILE* pFile)
strPrint:
push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13 ;hice 3 pushes (24 bytes) + push rbp (8 bytes) = 32 bytes

    sub rsp, 8 ; para llamada alineada a fprintf

    mov rbx, rdi   ;p a string
    mov r12, rsi   ;pFile

    mov r13b, byte [rbx]
    cmp r13b, 0 ;si es cero salto a escribir null con cositas raras
    jne .escribir


    mov rdi, r12             ; pFile → rdi
    lea rsi, [rel formatStr] ; "%s" → rsi
    lea rdx, [rel nullStr]   ; "NULL" → rdx
    call fprintf
    jmp .epilogo

.escribir:
    mov rdi, r12           ; pFile → rdi
    lea rsi, [rel formatStr] ; "%s" → rsi
    mov rdx, rbx           ; string a imprimir → rdx
    call fprintf

.epilogo:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; uint32_t strLen(char* a)
strLen:
	strLen:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
	sub rsp,8     

    mov rbx, rdi    ;puntero
    xor eax, eax    ;contador = 0

.loop:
    mov r12b, byte [rbx]
    cmp r12b, 0
    je .fin    ;si es '\0' chau

    inc eax
    inc rbx
    jmp .loop

.fin:
	add rsp, 8
    pop r12
    pop rbx
    pop rbp
    ret


