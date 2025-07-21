
global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete

extern strLen
extern malloc
extern calloc
extern strClone
extern free


;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; str_array_t* strArrayNew(uint8_t capacity)
strArrayNew:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov r12, rdi  ;Copio capacity, porque malloc usa rdi para el tamaño
    mov rdi, 16   ;struct = size + capacity + puntero al array
    call malloc    
    mov rbx, rax ;Guardamos el puntero al struct en rbx

    ; Inicialización de la estructura
    mov byte[rbx], 0      ; size = 0 inicialmente
    mov byte[rbx + 1], r12b ; capacity en lugar correcto sruct

    mov r13b, r12b          ; copiar capacity (en byte) antes del imul
    imul r12, r13, 8       ; r12 = capacity * 8
    mov rdi, r13           ; nmemb = cantidad de elementos
    mov rsi, 8             ; cada puntero ocupa 8 bytes
    call calloc  ;mismo que malloc pero me lo inicializa en 0 para despues cuando escribo esten ini
    mov [rbx + 8], rax     
    mov rax, rbx

    pop r12
    pop rbx
    pop rbp
    ret


; uint8_t  strArrayGetSize(str_array_t* a)
strArrayGetSize:
    push rbp
    mov rbp, rsp
    movzx rax, byte [rdi]
    pop rbp
    ret



; void  strArrayAddLast(str_array_t* a, char* data)
strArrayAddLast:
    push rbp
    mov rbp,rsp
    push rbx
    push r12
    push r13
    push r14

    mov r12, rdi ;puntero a struc
    mov r13, rsi ;puntero que quiero copiar 
    movzx r14, byte[r12] ;size
    movzx rbx, byte[r12 + 1] ;capacity
    
    cmp r14, rbx ;me fijo que size <= capacity
    jae .fin ;tengo que fuijarme que sea menos

    ;si tengo capacidad no necesiyo hacerme lugar pero si buscarmelo
    ;estar esta el tema es en donde
    mov rbx, [r12 + 8]  ;rbx = a->data
    xor r14, r14        ;limpio para usar como indice en data

.buscar:
    cmp byte [rbx + r14*8], 0 ;capacidad+puntero*8
    je .encontrado ;si encontre mi lugar vacio salto a copiar
    inc r14
    jmp .buscar

.encontrado:
    ; Clonar el string con strClone
    mov rdi, r13   ; argumento para strClone
    call strClone  ; rax = nuevo puntero clonado

    ; Guardar el puntero clonado en la posición encontrada
    mov [rbx + r14*8], rax

    ; Incrementar size
    inc byte [r12] ;updeteo el size para que quede representativo
    
.fin: 
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; a -> rdi
; i -> rsi
; j -> rdx
strArraySwap:
    ;prologo
    push rbp
    mov rbp, rsp
    push rbx
    push r15
    
    ;cargo el tamano
    xor r8, r8
    mov r8b, byte [rdi]

    ;me fijo si alguno esta fuera de rango
    cmp rsi, r8
    jg .fin
    cmp rdx, r8
    jg .fin

    mov r9, [rdi + 8] ;cargo array 

    mov r10, rsi ;cargo indice para iterar

    .loopPrimerElem: ;busco el primer puntero
        cmp r10, 0
        je .salirPrimerLoop
        dec r10
        add r9, 8
        jmp .loopPrimerElem
    .salirPrimerLoop:
        mov rbx, [r9] ;me guardo palabra en rbx, recordemos que en r9 es la posicion a guardar la 2da palabra
        mov r10, rdx ;iterador
        mov r15, [rdi + 8] ;cargo array para recorrer de nuevo y saber donde guardar 1era palabra
    .loopSegundoElem:
        cmp r10, 0
        je .swappear
        dec r10
        add r15, 8
        jmp .loopSegundoElem
    .swappear:
        mov r8, [r15] ;me guardo la palabra que esta en el indice de r15
        mov [r9], r8 ;en el indice de r9 pongo la palabra guardada en el indice r15
        mov [r15], rbx ;en el indice r15 pongo la palabra antes guardada en r9

    .fin:
    pop r15
    pop rbx
    pop rbp
    ret


; void  strArrayDelete(str_array_t* a)
strArrayDelete:
    push rbx
    mov rbx,rsp
    push r12
    push r13
    push r14
    push rbx
    push r15

    mov r12,rdi ;punt a struct/size
    mov r13,[r12+1] ;punt a capacity
    mov r14,[r12+8] ;punt a strings

    ;tengo que liberar los asignados a cada punt
    ;se qie tengo tantos elems como me diga size
    ;uso val para ver hasta cuando libero cn *8
    movzx rbx,byte[r12] ;val size
    xor r15, r15 ;limpio al pedo pero porlas

    .loop:
        cmp r15,rbx
        jae .listo

        mov rdi,[r14+r15*8]
        call free

        inc r15
        jmp .loop

    .listo:
        ; misterio de la ciencia porque no libero r13
        mov rdi,r14 ;libero capacity
        call free
        mov rdi, r12 ;libero size
        call free


    pop r15
    pop rbx
    pop r14
    pop r13
    pop r12
    pop rbx
    ret



