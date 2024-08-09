.section .data
    vetor:      .space 400    # Espaço para vetor (máximo 100 elementos)
    N:          .long 0       # Número de linhas
    M:          .long 0       # Número de colunas
    temp:       .long 0       # Variável temporária para leitura
    menu_msg:   .asciz "\n1 - Preencher matriz NxM\n2 - Buscar elemento na matriz\n3 - Mostrar diagonal principal\n4 - Mostrar lucky number\n5 - Mostrar matriz\n6 - Sair\nEscolha uma opção: "
    input_fmt:  .asciz "%d"
    output_fmt: .asciz "%d "
    newline:    .asciz "\n"
    goodbye:    .asciz "Obrigado por usar o programa. Tamo junto!\n"
    dim_msg:    .asciz "Digite o número de linhas e colunas (N M, max 10x10): "
    elem_msg:   .asciz "Digite o elemento a ser buscado: "
    found_msg:  .asciz "Elemento encontrado na posição (%d, %d)\n"
    not_found:  .asciz "Elemento não encontrado\n"
    lucky_msg:  .asciz "Lucky number encontrado:\n"
    lucky_format: .asciz "%d (%d, %d)\n"
    no_lucky:   .asciz "Nenhum Lucky number encontrado\n"
    show_matrix_msg: .asciz "Matriz atual:\n"

.section .text
.globl _start

_start:
    # Menu principal
menu_loop:
    pushl $menu_msg
    call printf
    addl $4, %esp

    # Ler opção do usuário
    pushl $temp
    pushl $input_fmt
    call scanf
    addl $8, %esp

    # Verificar opção escolhida
    movl temp, %eax
    cmpl $1, %eax
    je preencher_matriz
    cmpl $2, %eax
    je buscar_elemento
    cmpl $3, %eax
    je mostrar_diagonal
    cmpl $4, %eax
    je mostrar_lucky
    cmpl $5, %eax
    je mostrar_matriz
    cmpl $6, %eax
    je sair

    jmp menu_loop

preencher_matriz:
    pushl $dim_msg
    call printf
    addl $4, %esp

    # Ler N e M
    pushl $N
    pushl $input_fmt
    call scanf
    addl $8, %esp

    pushl $M
    pushl $input_fmt
    call scanf
    addl $8, %esp

    movl $0, %esi  # índice do vetor

loop_preencher:
    # Ler elemento
    pushl $temp
    pushl $input_fmt
    call scanf
    addl $8, %esp

    # Armazenar elemento no vetor
    movl temp, %ebx
    movl %ebx, vetor(, %esi, 4)

    incl %esi
    movl N, %eax
    mull M
    cmpl %eax, %esi
    jl loop_preencher

    jmp menu_loop

buscar_elemento:
    pushl $elem_msg
    call printf
    addl $4, %esp

    pushl $temp
    pushl $input_fmt
    call scanf
    addl $8, %esp

    movl temp, %ebx  # Elemento a ser buscado
    movl $0, %esi    # índice do vetor

busca_loop:
    movl vetor(, %esi, 4), %eax
    cmpl %ebx, %eax
    je encontrado

    incl %esi
    movl N, %eax
    mull M
    cmpl %eax, %esi
    jl busca_loop

    pushl $not_found
    call printf
    addl $4, %esp
    jmp menu_loop

encontrado:
    # Calcular linha e coluna
    movl %esi, %eax
    movl $0, %edx
    divl M
    pushl %edx  # coluna
    pushl %eax  # linha
    pushl $found_msg
    call printf
    addl $12, %esp
    jmp menu_loop

mostrar_diagonal:
    movl $0, %esi  # índice do vetor
    movl $0, %edi  # contador de diagonal

diag_loop:
    movl vetor(, %esi, 4), %ebx

    pushl %ebx
    pushl $output_fmt
    call printf
    addl $8, %esp

    # Próximo elemento da diagonal
    addl M, %esi
    incl %esi
    incl %edi
    cmpl N, %edi
    jl diag_loop

    pushl $newline
    call printf
    addl $4, %esp
    jmp menu_loop

mostrar_lucky:
    # Imprimir mensagem inicial
    pushl $lucky_msg
    call printf
    addl $4, %esp

    movl $0, %edx  # flag para indicar se um lucky number foi encontrado
    movl $0, %edi  # índice da linha atual

lucky_loop_linha:
    movl $0, %esi  # índice da coluna atual

lucky_loop_coluna:
    # Calcular o índice do elemento atual no vetor
    movl %edi, %eax
    mull M
    addl %esi, %eax
    movl vetor(, %eax, 4), %ebx  # Elemento atual

    # Verificar se é mínimo da linha
    movl $1, %ecx  # flag: 1 se for mínimo da linha
    pushl %esi
    movl $0, %esi  # resetar índice da coluna para comparação

min_linha_loop:
    movl %edi, %eax
    mull M
    addl %esi, %eax
    movl vetor(, %eax, 4), %eax
    cmpl %ebx, %eax
    jl not_min_linha
    incl %esi
    cmpl M, %esi
    jl min_linha_loop
    jmp end_min_linha_loop

not_min_linha:
    movl $0, %ecx  # Não é mínimo da linha

end_min_linha_loop:
    popl %esi
    cmpl $0, %ecx
    je continue_lucky_number

    # Verificar se é máximo da coluna
    movl $1, %ecx  # flag: 1 se for máximo da coluna
    pushl %edi
    movl $0, %edi  # resetar índice da linha para comparação

max_coluna_loop:
    movl %edi, %eax
    mull M
    addl %esi, %eax
    movl vetor(, %eax, 4), %eax
    cmpl %ebx, %eax
    jg not_max_coluna
    incl %edi
    cmpl N, %edi
    jl max_coluna_loop
    jmp end_max_coluna_loop

not_max_coluna:
    movl $0, %ecx  # Não é máximo da coluna

end_max_coluna_loop:
    popl %edi
    cmpl $0, %ecx
    je continue_lucky_number

    # É um lucky number, imprimir com sua posição
    pushl %esi  # coluna
    pushl %edi  # linha
    pushl %ebx  # número
    pushl $lucky_format
    call printf
    addl $16, %esp
    movl $1, %edx  # Indica que um lucky number foi encontrado

continue_lucky_number:
    incl %esi
    cmpl M, %esi
    jl lucky_loop_coluna

    incl %edi
    cmpl N, %edi
    jl lucky_loop_linha

    # Verificar se algum lucky number foi encontrado
    cmpl $0, %edx
    jne end_lucky

    # Se chegou aqui, não encontrou nenhum lucky number
    pushl $no_lucky
    call printf
    addl $4, %esp

end_lucky:
    jmp menu_loop

mostrar_matriz:
    # Imprimir mensagem inicial
    pushl $show_matrix_msg
    call printf
    addl $4, %esp

    movl $0, %edi  # índice da linha atual

mostrar_matriz_loop_linha:
    movl $0, %esi  # índice da coluna atual

mostrar_matriz_loop_coluna:
    # Calcular o índice do elemento atual no vetor
    movl %edi, %eax
    mull M
    addl %esi, %eax
    movl vetor(, %eax, 4), %ebx  # Elemento atual

    # Imprimir o elemento
    pushl %ebx
    pushl $output_fmt
    call printf
    addl $8, %esp

    incl %esi
    cmpl M, %esi
    jl mostrar_matriz_loop_coluna

    # Nova linha após cada linha da matriz
    pushl $newline
    call printf
    addl $4, %esp

    incl %edi
    cmpl N, %edi
    jl mostrar_matriz_loop_linha

    jmp menu_loop

sair:
    pushl $goodbye
    call printf
    addl $4, %esp

    # Encerrar o programa
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    