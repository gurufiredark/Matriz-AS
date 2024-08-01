.section .data
    menu:       .asciz "Menu:\n1 - Preencher matriz NxM\n2 - Buscar elemento na matriz\n3 - Mostrar diagonal principal\n4 - Mostrar lucky numbers\n5 - Sair e mostrar uma boa mensagem de saida\nOpcao: "
    prompt_n:   .asciz "Digite o numero de linhas (N): "
    prompt_m:   .asciz "Digite o numero de colunas (M): "
    prompt_val: .asciz "Digite o valor para a linha %d, coluna %d: "
    prompt_find:.asciz "Digite o valor a ser buscado: "
    not_found:  .asciz "Elemento nao encontrado.\n"
    found:      .asciz "Elemento encontrado na linha %d, coluna %d.\n"
    diag_msg:   .asciz "Diagonal principal: "
    lucky_msg:  .asciz "Lucky numbers: "
    bye_msg:    .asciz "Obrigado por usar o programa!\n"
    format_int: .asciz "%d"
    format_op:  .asciz "%d"
    format_ptr: .asciz "%p\n"
    space:      .asciz " "
    newline:    .asciz "\n"
    linhas:     .int 0
    colunas:    .int 0
    matriz:     .int 0
    opcao:      .int 0
    valor:      .int 0

.section .bss
    .lcomm value_buff, 4

.text
.globl _start

_start:
    # Loop principal do menu
menu_loop:
    pushl   $menu
    call    printf
    addl    $4, %esp

    leal    opcao, %eax
    pushl   %eax
    pushl   $format_op
    call    scanf
    addl    $8, %esp

    movl    opcao, %eax
    cmpl    $1, %eax
    je      opcao_1
    cmpl    $2, %eax
    je      opcao_2
    cmpl    $3, %eax
    je      opcao_3
    cmpl    $4, %eax
    je      opcao_4
    cmpl    $5, %eax
    je      opcao_5
    jmp     menu_loop

opcao_1:  # Preencher matriz NxM
    pushl   $prompt_n
    call    printf
    addl    $4, %esp

    leal    linhas, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    pushl   $prompt_m
    call    printf
    addl    $4, %esp

    leal    colunas, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    # Alocar memória para os ponteiros das linhas
    movl    linhas, %eax
    shll    $2, %eax   # multiplicar por 4 (tamanho de um ponteiro)
    pushl   %eax
    call    malloc
    addl    $4, %esp
    movl    %eax, matriz

    # Depurar: Mostrar o ponteiro da matriz
    pushl   matriz
    pushl   $format_ptr
    call    printf
    addl    $8, %esp

    # Alocar memória para cada linha
    movl    $0, %esi
allocate_rows:
    cmpl    linhas, %esi
    jge     end_allocate_rows

    # Calcular endereço do ponteiro da linha
    movl    matriz, %ebx
    movl    %esi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de um ponteiro)
    addl    %ecx, %ebx

    # Alocar memória para a linha
    movl    colunas, %eax
    shll    $2, %eax   # multiplicar por 4 (tamanho de int)
    pushl   %eax
    call    malloc
    addl    $4, %esp
    movl    %eax, (%ebx)

    # Depurar: Mostrar o ponteiro da linha
    pushl   (%ebx)
    pushl   $format_ptr
    call    printf
    addl    $8, %esp

    incl    %esi
    jmp     allocate_rows

end_allocate_rows:
    jmp     fill_matrix

fill_matrix:
    # Preencher a matriz
    movl    $0, %esi
fill_matrix_rows:
    cmpl    linhas, %esi
    jge     end_fill_matrix_rows

    movl    $0, %edi
fill_matrix_cols:
    cmpl    colunas, %edi
    jge     end_fill_matrix_cols

    # Solicitar o valor para a linha %esi, coluna %edi
    pushl   %edi
    pushl   %esi
    pushl   $prompt_val
    call    printf
    addl    $12, %esp

    # Ler o valor
    leal    value_buff, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    # Calcular o índice no vetor e armazenar o valor
    movl    matriz, %ebx
    movl    %esi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de um ponteiro)
    addl    %ecx, %ebx
    movl    (%ebx), %ebx  # ebx agora aponta para a linha correta

    # Depurar: Mostrar o ponteiro da linha
    pushl   %ebx
    pushl   $format_ptr
    call    printf
    addl    $8, %esp

    movl    %edi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de int)
    addl    %ecx, %ebx

    # Depurar: Mostrar o endereço onde o valor será armazenado
    pushl   %ebx
    pushl   $format_ptr
    call    printf
    addl    $8, %esp

    movl    value_buff, %eax
    movl    (%eax), %edx
    movl    %edx, (%ebx)

    incl    %edi
    jmp     fill_matrix_cols

end_fill_matrix_cols:
    incl    %esi
    jmp     fill_matrix_rows

end_fill_matrix_rows:
    jmp     menu_loop

opcao_2:  # Buscar elemento na matriz
    pushl   $prompt_find
    call    printf
    addl    $4, %esp

    leal    value_buff, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    movl    $0, %esi
search_matrix_rows:
    cmpl    linhas, %esi
    jge     element_not_found

    movl    $0, %edi
search_matrix_cols:
    cmpl    colunas, %edi
    jge     search_next_row

    # Calcular o índice no vetor e verificar o valor
    movl    matriz, %ebx
    movl    %esi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de um ponteiro)
    addl    %ecx, %ebx
    movl    (%ebx), %ebx  # ebx agora aponta para a linha correta

    movl    %edi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de int)
    addl    %ecx, %ebx
    movl    (%ebx), %eax
    movl    value_buff, %edx
    cmpl    %edx, %eax
    je      element_found

    incl    %edi
    jmp     search_matrix_cols

search_next_row:
    incl    %esi
    jmp     search_matrix_rows

element_not_found:
    pushl   $not_found
    call    printf
    addl    $4, %esp
    jmp     menu_loop

element_found:
    pushl   %edi
    pushl   %esi
    pushl   $found
    call    printf
    addl    $12, %esp
    jmp     menu_loop

opcao_3:  # Mostrar diagonal principal
    pushl   $diag_msg
    call    printf
    addl    $4, %esp

    movl    $0, %esi
print_diag:
    cmpl    linhas, %esi
    jge     end_print_diag
    cmpl    colunas, %esi
    jge     end_print_diag

    # Calcular o índice na matriz e obter o valor
    movl    matriz, %ebx
    movl    %esi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de um ponteiro)
    addl    %ecx, %ebx
    movl    (%ebx), %ebx  # ebx agora aponta para a linha correta

    movl    %esi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de int)
    addl    %ecx, %ebx
    movl    (%ebx), %eax

    # Imprimir o valor
    pushl   %eax
    pushl   $format_int
    call    printf
    addl    $8, %esp

    # Imprimir um espaço entre os valores
    pushl   $space
    call    printf
    addl    $4, %esp

    incl    %esi
    jmp     print_diag

end_print_diag:
    # Imprimir uma nova linha ao final da diagonal
    pushl   $newline
    call    printf
    addl    $4, %esp
    jmp     menu_loop

opcao_4:  # Mostrar lucky numbers
    pushl   $lucky_msg
    call    printf
    addl    $4, %esp

    movl    $0, %esi
find_lucky_rows:
    cmpl    linhas, %esi
    jge     end_find_lucky_rows

    # Encontrar o menor elemento da linha
    movl    $2147483647, %eax # inicializa com o maior valor possível
    movl    $0, %edi
    movl    %edi, %ebx
find_min_in_row:
    cmpl    colunas, %edi
    jge     check_lucky_col

    movl    matriz, %edx
    movl    %esi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de um ponteiro)
    addl    %ecx, %edx
    movl    (%edx), %edx  # edx agora aponta para a linha correta

    movl    %edi, %ecx
    shll    $2, %ecx   # multiplicar por 4 (tamanho de int)
    addl    %ecx, %edx
    movl    (%edx), %ecx

    cmpl    %ecx, %eax
    jge     not_min_in_row
    movl    %ecx, %eax
    movl    %edi, %ebx

not_min_in_row:
    incl    %edi
    jmp     find_min_in_row

check_lucky_col:
    # Verificar se o menor da linha é o maior da coluna
    movl    %eax, %edx
    movl    $0, %ecx
check_col:
    cmpl    linhas, %ecx
    jge     next_lucky_row

    movl    matriz, %edi
    movl    %ecx, %ebx
    shll    $2, %ebx   # multiplicar por 4 (tamanho de um ponteiro)
    addl    %ebx, %edi
    movl    (%edi), %edi  # edi agora aponta para a linha correta

    movl    %ebx, %ebx
    shll    $2, %ebx   # multiplicar por 4 (tamanho de int)
    addl    %ebx, %edi
    movl    (%edi), %ebx

    cmpl    %ebx, %edx
    jle     not_lucky

    incl    %ecx
    jmp     check_col

not_lucky:
    incl    %esi
    jmp     find_lucky_rows

next_lucky_row:
    pushl   %edx
    pushl   $format_int
    call    printf
    addl    $8, %esp

    # Imprimir um espaço entre os valores
    pushl   $space
    call    printf
    addl    $4, %esp

    incl    %esi
    jmp     find_lucky_rows

end_find_lucky_rows:
    # Imprimir uma nova linha após os lucky numbers
    pushl   $newline
    call    printf
    addl    $4, %esp
    jmp     menu_loop

opcao_5:  # Sair e mostrar uma boa mensagem de saída
    pushl   $bye_msg
    call    printf
    addl    $4, %esp
    jmp     exit

# Chamada ao sistema para sair do programa
exit:
    movl    $1, %eax
    xorl    %ebx, %ebx
    int     $0x80

# Referências externas
.extern printf
.extern scanf
.extern malloc
