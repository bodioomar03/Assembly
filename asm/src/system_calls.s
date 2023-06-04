print_string:
    pusha
    
    xorl %ecx, %ecx  # Lunghezza stringa
    movb $0, %dl     # Terminatore nullo

    strlen_loop:
        cmpb %dl, (%esi,%ecx,1)  # Compara esi+ecx con il terminatore nullo
        je strlen_done           # Se sono uguali, si è arrivati alla fine della stringa
        incl %ecx                
        jmp strlen_loop
    
    strlen_done:
        movl %ecx, %edx

    movl %esi, %ecx         # Puntatore alla stringa
    movl $1, %ebx           # File descriptor 1 (stdout)
    movl $4, %eax           # Syscall write
    int $0x80
    
    popa
    ret



print_int:
    pushl %ebp              # Salva il puntatore alla vecchia base dell'attuale frame
    movl %esp, %ebp         # Imposta il puntatore alla base dell'attuale frame
    movl 8(%ebp), %eax      # Ottiene il parametro passato alla funzione

    addl $48, (%eax)        # Aggiunge 48 per ottenere il valore ASCII del numero
    
    movl $1, %ebx           # File descriptor 1: STDOUT
    movl %eax, %ecx         # Puntatore al numero intero
    movl $1, %edx           # Lunghezza in byte (un singolo byte)
    movl $4, %eax           # Numero di byte da scrivere
    int $0x80               # Chiamata di sistema per scrivere su STDOUT

    popl %ebp               # Ripristina il puntatore alla vecchia base dell'attuale frame
    ret                     # Ritorna dalla funzione





# Funzione per la lettura di un carattere
read_char:
    pusha
    
    movl $1, %edx               # Numero di byte da leggere
    leal carattere, %ecx        # Buffer di destinazione
    movl $0, %ebx               # File descriptor 0 (stdin)
    movl $3, %eax               # Syscall read
    int $0x80
    
    popa
    ret


read_int:
    pusha

    subl $4, %esp               # Alloca 4 byte nello stack per l'input dell'intero
    movl %esp, %ecx             # Puntatore al buffer dell'input
    movl $3, %edx               # Numero di byte da leggere
    movl $0, %ebx               # File descriptor 0 (stdin)
    movl $3, %eax               # Syscall read
    int $0x80

    movl (%ecx), %eax           # Carica l'intero letto in %eax
    subl $48, %eax              # Converto ASCII to INT
    movl %eax, frecce_direzione # Memorizza l'intero in frecce_direzione

    addl $4, %esp               # Dealloca lo spazio nello stack
    popa
    ret