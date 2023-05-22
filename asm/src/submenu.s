.subMenu:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    # Consuma i caratteri nel buffer del main
    call getchar

    movl 8(%ebp), %eax  # menu_list
    movl 12(%ebp), %ebx # value

    loop:
    pushl %ebx
    pushl %eax
    pushl $1
    pushl $"%s %s\n"
    call printf
    addl $16, %esp

    pushl $1
    leal -1(%ebp), %eax
    pushl %eax
    pushl $" %c"
    call scanf
    addl $12, %esp

    movb -1(%ebp), %bl
    cmpb $'\n', %bl
    je exit

    cmpb $'\033', %bl
    jne next

    # Leggi il carattere successivo per determinare il tipo di freccia
    pushl $1
    call getchar
    addl $4, %esp

    movb %al, %bl
    cmpb $'A', %bl
    jne check_down

    # Gestisce la freccia su
    movl 12(%ebp), %eax
    cmpl $1, %eax
    je else_sub
    movl $0, %ebx
    jmp exit

    else_sub:
    movl $1, %ebx
    jmp exit

    check_down:
    cmpb $'B', %bl
    jne loop

    # Gestisce la freccia giù
    movl 12(%ebp), %eax
    cmpl $1, %eax
    jne else_sub
    movl $1, %ebx
    jmp exit

    next:
    pushl $1
    call getchar
    addl $4, %esp
    jmp loop

    exit:
    movl %ebx, %eax

    movl %ebp, %esp
    popl %ebp
    ret