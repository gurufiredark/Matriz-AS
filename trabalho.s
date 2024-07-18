.section .data
    prompt_lines:   .asciz "Digite o numero de linhas: "
    prompt_cols:    .asciz "Digite o numero de colunas: "
    prompt_entry:   .asciz "Digite o valor para a linha %d, coluna %d: "
    result_matrix:  .asciz "Matriz resultante:\n"
    format_int:     .asciz "%d"
    format_entry:   .asciz "%d %d"
    space:          .asciz " "
    newline:        .asciz "\n"
    linhas:         .int 0
    colunas:        .int 0
    matriz:         .int 0

.section .bss
    .lcomm value_buff, 4

.text
.globl _start

_start:
    # Solicitar o número de linhas
    pushl   $prompt_lines
    call    printf
    addl    $4, %esp

    # Ler o número de linhas
    leal    linhas, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    # Solicitar o número de colunas
    pushl   $prompt_cols
    call    printf
    addl    $4, %esp

    # Ler o número de colunas
    leal    colunas, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    # Calcular o tamanho do vetor e alocar memória
    movl    linhas, %eax
    imull   colunas, %eax
    imull   $4, %eax # tamanho de um int (4 bytes)
    pushl   %eax
    call    malloc
    addl    $4, %esp
    movl    %eax, matriz

    # Preencher o vetor
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
    pushl   $prompt_entry
    call    printf
    addl    $12, %esp

    # Ler o valor
    leal    value_buff, %eax
    pushl   %eax
    pushl   $format_int
    call    scanf
    addl    $8, %esp

    # Calcular o índice no vetor e armazenar o valor
    movl    %esi, %ecx
    imull   colunas, %ecx
    addl    %edi, %ecx
    imull   $4, %ecx
    movl    matriz, %ebx
    addl    %ecx, %ebx
    movl    value_buff, %eax
    movl    (%eax), %eax
    movl    %eax, (%ebx)

    incl    %edi
    jmp     fill_matrix_cols

end_fill_matrix_cols:
    incl    %esi
    jmp     fill_matrix_rows

end_fill_matrix_rows:

    # Imprimir o vetor como matriz
    pushl   $result_matrix
    call    printf
    addl    $4, %esp

    movl    $0, %esi
print_matrix_rows:
    cmpl    linhas, %esi
    jge     end_print_matrix

    movl    $0, %edi
print_matrix_cols:
    cmpl    colunas, %edi
    jge     end_print_matrix_cols

    # Calcular o índice no vetor e obter o valor
    movl    %esi, %ecx
    imull   colunas, %ecx
    addl    %edi, %ecx
    imull   $4, %ecx
    movl    matriz, %ebx
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

    incl    %edi
    jmp     print_matrix_cols

end_print_matrix_cols:
    # Imprimir uma nova linha ao final de cada linha da matriz
    pushl   $newline
    call    printf
    addl    $4, %esp

    incl    %esi
    jmp     print_matrix_rows

end_print_matrix:

    # Sair do programa
    call exit

exit:
    movl    $1, %eax
    xorl    %ebx, %ebx
    int     $0x80

# Referências externas
.extern printf
.extern scanf
.extern malloc
