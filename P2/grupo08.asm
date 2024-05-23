; *****************************************************************************************************************************
; * Grupo 08 Projeto ACOM - PAC-MAN Modificado
; * Modulo:    projeto.asm
; * Descrição: Este programa corre uma versão modificada do pac-man o objetivo é apanhar os 4 rebuçados sem ser apanhado 
;              por um fantasma.
; * Contribuidores: Marcos Coito Machado ist106082, Nuno João da Cruz Antunes ist98958, Inês Isabel Santos Costa ist1110632
; *****************************************************************************************************************************

; *****************************************************************************************************************************
; * Constantes
; *****************************************************************************************************************************
DISPLAYS               EQU 0A000H      ; endereço dos displays de 7 segmentos (periférico POUT-1)

UP_LEFT_KEY            EQU 11H         ; key 0 for moving up and left
UP_KEY                 EQU 12H         ; key 1 for moving up
UP_RIGHT_KEY           EQU 14H         ; key 2 for moving up and right
LEFT_KEY               EQU 21H         ; key 4 for moving left
RIGHT_KEY              EQU 24H         ; key 6 for moving right
DOWN_LEFT_KEY          EQU 41H         ; key 8 for moving down and left
DOWN__KEY              EQU 42H         ; key 9 for moving down
DOWN_RIGHT_KEY         EQU 44H         ; key A for moving down and right

TEC_L                  EQU 0C000H      ; endereço das linhas do teclado (periférico POUT-2)
TEC_C                  EQU 0E000H      ; endereço das colunas do teclado (periférico PIN)
LINHA                  EQU 1           ; inicialização da linha
MASK_TEC               EQU 0FH         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TEC_INCREMENTA         EQU 82H         ; tecla que incrementa o contador
TEC_DECREMENTA         EQU 81H         ; tecla que decrementa o contador

INITIAL_COUNTER        EQU 0000H       ; valor inicial do contador
MIN_COUNTER            EQU 0           ; valor minimo do display (que o contador pode ter)
MAX_COUNTER            EQU 100H        ; valor máximo do display (que o contador pode ter)
MASK_LSD               EQU 0FH         ; máscara para isolar os 4 btis de menor peso para ver o digito menos significativo
MASK_TENS              EQU 0F0H        ; máscara para isolar os bits que representam as dezenas

DEF_LINE    		   EQU 600AH       ; endereço do comando para definir a linha
DEF_COLUMN   	       EQU 600CH       ; endereço do comando para definir a coluna
DEF_PIXEL    	       EQU 6012H       ; endereço do comando para escrever um pixel
DELETE_WARNING     	   EQU 6040H       ; endereço do comando para apagar o aviso de nenhum cenário selecionado
DELETE_SCREEN	 	   EQU 6002H       ; endereço do comando para apagar todos os pixels já desenhados
SELECT_BACKGROUND_IMG  EQU 6042H       ; endereço do comando para selecionar uma imagem de fundo
PLAY_SOUND             EQU 605AH       ; endereço do comando para tocar som

START_LIN              EQU  13         ; linha inicial do pacman (a meio do ecrã)
START_COL	           EQU  30         ; coluna inicial do pacman (a meio do ecrã)

BOX_LIN                EQU  11         ; linha da caixa
BOX_COL	               EQU  26         ; coluna da caixa

GHOST_LIN              EQU  13         ; linha inicial do fantasma (a meio do ecrã)
GHOST_COL	           EQU  0          ; coluna inicial do fantasma (encostado ao limite esquerdo)

PAC_HEIGHT             EQU 5           ; altura do pacman
PAC_WIDTH		       EQU 5		   ; largura do pacman
YLW                    EQU 0FFF0H	   ; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)

GHOST_HEIGHT           EQU 4           ; altura do fantasma
GHOST_WIDTH		       EQU 4		   ; largura do fantasma
GRN                    EQU 0F0A5H	   ; cor do pixel: verde em ARGB (opaco no máximo, verde a 10, azul a 5 e vermelho a 0)

CANDY_HEIGHT           EQU 4           ; altura do rebuçado
CANDY_WIDTH            EQU 4           ; largura do rebuçado
RED_PIXEL              EQU 0FF00H      ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

EXPLOSION_HEIGHT       EQU 5           ; altura da explosão
EXPLOSION_WIDTH        EQU 5           ; largura da explosão
CYN                    EQU 0F4FFH      ; cor do pixel: ciano em ARGB (opaco, verde e azul no máximo, vermelho a 4)

BOX_HEIGHT             EQU 8           ; altura da caixa
BOX_WIDTH		       EQU 12		   ; largura da caixa
BLU                    EQU 0F469H	   ; cor do pixel: azul em ARGB (opaco e azul a 9, verde a 6 e vermelho a 4)

MAX_LIN EQU 31
MIN_LIN EQU 1

MAX_COL EQU 63
MIN_COL EQU 1

DELAY_COUNT            EQU 3000H

TRUE EQU 1
FALSE EQU 0

; *****************************************************************************************************************************
; * Dados 
; *****************************************************************************************************************************
    PLACE 1000H

pilha:
    STACK 100H  ; espaço reservado para a pilha (200H bytes, pois são 100H words)

SP_initial:     ; este é o endereço (1200H) com que o SP deve ser inicializado.
                ; O 1.º end. de retorno será armazenado em 11FEH (1200H-2)

DEF_PACMAN:  ; tabela que define o pacman (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                        ;  ### 
    WORD		YLW, YLW, YLW, YLW, YLW	                    ; #####   
    WORD		YLW, YLW, YLW, YLW, YLW		                ; #####   
    WORD		YLW, YLW, YLW, YLW, YLW		                ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                        ;  ### 

DEF_OPEN_PACMAN_LEFT:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 
    WORD		0, 0, YLW, YLW, YLW	                    ;   ###
    WORD		0, 0, 0, YLW, YLW		                ;    ##
    WORD		0, 0, YLW, YLW, YLW		                ;   ###
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###


DEF_OPEN_PACMAN_RIGHT:  ; tabela que define o pacman com a boca aberta para a direita (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 
    WORD		YLW, YLW, YLW, 0, 0	                    ; ###   
    WORD		YLW, YLW, 0, 0, 0		                ; ##
    WORD		YLW, YLW, YLW, 0, 0		                ; ### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###

DEF_OPEN_PACMAN_UP:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, 0, 0, 0, 0	                        ;
    WORD		YLW, 0, 0, 0, YLW	                    ; #   #   
    WORD		YLW, YLW, 0, YLW, YLW		            ; ## ##
    WORD		YLW, YLW, YLW, YLW, YLW		            ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###

DEF_OPEN_PACMAN_DOWN:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###
    WORD		YLW, YLW, YLW, YLW, YLW		            ; ##### 
    WORD		YLW, YLW, 0, YLW, YLW		            ; ## ## 
    WORD		YLW, 0, 0, 0, YLW	                    ; #   # 
	WORD		0, 0, 0, 0, 0	                        ; 

DEF_OPEN_PACMAN_UP_LEFT:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, 0, YLW, YLW, 0	                    ;   ##
    WORD		0, 0, 0, YLW, YLW		                ;    ## 
    WORD		YLW, 0, 0, YLW, YLW		                ; #  ## 
    WORD		YLW, YLW, YLW, YLW, YLW	                ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 

DEF_OPEN_PACMAN_UP_RIGHT:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, 0, 0	                    ;   ##
    WORD		YLW, YLW, 0, 0, 0		                ; ##   
    WORD		YLW, YLW, 0, 0, YLW		                ; ##  # 
    WORD		YLW, YLW, YLW, YLW, YLW	                ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 

DEF_OPEN_PACMAN_DOWN_LEFT:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###
    WORD		YLW, YLW, YLW, YLW, YLW	                ; ##### 
    WORD		YLW, 0, 0, YLW, YLW		                ; #  ##
    WORD		0, 0, 0, YLW, YLW		                ;    ##  
	WORD		0, 0, YLW, YLW, 0	                    ;   ##

DEF_OPEN_PACMAN_DOWN_RIGHT:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 
    WORD		YLW, YLW, YLW, YLW, YLW	                ; #####
    WORD		YLW, YLW, 0, 0, YLW		                ; ##  #  
    WORD		YLW, YLW, 0, 0, 0		                ; ##   
	WORD		0, YLW, YLW, 0, 0	                    ;   ##

DEF_GHOST:   ; tabela que define o fantasma (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, GRN, GRN, 0                          ;  ## 
    WORD        GRN, GRN, GRN, GRN                      ; ####
    WORD        GRN, GRN, GRN, GRN                      ; ####
    WORD        GRN, 0, 0, GRN                          ; #  #

DEF_CANDY:   ; tabela que define o rebuçado (altura, largura, pixels, cor)
    WORD        CANDY_HEIGHT
    WORD        CANDY_WIDTH
    WORD        0, 0, 0, RED_PIXEL                      ;    #
    WORD        0, RED_PIXEL, RED_PIXEL, 0              ;  ## 
    WORD        0, RED_PIXEL, RED_PIXEL, 0              ;  ##
    WORD        RED_PIXEL, 0, 0, 0                      ; #

DEF_EXPLOSION:   ; tabela que define a explosão (altura, largura, pixels, cor)
    WORD        EXPLOSION_HEIGHT
    WORD        EXPLOSION_WIDTH
    WORD        CYN, 0, 0, 0, CYN                       ; #   #
    WORD        0, CYN, 0, CYN, 0                       ;  # # 
    WORD        0, 0, CYN, 0, 0                         ;   #  
    WORD        0, CYN, 0, CYN, 0                       ;  # # 
    WORD        CYN, 0, 0, 0, CYN                       ; #   #

DEF_BOX:     ; tabela que define a caixa onde nasce o pacman (altura, largura, pixels, cor)
    WORD        BOX_HEIGHT
    WORD        BOX_WIDTH
    WORD        BLU, BLU, BLU, BLU, 0, 0, 0, 0, BLU, BLU, BLU, BLU      ; ####    ####
    WORD        BLU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLU                  ; #          #
    WORD        BLU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLU                  ; #          #
    WORD        BLU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLU                  ; #          #
    WORD        BLU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLU                  ; #          #
    WORD        BLU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLU                  ; #          #
    WORD        BLU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLU                  ; #          #
    WORD        BLU, BLU, BLU, BLU, 0, 0, 0, 0, BLU, BLU, BLU, BLU      ; ####    ####   

; *****************************************************************************************************************************
; * Código
; *****************************************************************************************************************************
    PLACE 0
start:
    MOV SP, SP_initial
    MOV R0, 0                           ; inicializa todos os registos a zero
    MOV R1, 0
    MOV R2, 0
    MOV R3, 0
    MOV R4, 0
    MOV R5, 0
    MOV R6, 0
    MOV R7, 0
    MOV R8, 0
    MOV R9, 0
    MOV R10, 0
    MOV R11, 0
    MOV [DELETE_WARNING], R0	        ; apaga o aviso de nenhum cenário selecionado (o valor de R0 não é relevante)
    MOV [DELETE_SCREEN], R0	            ; apaga todos os pixels já desenhados (o valor de R0 não é relevante)
    MOV [SELECT_BACKGROUND_IMG], R0     ; seleciona o cenário de fundo        
    
box_position:
    MOV R1, BOX_LIN                     ; linha inicial da caixa
    MOV R2, BOX_COL                     ; coluna inicial da caixa
    MOV R4, DEF_BOX                  ; endereço da tabela que define a caixa     
    CALL draw_object                    ; chama a função para desenhar a caixa

pacman_position:
    MOV R1, START_LIN                   ; linha inicial do pacman
    MOV R2, START_COL                   ; coluna inicial do pacman
    MOV R4, DEF_OPEN_PACMAN_RIGHT    ; endereço da tabela que define o pacman

show_pacman:
    CALL draw_object                    ; chama a função para desenhar o pacman

ghost_position:
    MOV R1, GHOST_LIN                   ; linha inicial do fantasma
    MOV R2, GHOST_COL                   ; coluna inicial do fantasma
    MOV R4, DEF_GHOST                ; endereço da tabela que define o fantasma

show_ghost:
    CALL draw_object                    ; chama a função para desenhar o fantasma

MOV R4, DISPLAYS                        ; guarda o endereço do periférico dos displays em R4
MOV R11, INITIAL_COUNTER                ; inicializa o contador a 0
MOV [R4], R11                           ; põe o valor do contador no display
MOV R10, 0                              ; inicializa R10 a 0
MOV R1, START_LIN                       ;
MOV R2, START_COL                       ;

main: ; ciclo principal
    CALL keyboard                       ; chama a função do teclado para ler as teclas pressionadas
    CMP R0, 0                           
    JNZ main

; *****************************************************************************************************************************
; write_pixel - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; *****************************************************************************************************************************
write_pixel:
	MOV  [DEF_LINE], R1		; seleciona a linha
	MOV  [DEF_COLUMN], R2	; seleciona a coluna
	MOV  [DEF_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET

; *****************************************************************************************************************************
; DRAW_OBJECT - Desenha o objeto na linha e coluna indicadas com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o objeto
;
; *****************************************************************************************************************************
draw_object:
    PUSH R1                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    MOV R5, [R4]                ; obtem altura do objeto 
    ADD R4, 2                   ; endereço da largura do objeto
    MOV R6, [R4]                ; obtem largura do objeto (nº colunas)
    ADD R4, 2                   ; endereço da cor do 1º pixel
    MOV R8, R2                  ; guarda a coluna inicial

draw_rows:
    MOV R7, R6                  ; contador linhas que faltam desenhar
    MOV R2, R8
    draw_pixels:
        MOV R3, [R4]            ; obtém a cor do próximo pixel do objeto
        CALL write_pixel        ; chama a função que desenha cada pixel do objeto
        ADD R4, 2               ; obtem o endereço da cor do próximo pixel
        ADD R2, 1               ; próxima coluna
        SUB R7, 1               ; diminui contador do numero de pixels que faltam desenhar nesta linha
        JNZ draw_pixels
    ADD R1, 1                   ; próxima linha
    SUB R5, 1                   ; diminui contador do numero de linhas que faltam desenhar
    JNZ draw_rows               ; se ainda faltarem linhas repete o ciclo
    POP R9                      ; recupera os valores anteriores dos registos modificados
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
;			      com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o objeto
;
; **********************************************************************
delete_object:
    PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, [R4]           ; obtem altura do objeto 
    MOV R6, [R4+2]         ; obtem largura do objeto
    MOV R8, R2             ; guarda coluna inicial

delete_rows:       	       ; desenha os pixels do objeto a partir da tabela
    MOV R7, R6             ; contador linhas que falta apagar
    MOV R2, R8             ; reset para coluna inicial em cada nova linha
    delete_pixels:
        MOV	R3, 0	       ; cor para apagar o próximo pixel do objeto
        CALL write_pixel   ; escreve cada pixel do objeto
        ADD R2, 1          ; próxima coluna
        SUB R7, 1		   ; menos uma coluna para tratar
        JNZ delete_pixels  ; continua até percorrer toda a largura do objeto
    ADD R1, 1
    SUB R5, 1
    JNZ delete_rows
   
    POP R8
    POP R7
    POP R6
    POP R5
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; IS_OBJ_AT_LIMIT - Testa se o objeto chegou aos limites do ecrã.
; Argumentos:	R1 - linha em que o objeto se encontra
;               R2 - coluna em que o objeto se encontra
;			    R4 - tabela que define o objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: R0 - 1 ou 0 (True or False) dependendo se o objeto se encontra num limite ou não
; *****************************************************************************************************************************
is_obj_at_limit:
    PUSH    R1
    PUSH    R2
	PUSH	R5
	PUSH	R6
    PUSH    R9
    MOV R5, [R4]   ; altura objeto
    MOV R6, [R4+2] ; largura objeto
    ADD R1, R7
    ADD R2, R8
    CMP R7, 0     
    JZ test_left_limit

test_top_limit:
    MOV R9, MIN_LIN
    CMP R1, R9
    JLT at_limit
    CMP R8, 0
    JZ test_bottom_limit

test_left_limit:
	MOV	R9, MIN_COL
	CMP	R2, R9
	JLT	at_limit
    CMP R7, 0
    JZ test_right_limit

test_bottom_limit:
    ADD R5, R1
    MOV R9, MAX_LIN
    CMP R5, R9 
	JGT	at_limit
    CMP R8, 0
    JZ not_at_limit

test_right_limit:
    ADD	R6, R2
	MOV	R9, MAX_COL
	CMP	R6, R9
	JGT	at_limit
    JMP not_at_limit 

at_limit:
    MOV R0, TRUE
    JMP leave_is_obj_at_limit

not_at_limit:
    MOV R0, FALSE

leave_is_obj_at_limit:
    POP R9
	POP	R6
	POP	R5
    POP R2
    POP R1
	RET

; *****************************************************************************************************************************
; MOVE_OBJECT - Incrementa ou decrementa o contador com base na tecla pressionada e atualiza o display
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - tabela que define o objeto
;               R4 - tabela que define a animação do objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna:      R1 - novo valor da linha, após o movimento
;               R2 - novo valor da coluna, após o movimento
; *****************************************************************************************************************************
move_object:
    PUSH R0
    PUSH R6
    PUSH R9
    PUSH R4

    MOV R4, R3
    CALL is_obj_at_limit
    CMP R0, TRUE
    JZ pre_end
    CALL delete_object   ; apaga o objeto
    POP R4
    ADD R1, R7           ; obtém nova linha
    ADD R2, R8           ; obtém nova coluna
    CALL draw_object     ; desenha versão animada/intermedia do objeto
    CALL delay
    CALL delete_object   ; apaga o objeto
    MOV R4, R3
    CALL draw_object     ; desenha versão final do objeto
    CALL delay
    JMP end_movement

pre_end:
    POP R4

end_movement:
    POP R9
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; KEYBOARD - Verifica se uma tecla foi pressionada
;
; *****************************************************************************************************************************
keyboard:
    PUSH R3                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11

    MOV R0, 0                   ; inicializa R0 para guardar a tecla pressionada
    MOV R4, TEC_L               ; endereço do periférico das linhas do teclado
    MOV R5, TEC_C               ; endereço do periférico das colunas do teclado
    MOV R7, MASK_TEC            ; máscara para a leitura do teclado

    reset_line: 
        MOV R3, LINHA           ; define a linha a ler (inicialmente a 1)
        MOV R9, 0               ; inicializa o contador de linhas a 0

    check_key:
        MOVB [R4], R3           ; ativa a linha para leitura do teclado
        MOVB R0, [R5]           ; lê a coluna do teclado
        AND R0, R7              ; aplica a máscara
        CMP R0, 0               ; verifica se alguma tecla foi pressionada
        JZ next_line            ; se nenhuma tecla foi pressionada, passa para a próxima linha
        PUSH R0                 ; guarda a coluna pressionada
        MOV	R10, 0			    ; som com número 0
        MOV [PLAY_SOUND], R10   ; comando para tocar o som
        JMP is_key_pressed      ; caso contrário, espera que a tecla deixe de ser pressionada

    next_line:
        SHL R3, 1               ; passa para a próxima linha do teclado
        INC R9                  ; incrementa o contador de linhas
        CMP R9, 4               ; verifica se já leu todas as linhas
        JNZ check_key           ; se não leu todas as linhas, verifica a próxima
        JMP reset_line          ; caso contrário, volta para a 1ª linha

    is_key_pressed:
        CALL movement_key       
        MOVB [R4], R3           ; ativa a linha para leitura do teclado
        MOVB R0, [R5]           ; lê a coluna do teclado
        AND R0, R7              ; aplica a máscara
        CMP R0, 0               ; verifica se a tecla foi libertada
        JNZ is_key_pressed      ; se não foi libertada, espera que seja

    POP R0                      ; recupera a coluna pressionada
    POP R11
    POP R10
    POP R9
    POP R8                      ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    RET

; *****************************************************************************************************************************
; MOVEMENT_KEY - Incrementa ou decrementa o contador com base na tecla pressionada e atualiza o display
; Argumentos:   R0 - valor da coluna pressionada
;               R3 - valor da linha pressionada
;               R11 - valor atual do contador 
;
; Retorna:      R11 - valor atualizado do contador
; *****************************************************************************************************************************
movement_key:
    PUSH R3                 ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, 500             ; inicializa R5 com o valor de iterações para delay

    ; Key mappings for movement
    SHL R3, 4               ; coloca linha nibble high
    OR R3, R0               ; juntamos a coluna (nibble low)
    MOV R6, UP_LEFT_KEY
    CMP R3, R6
    JZ move_up_left         ;
    MOV R6, UP_KEY
    CMP R3, R6              ; verifica se é a tecla para mover para cima
    JZ move_up
    MOV R6, UP_RIGHT_KEY
    CMP R3, R6
    JZ move_up_right
    MOV R6, LEFT_KEY
    CMP R3, R6              ; verifica se é a tecla para mover para a esquerda
    JZ move_left
    MOV R6, RIGHT_KEY
    CMP R3, R6              ; verifica se é a tecla para mover para a direita
    JZ move_right
    MOV R6, DOWN_LEFT_KEY
    CMP R3, R6
    JZ move_down_left
    MOV R6, DOWN__KEY
    CMP R3, R6              ; verifica se é a tecla para mover para baixo
    JZ move_down
    MOV R6, DOWN_RIGHT_KEY
    CMP R3, R6
    JZ move_down_right
    JMP end_move

move_up_left:
    MOV R3, DEF_OPEN_PACMAN_UP_LEFT
    MOV R7, -1
    MOV R8, -1
    JMP move

move_up:
    MOV R3, DEF_OPEN_PACMAN_UP
    MOV R7, -1
    MOV R8, 0
    JMP move

move_up_right:
    MOV R3, DEF_OPEN_PACMAN_UP_RIGHT
    MOV R7, -1
    MOV R8, 1
    JMP move

move_left:
    MOV R3, DEF_OPEN_PACMAN_LEFT
    MOV R7, 0
    MOV R8, -1
    JMP move

move_right:
    MOV R3, DEF_OPEN_PACMAN_RIGHT
    MOV R7, 0
    MOV R8, 1
    JMP move

move_down_left:
    MOV R3, DEF_OPEN_PACMAN_DOWN_LEFT
    MOV R7, 1
    MOV R8, -1
    JMP move

move_down:
    MOV R3, DEF_OPEN_PACMAN_DOWN
    MOV R7, 1
    MOV R8, 0
    JMP move

move_down_right:
    MOV R3, DEF_OPEN_PACMAN_DOWN_RIGHT
    MOV R7, 1
    MOV R8, 1

move:
    MOV R4, DEF_PACMAN
    CALL move_object

end_move:
    POP R8                  ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    RET

; **********************************************************************
; DELAY - Introduces a delay
; Argumentos: Nenhum
; **********************************************************************
delay:
    PUSH R0
    PUSH R1
    MOV R0, DELAY_COUNT

delay_loop:
    DEC R0
    JNZ delay_loop
    POP R1
    POP R0
    RET