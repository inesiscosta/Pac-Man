DISPLAYS EQU 0A000H

TEC_L EQU 0C000H
TEC_C EQU 0E000H
LINHA EQU 1
MASCARA_TEC EQU 0FH

PLACE 1000H
stack:
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

    MOV R2, TEC_L
    MOV R3, TEC_C
    MOV R4, DISPLAYS
    MOV R5, MASCARA_TEC

    reset_line:
        MOV R1, LINHA
        MOV R7, 0

    check_key:
        MOVB [R2], R1
        MOVB R0, [R3]
        AND R0, R5
        CMP R0, 0
        JZ next_line
        JMP is_key_pressed

    next_line:
        SHL R1, 1
        INC R7
        CMP R7, 4
        JNZ check_key
        JMP reset_line

    is_key_pressed:
        MOVB [R2], R1
        MOVB R0, [R3]
        AND R0, R5
        CMP R0, 0
        JNZ is_key_pressed
        JMP keyboard_end

    keyboard_end:
        SHL R7, 2
        OR R7, R0
        CALL keyboard_command

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
