DISPLAYS EQU 0A000H

TEC_L EQU 0C000H
TEC_C EQU 0E000H
LINHA EQU 1
MASCARA_TEC EQU 0FH

MIN_COUNTER EQU 0
MAX_COUNTER EQU 100

PLACE 1000H
pilha:
    STACK 100H;

SP_inicial:

PLACE 0
    MOV SP, SP_inicial
    MOV R0,0
    MOV R1,0
    MOV R2,0
    MOV R3,0
    MOV R4,0
    MOV R5,0
    MOV R6,0
    MOV R7,0
    MOV R8,0
    MOV R9,0
    MOV R10,0
    MOV R11,0
    
main: ; Ciclo principal
    CALL keyboard ; Teclado
    JMP main

keyboard:
    PUSH R1;
    PUSH R2;
    PUSH R3;
    PUSH R4;
    PUSH R5;
    PUSH R6;
    PUSH R7;

    MOV R2, TEC_L       ; Endereço do periférico das linhas do teclado
    MOV R3, TEC_C       ; Endereço do periférico das colunas do teclado
    MOV R4, DISPLAYS    ; Endereço do periférico dos displays
    MOV R5, MASCARA_TEC ; Máscara para a leitura do teclado

    reset_line: 
        MOV R1, LINHA   ; define a linha a ler (inicialmente a 1)
        MOV R7, 0       ; Inicializa o contador de linhas a 0

    check_key:
        MOVB [R2], R1       ; Ativa a linha para leitura do teclado
        MOVB R0, [R3]       ; Lê a coluna do teclado
        AND R0, R5          ; Aplica a máscara
        CMP R0, 0           ; Verifica se alguma tecla foi pressionada
        JZ next_line        ; Se não foi pressionada, passa para a próxima linha
        PUSH R0
        JMP is_key_pressed  ; caso contrário, espera que deixe de ser pressionada

    next_line:
        SHL R1, 1      ; Passa para a próxima linha
        INC R7         ; Incrementa o contador de linhas
        CMP R7, 4      ; Verifica se já leu todas as linhas
        JNZ check_key  ; Se não leu todas as linhas, verifica a próxima
        JMP reset_line ; Caso contrário, reinicia a linha

    is_key_pressed: 
        MOVB [R2], R1      ; Ativa a linha para leitura do teclado
        MOVB R0, [R3]      ; Lê a coluna do teclado
        AND R0, R5         ; Aplica a máscara
        CMP R0, 0          ; Verifica se a tecla foi libertada
        JNZ is_key_pressed ; Se não foi libertada, espera que seja
        JMP keyboard_end   ; Termina a rotina

    keyboard_end:
        POP R0             ; Termina a rotina
        SHL R7, 2             ; Multiplica o número da linha por 4
        ADD R7, R0             ; Adiciona o número da coluna
        CALL keyboard_command ; Executa o comando da tecla pressionada

    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

keyboard_command:
    PUSH R8
    PUSH R9
    MOV R8, MAX_COUNTER
    MOV R9, MIN_COUNTER
    CMP R7, 1
    JZ kc_increment
    CMP R7, 2
    JZ kc_decrement
    JMP kc_end
    
    kc_increment:
        ; implement Routine
        JMP kc_end

    kc_decrement:
        ; implement Routine
        JMP kc_end

    kc_end:
        POP R9
        POP R8
        RET
