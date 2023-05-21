section .data
    format_menu: db "%d. %s", 10, 0
    format_submenu: db "%s ON", 10, 0
    format_submenu_off: db "%s OFF", 10, 0
    format_input: db "%c", 0
    format_integer: db "%d", 0
    format_pressure_reset: db "Pressione gomme resettata", 10, 0
    menu_list: db "Setting automobile:", 0
              db "Data: 15/06/2014", 0
              db "Ora: 15:32", 0
              db "Blocco automatico porte:", 0
              db "Back-home:", 0
              db "Check olio", 0
              db "Frecce direzione", 0
              db "Reset pressione gomme", 0

section .bss
    carattere resb 1
    i_menu resb 1
    block_door resb 1
    back_home resb 1
    frecce_direzione resb 1

section .text
    global _start

_start:
    ; Controllo se è stato passato un argomento sulla riga di comando
    mov eax, dword [esp + 4]
    test eax, eax
    jz not_root
    
    ; Verifico se l'argomento corrisponde a "2244" per indicare che è un utente con privilegi di root
    mov esi, dword [esp + 8]
    mov al, byte [esi]
    cmp al, '2'
    jne not_root
    mov al, byte [esi + 1]
    cmp al, '2'
    jne not_root
    mov al, byte [esi + 2]
    cmp al, '4'
    jne not_root
    mov al, byte [esi + 3]
    cmp al, '4'
    jne not_root
    
    ; Se l'argomento corrisponde a "2244", imposto isRoot a 1
    mov byte [isRoot], 1
    jmp start_menu
    
not_root:
    ; Altrimenti, isRoot rimane a 0
    mov byte [isRoot], 0
    
start_menu:
    ; Inizializzo i valori delle variabili
    mov byte [i_menu], 0
    mov byte [block_door], 1
    mov byte [back_home], 1
    mov byte [frecce_direzione], 3
    
menu_loop:
    ; Stampo il menu corrente
    mov eax, dword [i_menu]
    add eax, 1 ; Incremento di 1 per visualizzare i numeri partendo da 1
    mov esi, menu_list
    lea edi, [format_menu]
    call print_string ;call print_menu
    
    ; Leggo l'input dell'utente
    call read_char
    
    cmp byte [carattere], 27 ; Controllo se il carattere letto è la sequenza di escape
    jne handle_input
    
    ; Leggo il carattere successivo per determinare il tipo di freccia
    call read_char
    cmp byte [carattere], 'A'
    je handle_up_arrow
    cmp byte [carattere], 'B'
    je handle_down_arrow
    cmp byte [carattere], 'C'
    je handle_right_arrow

    ; Loop while
    jmp menu_loop
    
handle_input:
    ; L'input dell'utente è un carattere normale
    jmp menu_loop
    
handle_up_arrow:
    ; Freccia su, decremento i_menu
    mov eax, dword [i_menu]
    cmp eax, 0
    jle set_i_menu_max
    sub eax, 1
    mov dword [i_menu], eax
    jmp menu_loop
    
set_i_menu_max:
    ; Se i_menu è <= 0, lo setto al valore massimo consentito
    mov eax, dword [i_menu]
    add eax, dword [N_MUNU]
    sub eax, dword [max]
    mov dword [i_menu], eax
    jmp menu_loop
    
handle_down_arrow:
    ; Freccia giù, incremento i_menu
    mov eax, dword [i_menu]
    add eax, 1
    cmp eax, dword [N_MUNU]
    jge set_i_menu_min
    mov dword [i_menu], eax
    jmp menu_loop
    
set_i_menu_min:
    ; Se i_menu è >= N_MENU, lo setto a 0
    xor eax, eax
    mov dword [i_menu], eax
    jmp menu_loop
    
handle_right_arrow:
    ; Freccia destra, controllo quale voce del menu è selezionata
    mov eax, dword [i_menu]
    add eax, 1 ; Incremento di 1 per avere valori da 1 a N_MENU
    cmp eax, 4
    jne check_back_home
    ; La voce selezionata è "Blocco automatico porte"
    push dword [block_door]
    push menu_list + 3*30 ; Puntatore alla voce del menu corrispondente
    call sub_menu
    mov byte [block_door], al ; CAMBIARE IN AEX
    jmp menu_loop
    
check_back_home:
    cmp eax, 5
    jne check_frecce_direzione
    ; La voce selezionata è "Back-home"
    push dword [back_home]
    push menu_list + 4*30 ; Puntatore alla voce del menu corrispondente
    call sub_menu
    mov byte [back_home], al ; CAMBIARE IN AEX
    jmp menu_loop
    
check_frecce_direzione:
    cmp byte [isRoot], 0
    je skip_frecce_direzione ; CHANGE: jmp menu_loop
    
    cmp eax, 7
    jne check_pressure_reset
    ; La voce selezionata è "Frecce direzione"
    push dword [frecce_direzione]
    push menu_list + 6*30 ; Puntatore alla voce del menu corrispondente
    call sub_menu
    mov byte [frecce_direzione], al
    jmp menu_loop
    
check_pressure_reset:
    cmp eax, 8
    jne menu_loop
    ; La voce selezionata è "Reset pressione gomme"
    mov esi, format_pressure_reset
    call print_string
    jmp menu_loop
    
skip_frecce_direzione:
    cmp eax, 7
    je menu_loop
    
    jmp menu_loop
    
; Funzione per la gestione dei sottomenu
sub_menu:
    push ebp
    mov ebp, esp
    
    mov esi, dword [ebp + 8] ; Puntatore alla stringa del sottomenu
    mov al, byte [ebp + 12] ; Valore iniziale (0 o 1)
    mov byte [al], 0 ; Variabile locale per il valore
    
sub_menu_loop:
    ; Stampo il sottomenu corrente con il valore attuale
    push esi
    movzx eax, byte [al]
    test eax, eax ; Verifica se il registro contiene un valore diverso da zero. Serve per controllare se un registro è zero o non zero prima di eseguire ulteriori istruzioni condizionali
    jnz print_submenu_on
    push esi
    mov esi, format_submenu_off
    call print_string
    pop esi
    jmp sub_menu_input
    
print_submenu_on:
    push esi
    mov esi, format_submenu
    call print_string
    pop esi
    
sub_menu_input:
    ; Leggo l'input dell'utente
    call read_char
    
    cmp byte [carattere], 27 ; Controllo se il carattere letto è la sequenza di escape
    jne sub_menu_handle_input
    
    ; Leggo il carattere successivo per determinare il tipo di freccia
    call read_char
    cmp byte [carattere], 'A'
    je sub_menu_toggle_value
    cmp byte [carattere], 'B'
    je sub_menu_toggle_value
    jmp sub_menu_loop
    
sub_menu_handle_input:
    ; L'input dell'utente è un carattere normale
    jmp sub_menu_loop
    
sub_menu_toggle_value:
    ; Cambio il valore tra 0 e 1
    xor eax, eax
    movzx eax, byte [al]
    xor eax, 1
    mov byte [al], al
    jmp sub_menu_loop
    
; Funzione per la stampa di una stringa
print_string:
    pusha
    
    mov edx, -1 ; Lunghezza della stringa, -1 per calcolarla automaticamente
    mov ecx, esi ; Puntatore alla stringa
    mov ebx, 1 ; File descriptor 1 (stdout)
    mov eax, 4 ; Syscall write
    int 0x80
    
    popa
    ret
    
; Funzione per la lettura di un carattere
read_char:
    pusha
    
    mov edx, 1 ; Numero di byte da leggere
    lea ecx, [carattere] ; Buffer di destinazione
    mov ebx, 0 ; File descriptor 0 (stdin)
    mov eax, 3 ; Syscall read
    int 0x80
    
    popa
    ret