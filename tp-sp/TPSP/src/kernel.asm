; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
; ==============================================================================

%include "print.mac"
extern GDT_DESC
extern screen_draw_layout
extern idt_init
extern IDT_DESC
extern pic_reset
extern pic_enable
extern mmu_init_kernel_dir
extern tss_init 
extern tasks_screen_draw
extern sched_init
extern tasks_init
 

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL  0b0000000000001000   
%define DS_RING_0_SEL  0b0000000000011000   




BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    
    ;Acá entiendo que lo que tenemos que deshabilitar son las interrupciones de hardware y/o debugging
    ;las de hardware se apagan seteando 0 en el flag IF, para esto hay una instruccion "cli" (ver manual seccion 7.8.1)
    ;las de debugging seteando el 0 en el flag RF (no encontre como todavia)

    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_pm_len, 0x2, 0, 0

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]
    ;------hay que usar lgdt direccion_gdt pero no se bien como hacer todavia para traer esa direccion de gdt.c (probe poner %include gdt.c pero me tiraba errores) 


    ; COMPLETAR - Setear el bit PE del registro CR0
    mov ecx, CR0
    mov edx, 0x00000001
    or ecx, edx
    mov CR0, ecx

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido


    

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo

    
    mov edx, DS_RING_0_SEL

    mov DS, dx
    mov ES, dx
    mov GS, dx
    mov FS, dx
    mov SS, dx


    ; COMPLETAR - Establecer el tope y la base de la pila
    mov ebp, 0x25000
    mov esp, 0x25000

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO

    print_text_pm start_pm_msg, start_pm_len, 0x2, 0, 0

    ; COMPLETAR - Inicializar pantalla

    call screen_draw_layout

    ;mov dl, 0b000000001
    ;push edx
    
    ;push edx
    
    ;mov edx, 80
    ;push edx

    ;mov edx, 50
    ;push edx

    ;mov edx, 0x000B8000

    ;push edx
    ;push edx
  

   ;call screen_draw_box

    ; Inicializar el directorio de paginas
    call mmu_init_kernel_dir

    ; Cargar directorio de paginas
    mov cr3, eax

    ; Habilitar paginacion
    mov edx, CR0
    or edx, 0x80000000
    mov cr0, edx

    ; Inicializar tss
    call tss_init

    ; Inicializar el scheduler

    call sched_init

    ; Inicializar las tareas
    
    call tasks_init

    ; COMPLETAR - Inicializar y cargar la IDT
    call idt_init
    lidt [IDT_DESC]

    ; COMPLETAR - Reiniciar y habilitar el controlador de interrupciones

    call pic_reset
    call pic_enable
   

    ; Cargar tarea inicial
    call tasks_screen_draw
    mov ax, 0x58
    ltr ax


    ; COMPLETAR - Habilitar interrupciones
    ; NOTA: Pueden chequear que las interrupciones funcionen forzando a que se
    ;       dispare alguna excepción (lo más sencillo es usar la instrucción
    ;       `int3`)
    


    ; Inicializar el directorio de paginas de la tarea de prueba

    ; Cargar directorio de paginas de la tarea

    ; Restaurar directorio de paginas del kernel

    ; Saltar a la primera tarea: Idle

    JMP 0x60:0

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
