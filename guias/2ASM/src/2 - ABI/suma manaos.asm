; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
; parametros: 
; x1 --> RDI
; x2 --> RSI
; x3 --> RDX
; x4 --> RCX
; x5 --> R8D
; x6 --> R9D
; x7 --> [RBP+16] es mas porqur voy a direcciones mas altas y no es mas 8 xq en 8 esta el instruccion pointer
; x8 --> [RBP+24]
; func llamadora solo puede pasarme 6 registros porque es tipo "entrada" maxima entonces lo que hace es apilar
; los otros valores para que yo desapile cuando considere necesario y estos estan "arriba" una direccion mas 
; alta que el instruction pointer.
;idea esta bien porque en vez de asignarle variable le das un lugar fisico, en este ej no necesario
  ;pero siempre remember multiplo de 8 porque tiene que estar alineado
  ;sub RSP, 40 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada
  ;mov [RSP - 8] RCX ; x4
  ;mov [RSP - 16] R8 ; x5
  ;mov [RSP - 24] R9
  ;mov [RSP - 32] , QWORD PTR [RBP + 16] ; x7  esto es medio ilegal memoria a memoria 
  ;mov [RSP - 40] , QWORD PTR [RBP + 24] ; x8

 alternate_sum_8_manaos:
;en cuanto a memoria rockea pero le pifeo a algo de numeros que no veo que
;osea falla en el assert pero segun tengo entendido signos y llamado a op esta ok 
;debo estar pifeando en un registro y cambum
  ;prologo
  push rbp
  mov rbp, rsp
  sub rsp,48 ;me hago espacio en stack nenita

  mov [rbp-8], rdx      ; Guardar x3
  mov [rbp-16], rcx     ; Guardar x4
  mov [rbp-24], r8      ; Guardar x5
  mov [rbp-32], r9      ; Guardar x6
  mov r12, [rbp+16]     ; Cargar x7
  mov [rbp-40], r12     ; Guardar x7
  mov r13, [rbp+24]     ; Cargar x8
  mov [rbp-48], r13     ; Guardar x8
  
  ; x1 - x2 (rdi y rsi ya tienen x1 y x2)
  call restar_c
  
  ; + x3
  mov edi, eax
  mov esi, dword [rbp-8]
  call sumar_c
  
  ; - x4
  mov edi, eax
  mov esi, dword [rbp-16]
  call restar_c
  
  ; + x5
  mov edi, eax
  mov esi, dword [rbp-24]
  call sumar_c
  
  ; - x6
  mov edi, eax
  mov esi, dword [rbp-32]
  call restar_c
  
  ; + x7
  mov edi, eax
  mov esi, dword [rbp-40]
  call sumar_c
  
  ; - x8
  mov edi, eax
  mov esi, dword [rbp-48]
  call restar_c
  mov edi, eax
  
  ; Epílogo
  add rsp,48 ; devuelvo"
  mov rsp, rbp
  pop rbp
  ret */
