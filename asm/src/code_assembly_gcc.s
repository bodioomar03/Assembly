.section .data
    format_menu: .string "%d. %s\n"
    format_submenu: .string "%s ON\n"
    format_submenu_off: .string "%s OFF\n"
    format_input: .string "%c"
    format_integer: .string "%d"
    format_pressure_reset: .string "Pressione gomme resettata\n"
    menu_list: .string "Setting automobile:\nData: 15/06/2014\nOra: 15:32\nBlocco automatico porte:\nBack-home:\nCheck olio\nFrecce direzione\nReset pressione gomme\n"


.section .bss
    .comm carattere, 1
    .comm i_menu, 1
    .comm block_door, 1
    .comm back_home, 1
    .comm frecce_direzione, 1

    .comm isRoot, 1
    .comm N_MUNU, 1
    .comm max, 1


.section .text
    .global _start


_start:
    # Controllo se è stato passato un argomento sulla riga di comando
    movl 4(%esp), %eax
    test %eax, %eax
    jz not_root
    
    # Verifico se l'argomento corrisponde a "2244" per indicare che è un utente con privilegi di root
    movl 8(%esp), %esi
    movb (%esi), %al
    cmpb $'2', %al
    jne not_root
    movb 1(%esi), %al
    cmpb $'2', %al
    jne not_root
    movb 2(%esi), %al
    cmpb $'4', %al
    jne not_root
    movb 3(%esi), %al
    cmpb $'4', %al
    jne not_root
    
    # Se l'argomento corrisponde a "2244", imposto isRoot a 1
    movb $1, isRoot
    jmp start_menu
    
not_root:
    # Altrimenti, isRoot rimane a 0
    movb $0, isRoot
    
start_menu:
    # Inizializzo i valori delle variabili
    movb $0, i_menu
    movb $1, block_door
    movb $1, back_home
    movb $3, frecce_direzione
    
menu_loop:
    # Stampo il menu corrente
    movl i_menu, %eax
    incl %eax # Incremento di 1 per visualizzare i numeri partendo da 1
    movl $menu_list, %esi
    leal format_menu, %edi
    call print_string #call print_menu
    
    # Leggo l'input dell'utente
    call read_char
    
    cmpb $27, carattere # Controllo se il carattere letto è la sequenza di escape
    jne handle_input
    
    # Leggo il carattere successivo per determinare il tipo di freccia
    call read_char
    cmpb $'A', carattere
    je handle_up_arrow
    cmpb $'B', carattere
    je handle_down_arrow
    cmpb $'C', carattere
    je handle_right_arrow

    # Loop while
    jmp menu_loop
    
handle_input:
    # L'input dell'utente è un carattere normale
    jmp menu_loop
    
handle_up_arrow:
    # Freccia su, decremento i_menu
    movl i_menu, %eax
    cmpb $0, %al
    jle set_i_menu_max
    dec %eax
    movb %al, i_menu
    jmp menu_loop
    
set_i_menu_max:
    # Se i_menu è <= 0, lo setto al valore massimo consentito
    movl i_menu, %eax
    addl N_MUNU, %eax
    subl max, %eax
    movb %al, i_menu
    jmp menu_loop
    
handle_down_arrow:
    # Freccia giù, incremento i_menu
    movl i_menu, %eax
    inc %eax
    cmpl N_MUNU, %eax
    jge set_i_menu_min
    movb %al, i_menu
    jmp menu_loop
    
set_i_menu_min:
    # Se i_menu è >= N_MENU, lo setto a 0
    xorl %eax, %eax
    movb %al, i_menu
    jmp menu_loop
    
handle_right_arrow:
    # Freccia destra, controllo quale voce del menu è selezionata
    movl i_menu, %eax
    incl %eax # Incremento di 1 per avere valori da 1 a N_MENU
    cmp $4, %eax
    jne check_back_home
    # La voce selezionata è "Blocco automatico porte"
    pushl block_door
    pushl $menu_list + 3*30 # Puntatore alla voce del menu corrispondente
    call sub_menu
    movb %al, block_door # CAMBIARE IN AEX
    jmp menu_loop
    
check_back_home:
    cmp $5, %eax
    jne check_frecce_direzione
    # La voce selezionata è "Back-home"
    pushl back_home
    pushl $menu_list + 4*30 # Puntatore alla voce del menu corrispondente
    call sub_menu
    movb %al, back_home # CAMBIARE IN AEX
    jmp menu_loop
    
check_frecce_direzione:
    cmpb $0, isRoot
    je skip_frecce_direzione # CHANGE: jmp menu_loop
    
    cmp $7, %eax
    jne check_pressure_reset
    # La voce selezionata è "Frecce direzione"
    pushl frecce_direzione
    pushl $menu_list + 6*30 # Puntatore alla voce del menu corrispondente
    call sub_menu
    movb %al, frecce_direzione
    jmp menu_loop
    
check_pressure_reset:
    cmp $8, %eax
    jne menu_loop
    # La voce selezionata è "Reset pressione gomme"
    movl $format_pressure_reset, %esi
    call print_string
    jmp menu_loop
    
skip_frecce_direzione:
    cmp $7, %eax
    je menu_loop
    
    jmp menu_loop
    
# Funzione per la gestione dei sottomenu
sub_menu:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %esi # Puntatore alla stringa del sottomenu
    movb 12(%ebp), %al # Valore iniziale (0 o 1)
    movb %al, (%ebp) # Variabile locale per il valore
    
sub_menu_loop:
    # Stampo il sottomenu corrente con il valore attuale
    pushl %esi
    movzbl (%ebp), %eax
    test %eax, %eax # Verifica se il registro contiene un valore diverso da zero. Serve per controllare se un registro è zero o non zero prima di eseguire ulteriori istruzioni condizionali
    jnz print_submenu_on
    pushl %esi
    movl $format_submenu_off, %esi
    call print_string
    popl %esi
    jmp sub_menu_input
    
print_submenu_on:
    pushl %esi
    movl $format_submenu, %esi
    call print_string
    popl %esi
    
sub_menu_input:
    # Leggo l'input dell'utente
    call read_char
    
    cmpb $27, %al # Controllo se il carattere letto è la sequenza di escape
    jne sub_menu_handle_input
    
    # Leggo il carattere successivo per determinare il tipo di freccia
    call read_char
    cmpb $'A', %al
    je sub_menu_toggle_value
    cmpb $'B', %al
    je sub_menu_toggle_value
    jmp sub_menu_loop
    
sub_menu_handle_input:
    # L'input dell'utente è un carattere normale
    jmp sub_menu_loop
    
sub_menu_toggle_value:
    # Cambio il valore tra 0 e 1
    xorl %eax, %eax
    movzbl (%ebp), %eax
    xorl $1, %eax
    movb %al, (%ebp)
    jmp sub_menu_loop
    
# Funzione per la stampa di una stringa
print_string:
    pusha
    
    movl $-1, %edx # Lunghezza della stringa, -1 per calcolarla automaticamente
    movl %esi, %ecx # Puntatore alla stringa
    movl $1, %ebx # File descriptor 1 (stdout)
    movl $4, %eax # Syscall write
    int $0x80
    
    popa
    ret
    
# Funzione per la lettura di un carattere
read_char:
    pusha
    
    movl $1, %edx # Numero di byte da leggere
    leal carattere, %ecx # Buffer di destinazione
    movl $0, %ebx # File descriptor 0 (stdin)
    movl $3, %eax # Syscall read
    int $0x80
    
    popa
    ret
