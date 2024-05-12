; ***********************************************************************************************************************
; * Projeto ACOM - PAC-MAN Modificado
; * Modulo:    projeto.asm
; * Descrição: Este programa corre uma versão modificada do pac-man o objetivo é
; *            apanhar os 4 rebuçados sem ser apanhado por um fantasma.
; ***********************************************************************************************************************

; ***********************************************************************************************************************
; * Constantes
; ***********************************************************************************************************************
DISPLAYS               EQU 0A000H      ;

TEC_L                  EQU 0C000H      ; endereço das linhas do teclado (periférico POUT-2)
TEC_C                  EQU 0E000H      ; endereço das colunas do teclado (periférico PIN)
LINHA EQU 1
MASK_TEC               EQU 0FH         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
;UP                    EQU  
;DOWN                  EQU 
;LEFT                  EQU 
;RIGHT                 EQU 
;UP_LEFT               EQU 
;UP_RIGHT              EQU 
;DOWN_LEFT             EQU 
;DOWN_RIGHT            EQU 

MIN_COUNTER            EQU 0
MAX_COUNTER            EQU 100

DEFINE_LINE    		   EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUMN   	   EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    	   EQU 6012H      ; endereço do comando para escrever um pixel
DELETE_WARNING     	   EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
DELETE_SCREEN	 	   EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECT_BACKGROUND_IMG  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
PLAY_SOUND             EQU 605AH      ; endereço do comando para tocar som

START_LIN              EQU  13        ; linha do objeto (a meio do ecrã)
START_COL	           EQU  30        ; coluna do objeto (a meio do ecrã)

BOX_LIN                EQU  11        ; linha da caixa (a meio do ecrã)
BOX_COL	               EQU  26        ; coluna da caixa (a meio do ecrã)

GHOST_LIN              EQU  13        ; linha do fantasma (a meio do ecrã)
GHOST_COL	           EQU  0         ; coluna do fantasma (encostado ao limite esquerdo)

MIN_COL		           EQU  0		  ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COL		           EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
DELAY		           EQU	400H	  ; atraso para limitar a velocidade de movimento do objeto

PAC_HEIGHT             EQU 5          ; altura pacman
PAC_WIDTH		       EQU 4		  ; largura pacman
YELLOW_PIXEL           EQU 0FFF0H	  ; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)

GHOST_HEIGHT           EQU 4          ; altura fantasma
GHOST_WIDTH		       EQU 4		  ; largura fantasma
GREEN_PIXEL            EQU 0F0F0H	  ; cor do pixel: verde em ARGB (opaco e verde no máximo, vermelho e azul a 0)

BOX_HEIGHT             EQU 8          ; altura caixa
BOX_WIDTH		       EQU 12		  ; largura caixa
BLUE_PIXEL             EQU 0F00FH	  ; cor do pixel: azul em ARGB (opaco e azul no máximo, vermelho e verde a 0)

; ***********************************************************************************************************************
; * Dados 
; ***********************************************************************************************************************
    PLACE 1000H

pilha:
    STACK 100H;

SP_initial:

DEFINE_PACMAN:  ; tabela que define o pacman (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YELLOW_PIXEL, YELLOW_PIXEL, 0	                        ;  ## 
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; ####   
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; ####   
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; #### 
	WORD		0, YELLOW_PIXEL, YELLOW_PIXEL, 0	                        ;  ## 

DEFINE_GHOST:   ;table que define o fantasma (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, GREEN_PIXEL, GREEN_PIXEL, 0                              ;  ## 
    WORD        GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL          ; ####
    WORD        GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL          ; ####
    WORD        GREEN_PIXEL, 0, 0, GREEN_PIXEL                              ; #  #

DEFINE_BOX:   ;table que define a caixa onde nasce o pacman (altura, largura, pixels, cor)
    WORD        BOX_HEIGHT
    WORD        BOX_WIDTH
    WORD        BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL, 0, 0, 0, 0, BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL      ; ####    ####
    WORD        BLUE_PIXEL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE_PIXEL                                                            ; #          #
    WORD        BLUE_PIXEL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE_PIXEL                                                            ; #          #
    WORD        BLUE_PIXEL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE_PIXEL                                                            ; #          #
    WORD        BLUE_PIXEL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE_PIXEL                                                            ; #          #
    WORD        BLUE_PIXEL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE_PIXEL                                                            ; #          #
    WORD        BLUE_PIXEL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE_PIXEL                                                            ; #          #
    WORD        BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL, 0, 0, 0, 0, BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL, BLUE_PIXEL      ; ####    ####   
; ***********************************************************************************************************************
; * Código
; ***********************************************************************************************************************
PLACE 0
start:
    MOV SP, SP_initial
    MOV R0,0
    MOV R1, 0
    MOV R2, 0
    MOV R3, 0
    MOV R4, 0
    MOV R5, 0
    MOV R6, 0
    MOV R7, 1                       ; valor a somar à coluna do objeto, para o movimentar
    MOV R8, 0
    MOV R9, 0
    MOV R10, 0
    MOV R11, 0
    MOV [DELETE_WARNING], R0	    ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV [DELETE_SCREEN], R0	        ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV [SELECT_BACKGROUND_IMG], R0 ; seleciona o cenário de fundo        
    
box_position:
    MOV R1, BOX_LIN               ; linha inicial da caixa
    MOV R2, BOX_COL               ; coluna inicial da caixa
    MOV R4, DEFINE_BOX           ; endereço da tabela que define o caixa     
    CALL draw_object

pacman_position:
    MOV R1, START_LIN               ; linha inicial do pacman
    MOV R2, START_COL               ; coluna inicial do pacman
    MOV R4, DEFINE_PACMAN           ; endereço da tabela que define o pacman

show_pacman:
    CALL draw_object

ghost_position:
    MOV R1, GHOST_LIN               ; linha inicial do ghost
    MOV R2, GHOST_COL               ; coluna inicial do ghost
    MOV R4, DEFINE_GHOST            ; endereço da tabela que define o ghost

show_ghost:
    CALL draw_object

main: ; Ciclo principal
    CALL keyboard
    CMP R0, 0
    JNZ main

; **********************************************************************
; write_pixel - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
write_pixel:
	MOV  [DEFINE_LINE], R1		; seleciona a linha
	MOV  [DEFINE_COLUMN], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET

; **********************************************************************
; DRAW_OBJECT - Desenha o objeto na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o objeto
;
; **********************************************************************
draw_object:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    MOV R5, [R4]    ; obtem altura do objeto 
    ADD R4, 2       ; endereço da largura do objeto
    MOV R6, [R4]    ; obtem largura do objeto
    ADD R4, 2       ; endereço da cor do 1º pixel
    MOV R8, R2      ; cria cópia do numero da coluna em que objeto vai ser desenhado
    MOV R9, R6      ; cria cópia da largura do objeto 

draw_rows:
    MOV R7, R5      ; contador linhas que falta desenhar
    draw_pixels:
        MOV R3, [R4] ; obtém a cor do próximo pixel do objeto
        CALL write_pixel ; escreve cada pixel do objeto
        ADD R4, 2
        ADD R2, 1
        SUB R6, 1
        JNZ draw_pixels
    MOV R2, R8     ; reset valor coluna
    MOV R6, R9     ; reset contador pixels que faltam desenhar numa coluna
    ADD R1, 1
    SUB R5, 1
    JNZ draw_rows
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; **********************************************************************
; DELETE_OBJECT - Apaga um objeto na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o objeto
;
; **********************************************************************
delete_object:
    PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    MOV R5, [R4]    ; obtem altura do objeto 
    ADD R4, 2       ; endereço da largura do objeto
    MOV R6, [R4]    ; obtem largura do objeto
    ADD R4, 2       ; endereço da cor do 1º pixel
    MOV R8, R2      ; cria cópia do numero da coluna em que objeto vai ser apagado
    MOV R9, R6      ; cria cópia da largura do objeto 

delete_rows:       	; desenha os pixels do objeto a partir da tabela
    MOV R7, R5      ; contador linhas que falta apagar
    delete_pixels:
        MOV	R3, 0	       ; cor para apagar o próximo pixel do objeto
        CALL write_pixel   ; escreve cada pixel do objeto
        ADD	R4, 2		   ; endereço da cor do próximo pixel
        ADD R2, 1          ; próxima coluna
        SUB R7, 1		   ; menos uma coluna para tratar
        JNZ delete_pixels  ; continua até percorrer toda a largura do objeto
    MOV R2, R8     ; reset valor coluna
    MOV R6, R9     ; reset contador pixels que faltam apagar numa coluna
    ADD R1, 1
    SUB R6, 1
    JNZ delete_rows
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; **********************************************************************
; KEYBOARD - ???
; Argumentos:	????
;
; Retorna: 	????
; **********************************************************************
keyboard:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R0, 0           ; Inicializa R0 para guardar a tecla pressionada
    MOV R2, TEC_L       ; Endereço do periférico das linhas do teclado
    MOV R3, TEC_C       ; Endereço do periférico das colunas do teclado
    MOV R4, DISPLAYS    ; Endereço do periférico dos displays
    MOV R5, MASK_TEC    ; Máscara para a leitura do teclado

    reset_line: 
        MOV R1, LINHA   ; define a linha a ler (inicialmente a 1)
        MOV R7, 0       ; Inicializa o contador de linhas a 0

    check_key:
        MOVB [R2], R1       ; Ativa a linha para leitura do teclado
        MOVB R0, [R3]       ; Lê a coluna do teclado
        AND R0, R5          ; Aplica a máscara
        CMP R0, 0           ; Verifica se alguma tecla foi pressionada
        JZ next_line        ; Se não foi pressionada, passa para a próxima linha
        PUSH R0             ; Guarda a coluna pressionada
        MOV	R8, 0			; som com número 0
	    MOV [TOCA_SOM], R8		; comando para tocar o som
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

    keyboard_end:               ; Termina a rotina
        POP R0                  ; Recupera a coluna pressionada
        CALL keyboard_command   ; Executa o comando da tecla pressionada

    POP R8
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
    MOV R8, MAX_COUNTER ; R8 = MAX_COUNTER
    MOV R9, MIN_COUNTER ; R9 = MIN_COUNTER
    CMP R7, 0           ; TECLA 0
    JZ kc_increment     ; Incrementa o Contador
    CMP R7, 1           ; TECLA 1
    JZ kc_decrement     ; Decrementa o Contador
    JMP kc_end          ; Termina a Rotina
    
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
