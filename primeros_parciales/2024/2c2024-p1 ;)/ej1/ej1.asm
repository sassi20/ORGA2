extern malloc
extern calloc


section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
ITEM_SIZE EQU 28
ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_FUERZA EQU 20
ITEM_OFFSET_DURABILIDAD EQU 24


section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE; Cambiar por `TRUE` para correr los tests.

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado: ;item_t** inventario = [rdi], uint16_t* indice = rsi, uint16_t tamanio = dx, comparador_t comparador = rcx
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
	push r15
	sub rsp, 8 ; pila alineada porque son pares

    ; Copiamos los parámetros a registros que nos gustan
    mov rbx, rdi         ; rbx = inventario
    mov r12, rsi         ; r12 = indice
    movzx r13, dx        ; r13 = tamaño (limpiamos la parte alta)
	mov r15, rcx

    ; Si tamaño <= 1, devolver true (1)
    cmp r13, 1
    jbe .ordenado

    xor r14d, r14d       ; r14 = i = 0

.bucle:
    ; Cargar indice[i] y indice[i+1]
    movzx r8, word [r12 + r14*2]        ; r8 = indice[i]
    movzx r9, word [r12 + r14*2 + 2]    ; r9 = indice[i+1]

    ; Obtener inventario[indice[i]] → item1
    mov r8, [rbx + r8*8]                ; r8 = item1 (puntero)

    ; Obtener inventario[indice[i+1]] → item2
    mov r9, [rbx + r9*8]                ; r9 = item2 (puntero)

    ; Llamar a comparador(item1, item2)
    mov rdi, r8     ; primer argumento: item1
    mov rsi, r9     ; segundo argumento: item2
    call r15        ; llamar a la función comparador

    ; El resultado queda en AL. Si es 0 → desordenado
    test al, al
    je .desordenado

    ; i++
    inc r14
    ; si i < tamanio - 1 → seguir
    mov r8, r13
    dec r8
    cmp r14, r8
    jb .bucle

.ordenado:
    ; Devolver true
    mov eax, 1
    jmp .fin

.desordenado:
    xor eax, eax        ; false (0)

.fin:
	add rsp,8
	pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;------------------------------------------------------------------------------------------------------------------------------------------------------

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**


global indice_a_inventario

indice_a_inventario:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    ; Guardar argumentos en registros no volátiles
    mov rbx, rdi          ; rbx = inventario
    mov r12, rsi          ; r12 = indice
    movzx r13, dx         ; r13 = tamanio

    ; Calcular cantidad de bytes a reservar: tamanio * 8
    mov rdi, r13
    shl rdi, 3            ; rdi = tamanio * 8
    call malloc

    mov r14, rax          ; r14 = puntero a resultado
    xor r8d, r8d          ; r8 = i = 0

.bucle:
    cmp r8, r13
    jge .fin

    ; idx = indice[i]
    movzx r9, word [r12 + r8*2]     ; r9 = índice

    ; item = inventario[idx]
    mov r10, [rbx + r9*8]           ; r10 = item

    ; resultado[i] = item
    mov [r14 + r8*8], r10

    inc r8
    jmp .bucle

.fin:
	mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret