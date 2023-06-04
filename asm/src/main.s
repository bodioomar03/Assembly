.section .data
    msg0:
        .asciz "1. Setting automobile:\n"
    msg0Super:
        .asciz "1. Setting automobile: (SuperVisor)\n"
    msg1:
        .asciz "2. Data: 15/06/2014\n"
    msg2:
        .asciz "3. Ora: 15:32\n"
    msg3:
        .asciz "4. Blocco automatico porte:\n"
    msg4:
        .asciz "5. Back-home:\n"
    msg5:
        .asciz "6. Check olio\n"
    msg6:
        .asciz "7. Frecce direzione\n"
    msg7:
        .asciz "8. Reset pressione gomme\n"

    format_pressure_reset: .string "Pressione gomme resettata\n"
    n_lampeggi: .string "Numero Lampeggi: "
    new_line: .string "\n"

    msg3ON:
        .asciz "Blocco automatico porte: ON\n"
    msg3OFF:
        .asciz "Blocco automatico porte: OFF\n"

    msg4ON:
        .asciz "Back-home: ON\n"
    msg4OFF:
        .asciz "Back-home: OFF\n"


.section .bss
    .comm carattere, 1

    .comm i_menu, 4
    .comm block_door, 4
    .comm back_home, 4
    .comm frecce_direzione, 4

    .comm isRoot, 4
    .comm N_MUNU, 4
    .comm max, 4



.section .text
.globl _start



.extern print_string
.extern print_int
.extern read_char
.extern read_int




_start:
    # Controllo se è stato passato un argomento sulla riga di comando
    movl (%esp), %eax
    cmpl $2, %eax
    jl not_root    # Facccio la jump if argc < 2
    
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
    movl $1, isRoot

    jmp start_menu



not_root:
    # Altrimenti, isRoot rimane a 0
    movl $0, isRoot
    

start_menu:
    # Inizializzo i valori delle variabili
    movl $0, i_menu
    movl $1, block_door
    movl $1, back_home
    movl $3, frecce_direzione

    movl $8, N_MUNU


    # Serve per cambiare la dimensine di N_MENU in base a isRoot
    movl isRoot, %eax
    cmpl $0, %eax
    je set_max_one
    movl $1, max

    jmp set_new_nmenu
    

set_max_one:
    movl $3, max
    jmp set_new_nmenu
    

set_new_nmenu:
    movl N_MUNU, %eax  # Carica il valore di N_MUNU nel registro %eax
    subl max, %eax      # Sottrai il valore di max da %eax
    movl %eax, N_MUNU  # Salva il risultato in N_MUNU

    jmp print_menu



# Stampo il menu corrente
print_menu:
    movl i_menu, %eax

    # Seleziona l'elemento in base all'indice
    cmpl $0, %eax
    je set_msg0
    cmpl $1, %eax
    je set_msg1
    cmpl $2, %eax
    je set_msg2
    cmpl $3, %eax
    je set_msg3
    cmpl $4, %eax
    je set_msg4
    cmpl $5, %eax
    je set_msg5
    cmpl $6, %eax
    je set_msg6
    cmpl $7, %eax
    je set_msg7

    jmp print_menu


menu_loop:
    # Leggo l'input dell'utente
    call read_char
    
    
    cmpb $27, carattere # Controllo se il carattere letto è la sequenza di escape
    jne menu_loop


    # Leggi il secondo carattere per rimuovere '['
    call read_char

    
    # Leggo il carattere successivo per determinare il tipo di freccia
    call read_char
    cmpb $'A', carattere
    je handle_up_arrow
    cmpb $'B', carattere
    je handle_down_arrow
    cmpb $'C', carattere
    je handle_right_arrow


    # Loop while
    jmp print_menu



handle_up_arrow:
    # Freccia su, decremento i_menu
    movl i_menu, %eax
    cmpl $0, %eax
    jle set_i_menu_max
    dec %eax
    movl %eax, i_menu

    jmp print_menu

    
set_i_menu_max:
    # Se i_menu è <= 0, lo setto al valore massimo consentito
    movl N_MUNU, %eax
    movl %eax, i_menu

    jmp print_menu
    

handle_down_arrow:
    # Freccia giù, incremento i_menu
    movl i_menu, %eax
    inc %eax


    cmpl N_MUNU, %eax
    jg set_i_menu_min
    movl %eax, i_menu
    
    jmp print_menu
    
set_i_menu_min:
    # Se i_menu è > N_MENU, lo setto a 0
    xorl %eax, %eax
    movl %eax, i_menu

    jmp print_menu




handle_right_arrow:
    # Freccia destra, controllo quale voce del menu è selezionata
    movl i_menu, %eax

    # NORMAL USER SUB-MENU #
    cmpl $3, %eax
    je print_sub_menu
    
    cmpl $4, %eax
    je print_sub_menu



    # SUPER USER SUB-MENU #
    cmpl $6, %eax
    je set_freccie_direzione

    cmpl $7, %eax
    je set_pressione_gomme


    jmp print_menu



set_pressione_gomme:
    # Stampo al stringa di reset pressione gomme
    movl $format_pressure_reset, %esi
    call print_string
    
    jmp print_menu





set_freccie_direzione:
    # Elimino i caratteri rimanenti nel buffer
    call read_char


    # Stampo la stringa lampeggi
    movl $n_lampeggi, %esi
    call print_string


    # Chiama la funzione print_int
    pushl $frecce_direzione  # Passa il numero intero come parametro
    call print_int

    # Stampo carattere "a capo"
    movl $new_line, %esi
    call print_string



    # Leggo il nuovo valore freccia_direzione
    call read_int

    movl frecce_direzione, %eax  # Carica il valore di frecce_direzione in %eax

    # Confronto il primo byte
    cmpb $2, %al                # Confronta il valore con 2
    jl less_than_2               # Salta a less_than_2 se è minore di 2
    cmpb $5, %al                # Confronta il valore con 5
    jg greater_than_5

    jmp print_menu



less_than_2:
    movl $2, frecce_direzione    # Imposta il valore di frecce_direzione a 2
    jmp print_menu

greater_than_5:
    movl $5, frecce_direzione    # Imposta il valore di frecce_direzione a 5
    jmp print_menu












# Controllo quale voce del menu è selezionata
print_sub_menu:
    movl i_menu, %eax

    # NORMAL USER SUB-MENU #
    cmpl $3, %eax
    je print_block_door
    
    cmpl $4, %eax
    je print_back_home



print_block_door:
    movl block_door, %ebx

    # Seleziona ON/OFF in base al valore
    cmpl $0, %ebx
    je set_msg3OFF
    cmpl $1, %ebx
    je set_msg3ON

    jmp print_sub_menu


print_back_home:
    movl back_home, %ebx

    # Seleziona ON/OFF in base al valore
    cmpl $0, %ebx
    je set_msg4OFF
    cmpl $1, %ebx
    je set_msg4ON

    jmp print_sub_menu



sub_menu_loop:
    # Cancello \n dal buffer
    call read_char


    # Leggo l'input dell'utente
    call read_char
    

    cmpb $10, carattere # Controllo se il carattere letto è \n e torno al menu
    je print_menu
    

    cmpb $27, carattere # Controllo se il carattere letto è la sequenza di escape
    jne sub_menu_loop


    # Leggi il secondo carattere per rimuovere '['
    call read_char

    
    # Leggo il carattere successivo per determinare il tipo di freccia
    call read_char
    cmpb $'A', carattere
    je select_what_invert
    cmpb $'B', carattere
    je select_what_invert

    # Loop while
    jmp print_sub_menu




# In base al indice i_menu inverto il valore da 0 a 1 || 1 a 0
select_what_invert:
    movl i_menu, %eax

    # NORMAL USER SUB-MENU #
    cmpl $3, %eax
    je invert_value_block_door
    
    cmpl $4, %eax
    je invert_value_back_home



invert_value_block_door:
    movl block_door, %ebx
    xorl $1, %ebx   # Esegue l'operazione XOR con 1 per invertire il valore
    movl %ebx, block_door
     
    jmp print_sub_menu


invert_value_back_home:
    movl back_home, %ebx
    xorl $1, %ebx   # Esegue l'operazione XOR con 1 per invertire il valore
    movl %ebx, back_home
     
    jmp print_sub_menu










# Sezione Stampa

set_msg0:
    movl isRoot, %eax
    cmpl $1, %eax
    je set_msg0Super

    movl $msg0, %esi
    call print_string
    
    jmp menu_loop


set_msg0Super:
    movl $msg0Super, %esi
    call print_string
    
    jmp menu_loop


set_msg1:
    movl $msg1, %esi
    call print_string
    
    jmp menu_loop


set_msg2:
    movl $msg2, %esi
    call print_string
    
    jmp menu_loop


set_msg3:
    movl $msg3, %esi
    call print_string
    
    jmp menu_loop


set_msg4:
    movl $msg4, %esi
    call print_string
    
    jmp menu_loop


set_msg5:
    movl $msg5, %esi
    call print_string
    
    jmp menu_loop


set_msg6:
    movl $msg6, %esi
    call print_string
    
    jmp menu_loop


set_msg7:
    movl $msg7, %esi
    call print_string
    
    jmp menu_loop






set_msg3ON:
    movl $msg3ON, %esi
    call print_string
    
    jmp sub_menu_loop


set_msg3OFF:
    movl $msg3OFF, %esi
    call print_string
    
    jmp sub_menu_loop



set_msg4ON:
    movl $msg4ON, %esi
    call print_string
    
    jmp sub_menu_loop


set_msg4OFF:
    movl $msg4OFF, %esi
    call print_string
    
    jmp sub_menu_loop