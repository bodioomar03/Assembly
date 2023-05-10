section .data
    menu_list db "Setting automobile:", "Data: 15/06/2014", "Ora: 15:32",
              "Blocco automatico porte:", "Back-home:", "Check olio",
              "Frecce direzione", "Reset pressione gomme"
    N_MENU equ 8

section .bss
    i_menu resb 1
    cmd resb 4
    max resb 1
    block_door resb 1
    back_home resb 1
    frecce_direzione resb 1

section .text
    global main
    extern printf, scanf

subMenu:
    ; Prepara i registri e lo stack per la chiamata a printf
    push ebp
    mov ebp, esp
    sub esp, 8

    ; Stampa il menu corrente
    mov edx, [ebp+8]
    movzx eax, byte [ebp+12]
    test eax, eax
    jne .print_on
    push format_menu_off
    jmp .print_menu
.print_on:
    push format_menu_on
.print_menu:
    push edx
    call printf
    add esp, 12

.loop:
    ; Leggi il carattere
    lea eax, [ebp-1]
    push eax
    push format_char
    call scanf
    add esp, 8

    ; Controlla il carattere
    movzx eax, byte [ebp-1]
    cmp eax, '\n'
    je .end_loop
    cmp eax, '\033'
    jne .check_arrow

    ; Leggi il carattere successivo per determinare il tipo di freccia
    push ebp
    push eax
    push format_char
    call scanf
    add esp, 8
    movzx eax, byte [ebp-1]
    cmp eax, 'A'
    jne .not_arrow_a
    jmp .toggle_value
.not_arrow_a:
    cmp eax, 'B'
    jne .not_arrow_b
.toggle_value:
    xor edx, edx
    movzx eax, byte [ebp+12]
    test eax, eax
    jne .set_value_0
    mov edx, 1
.set_value_0:
    mov byte [ebp+12], dl
    jmp .loop
.not_arrow_b:
    jmp .loop

.check_arrow:
    ; Consuma il carattere di newline residuo nel buffer
    push ebp
    push 0
    push format_char
    call scanf
    add esp, 8
    jmp .loop

.end_loop:
    ; Ripristina i registri e lo stack
    mov esp, ebp
    pop ebp

    ; Restituisce il valore
    movzx eax, byte [ebp+12]
    ret

section .data
    format_menu db "%d. %s", 10, 0
    format_menu_on db "%s ON", 10, 0
    format_menu_off db "%s OFF", 10, 0
    format_input db "%3s", 0
    format_char db " %c", 0

section .text
    global main
    extern printf, scanf

main:
    ; Imposta isRoot a 0
    xor eax, eax
    mov isRoot, al

    ; Controlla gli argomenti della riga di comando
    cmp dword [argc], 2
    jle .skip_check
    mov edi, [argv+4]
    movzx eax, byte [edi]
    cmp eax, '2'
    jne .skip_check
    movzx eax, byte [edi+1]
    cmp eax, '2'
    jne .skip_check
    movzx eax, byte [edi+2]
    cmp eax, '4'
    jne .skip_check
    movzx eax, byte [edi+3]
    cmp eax, '4'
    jne .skip_check
    mov isRoot, 1

.skip_check:

    ; Inizializza i_menu a 0
    xor eax, eax
    mov byte [i_menu], al

    ; Inizializza max in base a isRoot
    cmp isRoot, 0
    jne .is_root
    mov byte [max], 1
    jmp .end_max
.is_root:
    mov byte [max], 3
.end_max:

.loop:
    ; Stampa il numero e l'elemento del menu corrente
    movzx eax, byte [i_menu]
    add eax, 1
    push eax
    mov edi, eax
    mov esi, menu_list
    lea eax, [esi + edi*4 - 4]
    push eax
    push format_menu
    call printf
    add esp, 12

    ; Leggi l'input dell'utente
    lea eax, [cmd]
    push eax
    push format_input
    call scanf
    add esp, 8

    ; Controlla l'input
    movzx eax, byte [cmd+2]
    cmp eax, 'B'
    je .increment_menu
    cmp eax, 'A'
    je .decrement_menu
    cmp eax, 'C'
    jne .loop

    ; Sub-menu
    movzx eax, byte [i_menu]
    add eax, 1
    cmp eax, 4
    je .sub_menu_4
    cmp eax, 5
    jne .loop

.sub_menu_5:
    push byte [back_home]
    push menu_list+20
    call subMenu
    add esp, 8
    jmp .loop

.sub_menu_4:
    push byte [block_door]
    push menu_list+13
    call subMenu
    add esp, 8
    jmp .loop

.increment_menu:
    movzx eax, byte [i_menu]
    cmp eax, byte [N_MENU-max-1]
    jl .increment
    xor eax, eax
    jmp .end_increment
.increment:
    add eax, 1
    mov byte [i_menu], al
.end_increment:
    jmp .loop

.decrement_menu:
    movzx eax, byte [i_menu]
    cmp eax, 0
    jg .decrement
    mov eax, byte [N_MENU-max-1]
    mov byte [i_menu], al
    jmp .end_decrement
.decrement:
    sub eax, 1
    mov byte [i_menu], al
.end_decrement:
    jmp .loop


.end_loop:

    ; Ripristina i registri e lo stack
    mov esp, ebp
    pop ebp

    ; Restituisce il valore
    movzx eax, byte [ebp+12]
    ret