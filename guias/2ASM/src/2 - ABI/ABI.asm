extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI ; hago x1 - x2 guardo en x1 no en x1 pero en lugar donde se encontraba
  add EDI, EDX ; agarro res de la cuenta y le sumo lo que esta en edx
  sub EDI, ECX ; agarro result suma y le resto uno mas
  mov EAX, EDI ; muevo de registro cualquiera mi reta a eax que es el de "salida"
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret

; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
  alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, DWORD [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret

alternate_sum_8:
  ;se rompe para negativos nose bien si es la idea o no pero mirar
	;prologo
    push rbp
    mov rbp, rsp

    ; Cargar x7 y x8 como uint32_t desde la pila
    mov r12d, dword [rbp + 16]   ; x7
    mov r13d, dword [rbp + 24]   ; x8

    ; Operaciones
    sub edi, esi
    add edi, edx
    sub edi, ecx
    add edi, r8d
    sub edi, r9d
    add edi, r12d
    sub edi, r13d

    mov eax, edi

    ; Epílogo
    pop rbp
    ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
;destination -> EAX (maybe deberia ser RAX? pero en definitiva yo no estoy devolviendo yo estoy almacenando)
;x1 -> esi -> xmm1
;f1 -> xmm0
product_2_f:
push rbp
    mov rbp, rsp

    ; Convertimos x1 a double (donde xmm1 = x1 como double)
    cvtsi2sd xmm1, esi

    ; Convertimos f1 a double (donde xmm0 = f1 como double)
    cvtss2sd xmm0, xmm0

    ; Multiplicamos xmm1 * xmm0, el resultado está en xmm1
    mulsd xmm1, xmm0

    ; Convertimos el resultado a entero (signed) de 64 bits en rax
    cvttsd2si rax, xmm1

    ; Guardamos el valor de eax (32 bits bajos de rax) en la dirección destino
    mov [rdi], eax

    pop rbp
    ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[?], f1[?], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
; parametros: 
; destination* -> RDI (primer parámetro de la función)
; x1 --> ESI (primer entero)
; f1 -> XMM0 (primer flotante)
; x2 --> EDX (segundo entero)
; f2 -> XMM1 (segundo flotante)
; x3 --> ECX (tercer entero)
; f3 -> XMM2 (tercer flotante)
; x4 --> R8d (cuarto entero)
; f4 -> XMM3 (cuarto flotante)
; x5 --> R9d (quinto entero)
; f5 -> XMM4 (quinto flotante)
; [RBP+16] = x6 (sexto entero, en la pila)
; f6 -> XMM5 (sexto flotante)
; [RBP+24] = x7 (séptimo entero, en la pila)
; f7 -> XMM6 (séptimo flotante)
; [RBP+32] = x8 (octavo entero, en la pila)
; f8 -> XMM7 (octavo flotante)
; [RBP+40] = x9 (noveno entero, en la pila)
; [RBP+48] = f9 (noveno flotante, en la pila)

product_9_f:
  ;prologo
  push rbp
  mov rbp, rsp
  ; no reservo ma espaxio porque no voy a usar 
  cvtss2sd xmm0, xmm0
  
  cvtss2sd xmm1, xmm1
  mulsd xmm0, xmm1       ; xmm0 = f1 * f2
    
  cvtss2sd xmm2, xmm2
  mulsd xmm0, xmm2       ; xmm0 = f1 * f2 * f3
    
  cvtss2sd xmm3, xmm3
  mulsd xmm0, xmm3       ; xmm0 = f1 * f2 * f3 * f4
  
  cvtss2sd xmm4, xmm4      ; f5
  mulsd xmm0, xmm4
  
  cvtss2sd xmm5, xmm5      ; f6
  mulsd xmm0, xmm5

  cvtss2sd xmm6, xmm6      ; f7
  mulsd xmm0, xmm6

  cvtss2sd xmm7, xmm7      ; f8
  mulsd xmm0, xmm7

  movss xmm1, [rbp+48]     ; f9
  cvtss2sd xmm1, xmm1
  mulsd xmm0, xmm1


  ;empiezo con los enteros que los tengo que hacer doubles
  ;despues de hacerlo doubles lo multiplico por mi xmmo que tiene la multi
  cvtsi2sd xmm1, esi       ; x1
  mulsd xmm0, xmm1

  cvtsi2sd xmm1, edx       ; x2
  mulsd xmm0, xmm1

  cvtsi2sd xmm1, ecx       ; x3
  mulsd xmm0, xmm1

  cvtsi2sd xmm1, r8d       ; x4
  mulsd xmm0, xmm1

  cvtsi2sd xmm1, r9d       ; x5
  mulsd xmm0, xmm1

  mov eax, [rbp+16]        ; x6
  cvtsi2sd xmm1, eax
  mulsd xmm0, xmm1

  mov eax, [rbp+24]        ; x7
  cvtsi2sd xmm1, eax
  mulsd xmm0, xmm1

  mov eax, [rbp+32]        ; x8
  cvtsi2sd xmm1, eax
  mulsd xmm0, xmm1

  mov eax, [rbp+40]        ; x9
  cvtsi2sd xmm1, eax
  mulsd xmm0, xmm1

  ; Guardar resultado
  movsd [rdi], xmm0

  ; epilogo
  pop rbp
  ret