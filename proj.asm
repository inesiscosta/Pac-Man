NIBBLE_3_0 EQU 000FH
NIBBLE_7_4 EQU 00F0H
NIBBLE_11_8 EQU 0F00H
DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
LINHA      EQU 8       ; linha a testar (4� linha, 1000b)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

PLACE 1000H
pilha:
    STACK 100H;

SP_inicial: ;

imagem_hexa:
    BYTE 00H

PLACE 0

init:
    MOV SP, SP_inicial

    MOV R0, 0
    MOV R1, 0
    MOV R2, 0
    MOV R3, 0

hexa_display:
    PUSH R0
    MOV R0, 0FH
    AND R0, R1
    CALL hexa_low
    MOV R0, R1
    SHR R0, 4
    CALL hexa_middle
    MOV R0, R1
    SHR R0, 8
    CALL hexa_high
    POP R0
    RET

    