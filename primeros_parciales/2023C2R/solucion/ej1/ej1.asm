; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

%define LFIRST 0
%define LLAST 8
%define LSIZE 16

%define NODONEXT 0
%define NODOPREV 8
%define NODOTYPE 16
%define NODOHASH 24
%define NODOSIZE 32


section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat

;--------------------------------------------------------------------------------------------
string_proc_list_create_asm:
    push rbp
    mov rbp,rsp

    mov rdi,LSIZE
    call malloc

    mov qword[rax+LFIRST],0
    mov qword[rax+LLAST],0

    pop rbp 
    ret

;--------------------------------------------------------------------------------------------
string_proc_node_create_asm:
    push rbp
    mov rbp,rsp
    push r12
    push r13

    xor r12,r12
    mov r12b,dil
    mov r13,rsi

    mov rdi,NODOSIZE 
    call malloc 

    mov qword[rax+NODONEXT],0
    mov qword[rax+NODOPREV],0
    mov byte[rax+NODOTYPE],r12b
    mov qword[rax+NODOHASH],r13

    pop r13
    pop r12
    pop rbp
    ret
;--------------------------------------------------------------------------------------------
string_proc_list_add_node_asm:
    push rbp
    mov rbp,rsp
    push r12
    push r13
    sub rsp, 8

    mov r12,rdi 

    xor rdi,rdi 
    mov dil,sil 
    mov rsi,rdx
    call string_proc_node_create_asm ;me queda en rax mi nodo

    mov r13,[r12+LLAST] ;con r13 miro la lista q me pasaronn
    cmp r13,0
    je .listavacia

    mov [r12+LLAST],rax        ;lo agrego como ultimo a lista
    mov [rax+NODOPREV],r13     ;actualizo que nuestro nodo si tiene uno previo
    mov [r13+NODONEXT],rax     ;actualizo a viejo ultimo que ahora tiene uno que va despues 
    jmp .fin

    .listavacia:
        mov [r12+LLAST], rax
        mov [r12+LFIRST],rax

    .fin:
        add rsp,8
        pop r13
        pop r12
        pop rbp
        ret


;--------------------------------------------------------------------------------------------
string_proc_list_concat_asm:
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14

    mov r12,[rdi+LFIRST]
    xor r13,r13
    mov r13b,sil 
    mov r14,rdx

    .loop2:
        cmp r12,0
        je .fin2

        xor rsi,rsi 
        mov sil,[r12+NODOTYPE]
        cmp sil,r13b
        jne .siguiente2

        mov rsi,[r12+NODOHASH]
        mov rdi,r14
        call str_concat 
        mov r14,rax

    .siguiente2:
        mov r12,[r12+NODONEXT]
        jmp .loop2

    .fin2:
        pop r14
        pop r13
        pop r12
        pop rbp
        ret

