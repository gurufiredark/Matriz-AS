.section .data
    vetor:      .space 400    # Espaço para vetor (máximo 100 elementos)
    lucky_vetor: .space 400   # Vetor para armazenar lucky numbers
    lucky_count: .long 0      # Contador de lucky numbers encontrados
    N:          .long 0       # Número de linhas
    M:          .long 0       # Número de colunas
    temp:       .long 0       # Variável temporária para leitura
    menu_msg:   .asciz "\n1 - Preencher matriz NxM\n2 - Buscar elemento na matriz\n3 - Mostrar diagonal principal\n4 - Mostrar lucky numbers\n5 - Mostrar matriz\n6 - Sair\nEscolha uma opção: "
    input_fmt:  .asciz "%d"
    output_fmt: .asciz "%d "
    newline:    .asciz "\n"
    goodbye:    .asciz "Obrigado por usar o programa. Tamo junto!\n"
    dim_msg:    .asciz "Digite o número de linhas e colunas (N M, max 10x10): "
    elem_msg:   .asciz "Digite o elemento a ser buscado: "
    found_msg:  .asciz "Elemento encontrado na posição (%d, %d)\n"
    not_found:  .asciz "Elemento não encontrado\n"
    lucky_msg:  .asciz "Lucky numbers encontrados:\n"
    lucky_format: .asciz "%d (%d, %d)\n"
    no_lucky:   .asciz "Nenhum Lucky number encontrado\n"
    show_matrix_msg: .asciz "Matriz atual:\n"
    pos_msg:    .asciz "Digite o elemento para a posição (%d, %d): "
    search_result_msg: .asciz "Resultados da busca:\n"
    search_count: .long 0     # Contador para o número de ocorrências encontradas

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

    movl $0, %edi  # contador de linha

loop_preencher_linha:
    movl $0, %esi  # contador de coluna

loop_preencher_coluna:
    # Mostrar a posição atual
    pushl %esi
    pushl %edi
    pushl $pos_msg
    call printf
    addl $12, %esp

    # Ler elemento
    pushl $temp
    pushl $input_fmt
    call scanf
    addl $8, %esp

    # Calcular o índice no vetor
    movl %edi, %eax
    mull M
    addl %esi, %eax

    # Armazenar elemento no vetor
    movl temp, %ebx
    movl %ebx, vetor(, %eax, 4)

    incl %esi
    cmpl M, %esi
    jl loop_preencher_coluna

    incl %edi
    cmpl N, %edi
    jl loop_preencher_linha

    # Calcular lucky numbers após preencher a matriz
    call calcular_lucky

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
    movl $0, search_count  # Resetar o contador de ocorrências

    # Imprime mensagem de resultados da busca
    pushl $search_result_msg
    call printf
    addl $4, %esp

busca_loop:
    movl vetor(, %esi, 4), %eax
    cmpl %ebx, %eax
    jne not_found_here

    # Elemento encontrado, calcula linha e coluna
    movl %esi, %eax
    movl $0, %edx
    divl M
    pushl %edx  # coluna
    pushl %eax  # linha
    pushl $found_msg
    call printf
    addl $12, %esp

    incl search_count

not_found_here:
    incl %esi
    movl N, %eax
    mull M
    cmpl %eax, %esi
    jl busca_loop

    # Verifica se algum elemento foi encontrado
    cmpl $0, search_count
    jne end_search

    # Se nenhum elemento foi encontrado, imprime mensagem
    pushl $not_found
    call printf
    addl $4, %esp

end_search:
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
    cmpl $0, lucky_count
    je no_lucky_found

    # Imprime os lucky numbers encontrados
    pushl $lucky_msg
    call printf
    addl $4, %esp

    movl $0, %edi  # Índice para percorrer lucky_vetor
    movl lucky_count, %esi
    
print_lucky_loop:
    movl lucky_vetor(, %edi, 4), %eax  # Número
    movl lucky_vetor+4(, %edi, 4), %ebx  # Linha
    movl lucky_vetor+8(, %edi, 4), %ecx  # Coluna
    
    pushl %ecx
    pushl %ebx
    pushl %eax
    pushl $lucky_format
    call printf
    addl $16, %esp

    addl $3, %edi
    cmpl %esi, %edi
    jl print_lucky_loop
    jmp menu_loop

no_lucky_found:
    pushl $no_lucky
    call printf
    addl $4, %esp
    jmp menu_loop

calcular_lucky:
    # Reseta o contador de lucky numbers
    movl $0, lucky_count

    movl $0, %edi  # índice da linha atual

lucky_loop_linha:
    movl $0, %esi  # índice da coluna atual

lucky_loop_coluna:
    # Calculo do índice do elemento atual no vetor
    movl %edi, %eax
    mull M
    addl %esi, %eax
    movl vetor(, %eax, 4), %ebx  # Elemento atual

    # Verifica se é mínimo na linha
    movl $1, %ecx  # flag: 1 se for mínimo da linha
    pushl %esi
    movl $0, %esi  # reseta índice da coluna para comparação

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

    # Verifica se é máximo na coluna
    movl $1, %ecx  # flag: 1 se for máximo da coluna
    pushl %edi
    movl $0, %edi  # reseta índice da linha para comparação

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

    # É um lucky number, armazena no lucky_vetor
    movl lucky_count, %eax
    leal lucky_vetor(, %eax, 4), %ecx
    movl %ebx, (%ecx)  # Armazenar o número
    movl %edi, 4(%ecx)  # Armazenar a linha
    movl %esi, 8(%ecx)  # Armazenar a coluna
    addl $3, %eax
    movl %eax, lucky_count

continue_lucky_number:
    incl %esi
    cmpl M, %esi
    jl lucky_loop_coluna

    incl %edi
    cmpl N, %edi
    jl lucky_loop_linha

    ret

mostrar_matriz:
    # Imprime mensagem inicial
    pushl $show_matrix_msg
    call printf
    addl $4, %esp

    movl $0, %edi  # índice da linha atual

mostrar_matriz_loop_linha:
    movl $0, %esi  # índice da coluna atual

mostrar_matriz_loop_coluna:
    # Calcula o índice do elemento atual no vetor
    movl %edi, %eax
    mull M
    addl %esi, %eax
    movl vetor(, %eax, 4), %ebx  # Elemento atual

    # Imprime o elemento
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

    # Encerra o programa
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    