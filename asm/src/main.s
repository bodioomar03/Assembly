.data
N_MENU:     .equ 8
MENU_LIST:  .asciz "Setting automobile:\n"
            .asciz "Data: 15/06/2014\n"
            .asciz "Ora: 15:32\n"
            .asciz "Blocco automatico porte:\n"
            .asciz "Back-home:\n"
            .asciz "Check olio\n"
            .asciz "Frecce direzione\n"
            .asciz "Reset pressione gomme\n"
IS_ROOT:    .long 0
I_MENU:     .long 0
MAX:        .long 0
BLOCK_DOOR: .long 1
BACK_HOME:  .long 1
FRECCE_DIR: .long 3
CARATTERE:  .byte 0

.text
.globl _start

_start:
    # Imposta IS_ROOT a 0 inizialmente
    movl $0, IS_ROOT

    # Controllo se è stato passato un argomento alla riga di comando
    cmpl $1, %eax
    jle else
    # Se argc > 1, controlla se l'argomento è "2244"
    movl 8(%ebp), %eax
    movb $'2', %bl
    cmpb %bl, (%eax)
    jne else
    movb $'2', %bl
    cmpb %bl, 1(%eax)
    jne else
    movb $'4', %bl
    cmpb %bl, 2(%eax)
    jne else
    movb $'4', %bl
    cmpb %bl, 3(%eax)
    jne else
    # Se l'argomento è "2244", imposta IS_ROOT a 1
    movl $1, IS_ROOT
    else:

    # Inizializza i registri per il ciclo principale
    movl $0, %eax
    movl %eax, I_MENU
    movl %eax, MAX

    # Controllo se IS_ROOT è vero per impostare MAX
    cmpl $0, IS_ROOT
    jne set_max

    # Imposta MAX a 3 se IS_ROOT è falso
    movl $3, MAX
    jmp menu_loop

    set_max:
    # Imposta MAX a 1 se IS_ROOT è vero
    movl $1, MAX

    menu_loop:
    # Stampa il menu corrente
    movl I_MENU, %eax
    leal MENU_LIST(,%eax,4), %eax
    push %eax
    push $menu_format
    call printf
    add $8, %esp

    # Legge il carattere
    push $1
    leal CARATTERE, %eax
    push %eax
    push $char_format
    call scanf
    add $8, %esp

    # Controlla il carattere letto
    movb CARATTERE, %bl
    cmpb $'\033', %bl
    jne menu_loop

    # Legge il carattere successivo per determinare il tipo di freccia
    call getchar
    movb %al, %bl
    cmpb $'A', %bl
    jne check_down

    # Gestisce la freccia su
    movl I_MENU, %eax
    cmpl $0, %eax
    jle set_max_i_menu
    subl $1, %eax
    jmp set_i_menu

    check_down:
    cmpb $'B', %bl
    jne menu_loop

    # Gestisce la freccia giù
    movl I_MENU, %eax
    cmpl $7, %eax
    jl inc_i_menu
    set_max_i_menu:
    movl N_MENU, %eax
    subl MAX, %eax
    decl %eax
    jmp set_i_menu

    inc_i_menu:
    incl %eax

    set_i_menu:
    movl %eax, I_MENU
    jmp menu_loop

.section .data
menu_format: .asciz "%d. %s\n"
char_format: .asciz " %c"
