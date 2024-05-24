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
TRUE                   EQU 1           ; valor numérico para representar TRUE (1)
FALSE                  EQU 0           ; valor numérico para representar FALSE (0)
DELAY                  EQU 05000H       ; numero de ciclos de delay para atrasar a animação do movimento
DISPLAYS               EQU 0A000H      ; endereço dos displays de 7 segmentos (periférico POUT-1)

; MediaCenter
DEF_LINE    		   EQU 600AH       ; endereço do comando para definir a linha
DEF_COLUMN   	       EQU 600CH       ; endereço do comando para definir a coluna
DEF_PIXEL    	       EQU 6012H       ; endereço do comando para escrever um pixel
DELETE_WARNING     	   EQU 6040H       ; endereço do comando para apagar o aviso de nenhum cenário selecionado
DELETE_SCREEN	 	   EQU 6002H       ; endereço do comando para apagar todos os pixels já desenhados
SELECT_BACKGROUND_IMG  EQU 6042H       ; endereço do comando para selecionar uma imagem de fundo
PLAY_SOUND             EQU 605AH       ; endereço do comando para tocar som
LOOP_PLAY_SOUND        EQU 605CH       ; endereço do comando para reproduzir o som ou video especificado em ciclo
PAUSE_SOUND            EQU 605EH       ; endereço do comando para pausar a reprodução do som ou video especificado
RESUME_SOUND           EQU 6006H       ; endereço do comando para resumir a reprodução do som ou video especificado
STOP_SOUND             EQU 6066H       ; endereço do comando para terminar a reprodução do som ou video especificado

; Imagens
GAME_BACKGROUND        EQU 0           ;

; Sons
PACMAN_CHOMP           EQU 0           ; som do pacman a movimentar-se

; Controlos
UP_LEFT_KEY            EQU 11H         ; key 0 for moving up and left
UP_KEY                 EQU 12H         ; key 1 for moving up
UP_RIGHT_KEY           EQU 14H         ; key 2 for moving up and right
LEFT_KEY               EQU 21H         ; key 4 for moving left
RIGHT_KEY              EQU 24H         ; key 6 for moving right
DOWN_LEFT_KEY          EQU 41H         ; key 8 for moving down and left
DOWN__KEY              EQU 42H         ; key 9 for moving down
DOWN_RIGHT_KEY         EQU 44H         ; key A for moving down and right

; Teclado
KEY_LIN                EQU 0C000H      ; endereço das linhas do teclado (periférico POUT-2)
KEY_COL                EQU 0E000H      ; endereço das colunas do teclado (periférico PIN)
KEY_START_LINE         EQU 1           ; inicialização da linha
MASK_TEC               EQU 0FH         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; Contador
MASK_LSD               EQU 0FH         ; máscara para isolar os 4 btis de menor peso para ver o digito menos significativo
MASK_TENS              EQU 0F0H        ; máscara para isolar os bits que representam as dezenas

; Posições Iniciais
PAC_START_LIN          EQU 13          ; linha inicial do pacman (a meio do ecrã)
PAC_START_COL          EQU 30          ; coluna inicial do pacman (a meio do ecrã)
GHOST_START_LIN        EQU 13          ; linha inicial do fantasma (a meio do ecrã)
GHOST1_START_COL       EQU 0           ; coluna inicial do fantasma1 (encostado ao limite esquerdo)
GHOST2_START_COL       EQU 62          ; coluna inicial do fantasma2 (encostado ao limite esquerdo)
GHOST3_START_COL       EQU 0           ; coluna inicial do fantasma3 (encostado ao limite esquerdo)
GHOST4_START_COL       EQU 62          ; coluna inicial do fantasma4 (encostado ao limite esquerdo)
BOX_LIN                EQU 11          ; linha da caixa
BOX_COL	               EQU 26          ; coluna da caixa
CANDY1_LIN			   EQU  1          ; linha do 1º rebuçado
CANDY1_COL		       EQU  1   	   ; coluna do 1º rebuçado
CANDY2_LIN			   EQU  1          ; linha do 2º rebuçado
CANDY2_COL		       EQU  59 	       ; coluna do 2º rebuçado
CANDY3_LIN			   EQU  27         ; linha do 3º rebuçado
CANDY3_COL		       EQU  1 		   ; coluna do 3º rebuçado
CANDY4_LIN			   EQU  27         ; linha do 4º rebuçado
CANDY4_COL		       EQU  59		   ; coluna do 4º rebuçado

; Posições Atuais
PAC_LIN                EQU 3FECH       ; endereco da memoria onde se encontra a linha atual do pacman
PAC_COL                EQU 3FEEH       ; endereco da memoria onde se encontra a coluna atual do pacman
GHOST1_LIN             EQU 3FF0H       ; endereco da memoria onde se encontra a linha atual do fantasma1
GHOST1_COL             EQU 3FF2H       ; endereco da memoria onde se encontra a coluna atual do fantasma1
GHOST2_LIN             EQU 3FF4H       ; endereco da memoria onde se encontra a linha atual do fantasma2
GHOST2_COL             EQU 3FF6H       ; endereco da memoria onde se encontra a coluna atual do fantasma2
GHOST3_LIN             EQU 3FF8H       ; endereco da memoria onde se encontra a linha atual do fantasma3
GHOST3_COL             EQU 3FFAH       ; endereco da memoria onde se encontra a coluna atual do fantasma3
GHOST4_LIN             EQU 3FFCH       ; endereco da memoria onde se encontra a linha atual do fantasma4
GHOST4_COL             EQU 3FFEH       ; endereco da memoria onde se encontra a coluna atual do fantasma4

; Cores
YLW                    EQU 0FFF0H	   ; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)
GRN                    EQU 0F0A5H	   ; cor do pixel: verde em ARGB (opaco no máximo, verde a 10, azul a 5 e vermelho a 0)
RED                    EQU 0FF00H      ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
CYAN                   EQU 0F4FFH      ; cor do pixel: ciano em ARGB (opaco, verde e azul no máximo, vermelho a 4)
BLUE                   EQU 0F469H	   ; cor do pixel: azul em ARGB (opaco e azul a 9, verde a 6 e vermelho a 4)

; Medidas
PAC_HEIGHT             EQU 5           ; altura do pacman
PAC_WIDTH		       EQU 5		   ; largura do pacman
GHOST_HEIGHT           EQU 4           ; altura do fantasma
GHOST_WIDTH		       EQU 4		   ; largura do fantasma
CANDY_HEIGHT           EQU 4           ; altura do rebuçado
CANDY_WIDTH            EQU 4           ; largura do rebuçado
EXPLOSION_HEIGHT       EQU 5           ; altura da explosão
EXPLOSION_WIDTH        EQU 5           ; largura da explosão
BOX_HEIGHT             EQU 8           ; altura da caixa
BOX_WIDTH		       EQU 12		   ; largura da caixa

; Limites
MIN_LIN                EQU 1           ; linha limite mínimo do ecrã
MAX_LIN                EQU 31          ; linha limite máximo do ecrã
MIN_COL                EQU 1           ; coluna limite máximo do ecrã
MAX_COL                EQU 63          ; coluna limite mínimo do ecrã
; *****************************************************************************************************************************
; * Dados 
; *****************************************************************************************************************************
    PLACE 1000H

pilha:
    STACK 100H  ; espaço reservado para a pilha (200H bytes, pois são 100H words)

SP_initial:     ; este é o endereço (1200H) com que o SP deve ser inicializado.
                ; O 1.º end. de retorno será armazenado em 11FEH (1200H-2)

tab:
    WORD rot_int_0

DEF_PACMAN:     ; tabela que define o pacman (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0                     ;  ### 
    WORD		YLW, YLW, YLW, YLW, YLW	                ; #####   
    WORD		YLW, YLW, YLW, YLW, YLW		            ; #####   
    WORD		YLW, YLW, YLW, YLW, YLW		            ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 

DEF_OPEN_PAC_LEFT:  ; tabela que define o pacman com a boca aberta para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		YLW, YLW, YLW, 0, 0	                    ; ### 
    WORD		0, YLW, YLW, YLW, 0	                    ;  ###
    WORD		0, 0, YLW, YLW, 0		                ;   ##
    WORD		0, YLW, YLW, YLW, 0		                ;  ###
	WORD		YLW, YLW, YLW, 0, 0	                    ; ###

DEF_OPEN_PAC_RIGHT:  ; tabela que define o pacman com a boca aberta para a direita (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, 0, YLW, YLW, YLW	                    ;  ### 
    WORD		0, YLW, YLW, YLW, 0	                    ; ###   
    WORD		0, YLW, YLW, 0, 0		                ; ##
    WORD		0, YLW, YLW, YLW, 0		                ; ### 
	WORD		0, 0, YLW, YLW, YLW	                    ;  ###

DEF_OPEN_PAC_UP:  ; tabela que define o pacman com a boca aberta para cima (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD		YLW, 0, 0, 0, YLW	                    ; #   #   
    WORD		YLW, YLW, 0, YLW, YLW		            ; ## ##
    WORD		YLW, YLW, YLW, YLW, YLW		            ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###
	WORD		0, 0, 0, 0, 0	                        ;

DEF_OPEN_PAC_DOWN:  ; tabela que define o pacman com a boca aberta para baixo (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, 0, 0, 0, 0	                        ; 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###
    WORD		YLW, YLW, YLW, YLW, YLW		            ; ##### 
    WORD		YLW, YLW, 0, YLW, YLW		            ; ## ## 
    WORD		YLW, 0, 0, 0, YLW	                    ; #   # 

DEF_OPEN_PAC_UP_LEFT:  ; tabela que define o pacman com a boca aberta para cima e para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, 0, YLW, YLW, 0	                    ;   ##
    WORD		0, 0, 0, YLW, YLW		                ;    ## 
    WORD		YLW, 0, 0, YLW, YLW		                ; #  ## 
    WORD		YLW, YLW, YLW, YLW, YLW	                ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 

DEF_OPEN_PAC_UP_RIGHT:  ; tabela que define o pacman com a boca aberta para cima e para a direita (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, 0, 0	                    ;   ##
    WORD		YLW, YLW, 0, 0, 0		                ; ##   
    WORD		YLW, YLW, 0, 0, YLW		                ; ##  # 
    WORD		YLW, YLW, YLW, YLW, YLW	                ; ##### 
	WORD		0, YLW, YLW, YLW, 0	                    ;  ### 

DEF_OPEN_PAC_DOWN_LEFT:  ; tabela que define o pacman com a boca aberta para baixo e para a esquerda (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YLW, YLW, YLW, 0	                    ;  ###
    WORD		YLW, YLW, YLW, YLW, YLW	                ; ##### 
    WORD		YLW, 0, 0, YLW, YLW		                ; #  ##
    WORD		0, 0, 0, YLW, YLW		                ;    ##  
	WORD		0, 0, YLW, YLW, 0	                    ;   ##

DEF_OPEN_PAC_DOWN_RIGHT:  ; tabela que define o pacman com a boca aberta para baixo e para a direita (altura, largura, pixels, cor)
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

DEF_GHOST_ANIMATED:   ; tabela que define o fantasma (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, GRN, GRN, 0                          ;  ##
    WORD        GRN, GRN, GRN, GRN                      ; ####
    WORD        GRN, GRN, GRN, GRN                      ; ####
    WORD        0, GRN, GRN, 0                          ;  ## 

DEF_CANDY:   ; tabela que define o rebuçado (altura, largura, pixels, cor)
    WORD        CANDY_HEIGHT
    WORD        CANDY_WIDTH
    WORD        0, 0, 0, RED                            ;    #
    WORD        0, RED, RED, 0                          ;  ## 
    WORD        0, RED, RED, 0                          ;  ##
    WORD        RED, 0, 0, 0                            ; #

DEF_EXPLOSION:   ; tabela que define a explosão (altura, largura, pixels, cor)
    WORD        EXPLOSION_HEIGHT
    WORD        EXPLOSION_WIDTH
    WORD        CYAN, 0, 0, 0, CYAN                     ; #   #
    WORD        0, CYAN, 0, CYAN, 0                     ;  # # 
    WORD        0, 0, CYAN, 0, 0                        ;   #  
    WORD        0, CYAN, 0, CYAN, 0                     ;  # # 
    WORD        CYAN, 0, 0, 0, CYAN                     ; #   #

DEF_BOX:     ; tabela que define a caixa onde nasce o pacman (altura, largura, pixels, cor)
    WORD        BOX_HEIGHT
    WORD        BOX_WIDTH
    WORD        BLUE, BLUE, BLUE, BLUE, 0, 0, 0, 0, BLUE, BLUE, BLUE, BLUE      ; ####    ####
    WORD        BLUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE                        ; #          #
    WORD        BLUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE                        ; #          #
    WORD        BLUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE                        ; #          #
    WORD        BLUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE                        ; #          #
    WORD        BLUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE                        ; #          #
    WORD        BLUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, BLUE                        ; #          #
    WORD        BLUE, BLUE, BLUE, BLUE, 0, 0, 0, 0, BLUE, BLUE, BLUE, BLUE      ; ####    ####   

CHECK_IE:
    WORD 0   ; observa chamadas da interrupção 0
    WORD 0   ; observa chamadas da interrupção 1
    WORD 0   ; observa chamadas da interrupção 2
    WORD 0   ; observa chamadas da interrupção 3

; *****************************************************************************************************************************
; * Código
; *****************************************************************************************************************************
    PLACE 0
start:
    MOV SP, SP_initial
    MOV BTE, tab
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
    MOV R4, DEF_BOX                     ; endereço da tabela que define a caixa     
    CALL draw_object                    ; chama a função para desenhar a caixa

ghost_position:
    MOV R2, GHOST1_LIN                  ; endereço da linha atual do fantasma
    MOV R1, GHOST_START_LIN             ; valor da linha inicial do fantasma
    MOV [R2], R1                        ; guarda na RAM a linha atual do fantasma (de momento a inicial)
    MOV R3, GHOST1_COL                  ; endereço da coluna inicial do fantasma
    MOV R2, GHOST1_START_COL            ; valor da coluna inicial do fantasma
    MOV [R3], R2                        ; guarda na RAM a coluna atual do fantasma (de momento a inicial)
    MOV R4, DEF_GHOST                   ; endereço da tabela que define o fantasma
    CALL draw_object                    ; chama a função para desenhar o fantasma

candy1:
    MOV R1, CANDY1_LIN
    MOV R2, CANDY1_COL
    MOV R4, DEF_CANDY
    CALL draw_object

candy2:
    MOV R1, CANDY2_LIN
    MOV R2, CANDY2_COL
    MOV R4, DEF_CANDY
    CALL draw_object

candy3:
    MOV R1, CANDY3_LIN
    MOV R2, CANDY3_COL
    MOV R4, DEF_CANDY
    CALL draw_object

candy4:
    MOV R1, CANDY4_LIN
    MOV R2, CANDY4_COL
    MOV R4, DEF_CANDY
    CALL draw_object

pacman_position:
    MOV R2, PAC_LIN                     ; endereço da linha atual do pacman
    MOV R1, PAC_START_LIN               ; valor da linha inicial do pacman
    MOV [R2], R1                        ; guarda na RAM a linha atual do pacman (de momento a inicial)
    MOV R3, PAC_COL                     ; endereço da coluna inicial do pacman
    MOV R2, PAC_START_COL               ; valor da coluna inicial do pacman
    MOV [R3], R2                        ; guarda na RAM a coluna atual do pacman (de momento a inicial)
    MOV R4, DEF_OPEN_PAC_RIGHT          ; endereço da tabela que define o pacman
    CALL draw_object                    ; chama a função para desenhar o pacman

EI0
EI

main: ; ciclo principal
    CALL keyboard                       ; chama a função do teclado para ler as teclas pressionadas
    CALL ghost_cicle
    JMP main

; *****************************************************************************************************************************
; WRITE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; *****************************************************************************************************************************
write_pixel:
	MOV  [DEF_LINE], R1		    ; seleciona a linha
	MOV  [DEF_COLUMN], R2	    ; seleciona a coluna
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
    MOV R5, [R4]                ; obtem altura do objeto 
    ADD R4, 2                   ; endereço da largura do objeto
    MOV R6, [R4]                ; obtem largura do objeto (nº colunas)
    ADD R4, 2                   ; endereço da cor do 1º pixel
    MOV R8, R2                  ; guarda a coluna inicial

draw_rows:
    MOV R7, R6                  ; contador linhas que faltam desenhar
    MOV R2, R8                  ; reinicia a coluna
    draw_pixels:
        MOV R3, [R4]            ; obtém a cor do próximo pixel do objeto
        CALL write_pixel        ; chama a função que desenha cada pixel do objeto
        ADD R4, 2               ; obtem o endereço da cor do próximo pixel
        ADD R2, 1               ; próxima coluna
        SUB R7, 1               ; diminui contador do número de pixels que faltam desenhar nesta linha
        JNZ draw_pixels
    ADD R1, 1                   ; próxima linha
    SUB R5, 1                   ; diminui contador do número de linhas que faltam desenhar
    JNZ draw_rows               ; se ainda faltarem linhas repete o ciclo

    POP R8                      ; recupera os valores anteriores dos registos modificados
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
    PUSH R1                     ; guarda os valores anteriores dos registos que são alterados nesta função
	PUSH R2
	PUSH R3
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, [R4]                ; obtem a altura do objeto 
    MOV R6, [R4+2]              ; obtem largura do objeto (nº colunas)
    MOV R8, R2                  ; guarda a coluna inicial

delete_rows:       	            ; desenha os pixels do objeto a partir da tabela
    MOV R7, R6                  ; contador linhas que falta apagar
    MOV R2, R8                  ; reset para coluna inicial em cada nova linha
    delete_pixels:
        MOV	R3, 0	            ; cor para apagar o próximo pixel do objeto
        CALL write_pixel        ; escreve cada pixel do objeto
        ADD R2, 1               ; próxima coluna
        SUB R7, 1		        ; menos uma coluna para tratar
        JNZ delete_pixels       ; continua até percorrer toda a largura do objeto
    ADD R1, 1                   ; proxima linha
    SUB R5, 1                   ; diminui o contador do número de linhas que faltam apagar
    JNZ delete_rows             ; se ainda faltar apagar linhas repete o ciclo

    POP R8                      ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R6
    POP R5
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; IS_OBJ_OVER_LIMIT - Testa se o objeto está a tentar ultrapassar aos limites do ecrã.
; Argumentos:	R1 - linha em que o objeto se encontra
;               R2 - coluna em que o objeto se encontra
;			    R4 - tabela que define o objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: R0 - 1 ou 0 (True or False) dependendo se o objeto se encontra num limite ou não
; *****************************************************************************************************************************
is_obj_over_limit:
    PUSH    R1                  ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH    R2
	PUSH	R5
	PUSH	R6
    PUSH    R9
    MOV R5, [R4]                ; obtém a altura objeto
    MOV R6, [R4+2]              ; obtém a largura objeto
    ADD R1, R7                  ; soma à linha o valor do eventual movimento
    ADD R2, R8                  ; soma à coluna o valor do eventual movimento
    CMP R7, 0                   ; determina se o objeto está a ser movido na vertical
    JZ test_left_limit          ; se não estiver a tentar ser movido na vertical salta à frente o teste do limite superior diretamente para o teste do limite esquerdo

test_top_limit:
    MOV R9, MIN_LIN             ; guarda o valor do limite superior do ecrã
    CMP R1, R9                  ; compara este valor com o valor da linha em que o objeto se encontra
    JLT over_limit              ; se o valor for inferior então o objeto está a tentar ultrapassar um dos limite então salta para over_limit
    CMP R8, 0                   ; determina se o objeto está a ser movido na horizontal
    JZ test_bottom_limit        ; se não estiver a tentar ser movido na horizontal salta à frente o teste do limite esquerdo diretamente para o teste do limite inferior

test_left_limit:
	MOV	R9, MIN_COL             ; guarda o valor do limite esquerdo das colunas do ecrã
	CMP	R2, R9                  ; compara este valor com o valor da coluna em que o objeto se encontra
	JLT	over_limit              ; se o valor for inferior então o objeto está a tentar ultrapassar um dos limite então salta para over_limit
    CMP R7, 0                   ; determina se o objeto está a ser movido na vertical
    JZ test_right_limit         ; se não estiver a tentar ser movido na vertical salta à frente o teste do limite inferior diretamente para o teste do limite direito

test_bottom_limit:
    ADD R5, R1                  ; soma à altura do objeto a linha em que se encontra                 
    MOV R9, MAX_LIN             ; guarda o valor do limite inferior do ecrã
    CMP R5, R9                  ; compara o valor da soma (o limite inferior do objeto) com o limite inferior do ecrã
	JGT	over_limit              ; se o valor do limite inferior do objeto for superior ao limite inferior do ecrã então o objeto está a tentar ultrapassar o limite então salta para over_limit
    CMP R8, 0                   ; determina se o objeto está a ser movido na horizontal
    JZ not_over_limit           ; se não estiver a tentar ser movido na horizontal salta à frente o teste do limite direito diretamente para not_over_limit

test_right_limit:
    ADD	R6, R2                  ; soma à largura do objeto a coluna em que se encontra
	MOV	R9, MAX_COL             ; guarda o valor do limite direito do ecrã
	CMP	R6, R9                  ; compara o valor da soma (o limite direito do objeto) com o limite direito do ecrã
	JGT	over_limit              ; se o valor do limite direito do objeto for superior ao limite direito do ecrã então o objeto está a tentar ultrapassar o limite então salta para at_limit
    JMP not_over_limit          ; se não, salta para not_at_limit

over_limit:
    MOV R0, TRUE                ; move o valor 1 para R0 (de modo a representar TRUE)
    JMP leave_limit_tests       ; salta para o fim da rotina

not_over_limit:
    MOV R0, FALSE               ; move o valor 0 para R0 (de modo a representar FALSE)

leave_limit_tests:
    POP R9                      ; recupera os valores anteriores dos registos modificados
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
    PUSH R0                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R6
    PUSH R9

    CALL is_obj_over_limit      ; chama a função que verifica se o objeto está a tentar ultrapassar algum limite com este movimento
    CMP R0, TRUE                ; compara o retorno da função (R0) com o valor para TRUE
    JZ end_movement             ; se a função retornar true então saltamos para end_movement pois o movimento é proíbido
    CALL delete_object          ; se não, apaga o objeto
    ADD R1, R7                  ; obtém nova linha
    ADD R2, R8                  ; obtém nova coluna
    PUSH R4                     ; guarda o valor de R4
    MOV R4, R3                  ; move o valor de R3 para R4 para ser usado como argumento na função seguinte
    CALL draw_object            ; desenha versão animada do objeto
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento
    CALL delete_object          ; apaga a versão animada do objeto
    POP R4                      ; recupera o valor de R4
    CALL draw_object            ; desenha versão final do objeto
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento 

end_movement:
    POP R9                      ; recupera os valores anteriores dos registos modificados
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; KEYBOARD - Verifica se uma tecla foi pressionada
;
; *****************************************************************************************************************************
keyboard:
    PUSH R0
    PUSH R3                     
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10

    MOV R3, KEY_START_LINE  ; define a linha a ler (inicialmente a 1)
    MOV R0, 0                   ; inicializa R0 para guardar a tecla pressionada
    MOV R4, KEY_LIN             ; endereço do periférico das linhas do teclado
    MOV R5, KEY_COL             ; endereço do periférico das colunas do teclado
    MOV R7, MASK_TEC            ; máscara para a leitura do teclado
    MOV R9, 0               ; inicializa o contador de linhas a 0

    check_key:
        MOVB [R4], R3           ; ativa a linha para leitura do teclado
        MOVB R0, [R5]           ; lê a coluna do teclado
        AND R0, R7              ; aplica a máscara
        CMP R0, 0               ; verifica se alguma tecla foi pressionada
        JZ next_line            ; se nenhuma tecla foi pressionada, passa para a próxima linha
        MOV	R10, 0			    ; som com número 0
        MOV [PLAY_SOUND], R10   ; comando para tocar o som
        JMP is_key_pressed      ; caso contrário, espera que a tecla deixe de ser pressionada

    next_line:
        SHL R3, 1               ; passa para a próxima linha do teclado
        INC R9                  ; incrementa o contador de linhas
        CMP R9, 4               ; verifica se já leu todas as linhas
        JNZ check_key           ; se não leu todas as linhas, verifica a próxima
        JMP exit_keyboard

    is_key_pressed:
        CALL movement_key       ; chama uma função para detetar se a tecla pressionada é uma tecla de movimento
        CALL ghost_cicle
        MOVB [R4], R3           ; ativa a linha para leitura do teclado
        MOVB R0, [R5]           ; lê a coluna do teclado
        AND R0, R7              ; aplica a máscara
        CMP R0, 0               ; verifica se a tecla foi libertada
        JNZ is_key_pressed      ; se não foi libertada, espera que seja

    exit_keyboard:
        POP R10
        POP R9
        POP R8                      
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R0
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
    PUSH R3                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, DELAY                 ; inicializa R5 com o valor de iterações para delay

    ; Key mappings for movement
    SHL R3, 4                   ; coloca linha nibble high
    OR R3, R0                   ; juntamos a coluna (nibble low)
    MOV R6, UP_LEFT_KEY         ; move para R6 o valor hexadecimal que representa o movimento UP/LEFT
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_up_left             ; se a tecla pressionada for UP/LEFT salta para move_up_left
    MOV R6, UP_KEY              ; move para R6 o valor hexadecimal que representa o movimento UP
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_up                  ; se a tecla pressionada for UP salta para move_up
    MOV R6, UP_RIGHT_KEY        ; move para R6 o valor hexadecimal que representa o movimento UP/RIGHT
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_up_right            ; se a tecla pressionada for UP/RIGHT salta para move_up_right
    MOV R6, LEFT_KEY            ; move para R6 o valor hexadecimal que representa o movimento LEFT
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_left                ; se a tecla pressionada for LEFT salta para move_left
    MOV R6, RIGHT_KEY           ; move para R6 o valor hexadecimal que representa o movimento RIGHT
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_right               ; se a tecla pressionada for RIGHT salta para move_right
    MOV R6, DOWN_LEFT_KEY       ; move para R6 o valor hexadecimal que representa o movimento DOWN/LEFT
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_down_left           ; se a tecla pressionada for DOWN/LEFT salta para move_down_left
    MOV R6, DOWN__KEY           ; move para R6 o valor hexadecimal que representa o movimento DOWN
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_down                ; se a tecla pressionada for DOWN salta para move_down
    MOV R6, DOWN_RIGHT_KEY      ; move para R6 o valor hexadecimal que representa o movimento DOWN_RIGHT
    CMP R3, R6                  ; compara a tecla pressionada como o valor em R6
    JZ move_down_right          ; se a tecla pressionada for DOWN salta para move_down_right
    JMP end_move                ; se a tecla pressionada não for nenhuma das teclas testadas acima então salta para end_move

move_up_left:
    MOV R4, DEF_OPEN_PAC_UP_LEFT    ; guarda em R4 o valor da tabela que define o pacman de boca aberta para cima e para a esquerda
    MOV R7, -1                      ; guarda em R7 o valor -1, R7 representa o movimento vertical ao mover para cima o objeto sutrai 1 à sua linha atual
    MOV R8, -1                      ; guarda em R8 o valor -1, R8 representa o movimento horizontal ao mover para a esquerda o objeto sutrai 1 à sua coluna atual
    JMP move                        ; salta para move para não alterar os valores de R4, R7 e R8

move_up:
    MOV R4, DEF_OPEN_PAC_UP         ; guarda em R4 o valor da tabela que define o pacman de boca aberta para cima
    MOV R7, -1                      ; guarda em R7 o valor -1
    MOV R8, 0                       ; guarda em R8 o valor 0. O movimento UP não requer translações horizontais
    JMP move                        ; salta para move

move_up_right:
    MOV R4, DEF_OPEN_PAC_UP_RIGHT   ; guarda em R4 o valor da tabela que define o pacman de boca aberta para cima e para a direita
    MOV R7, -1                      ; guarda em R7 o valor -1
    MOV R8, 1                       ; guarda em R8 o valor 1
    JMP move                        ; salta para move

move_left:
    MOV R4, DEF_OPEN_PAC_LEFT       ; guarda em R4 o valor da tabela que define o pacman de boca aberta para a esquerda
    MOV R7, 0                       ; guarda em R7 o valor 0. O movimento LEFT não requer translações verticais
    MOV R8, -1                      ; guarda em R8 o valor -1
    JMP move                        ; salta para move

move_right:
    MOV R4, DEF_OPEN_PAC_RIGHT      ; guarda em R4 o valor da tabela que define o pacman de boca aberta para a direita
    MOV R7, 0                       ; guarda em R7 o valor 0
    MOV R8, 1                       ; guarda em R8 o valor 1
    JMP move                        ; salta para move

move_down_left:
    MOV R4, DEF_OPEN_PAC_DOWN_LEFT  ; guarda em R4 o valor da tabela que define o pacman de boca aberta para baixo e para a esquerda
    MOV R7, 1                       ; guarda em R7 o valor 1
    MOV R8, -1                      ; guarda em R8 o valor -1
    JMP move                        ; salta para move

move_down:
    MOV R4, DEF_OPEN_PAC_DOWN       ; guarda em R4 o valor da tabela que define o pacman de boca aberta para baixo
    MOV R7, 1                       ; guarda em R7 o valor 1
    MOV R8, 0                       ; guarda em R8 o valor 0
    JMP move                        ; salta para move

move_down_right:
    MOV R4, DEF_OPEN_PAC_DOWN_RIGHT ; guarda em R4 o valor da tabela que define o pacman de boca aberta para baixo e para a direita
    MOV R7, 1                       ; guarda em R7 o valor 1 
    MOV R8, 1                       ; guarda em R8 o valor 1 

move:
    MOV R3, DEF_PACMAN              ; move para R3 a tabela que define o pacman de boca fechada
    CALL move_object                ; chama a função move_object
    MOV [PAC_LIN], R1
    MOV [PAC_COL], R2

end_move:
    POP R8                          ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    RET

; *****************************************************************************************************************************
; DELAY - Introduz um delay
; *****************************************************************************************************************************
delay:
    PUSH R0                     ; guarda o valor de R0
    MOV R0, DELAY               ; move para R0 o valor do DELAY (número grande)

delay_loop:
    DEC R0                      ; decrementa o valor de R0
    JNZ delay_loop              ; repete o loop até R0 chegar a 0
    POP R0                      ; recupera o valor de R0
    RET


; *****************************************************************************************************************************
; ROT_INT_0 - Rotina de atendimento da interrupção 0
;			  Faz os fantasmas dançarem
; *****************************************************************************************************************************
rot_int_0:
    PUSH R1
    MOV R1, 1
    MOV [CHECK_IE], R1
    POP R1
    RFE

ghost_cicle:
    PUSH R0
    PUSH R1
    MOV R1, 1
    MOV R0, [CHECK_IE]
    CMP R0, 1
    JNZ exit_ghost_cicle

    MOV R0, 0
    MOV [CHECK_IE], R0
    CALL ghost1

    exit_ghost_cicle:
        POP R1
        POP R0
        RET

ghost1:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R1, [GHOST1_LIN]
    MOV R2, [GHOST1_COL]
    MOV R5, [PAC_LIN]
    MOV R6, [PAC_COL]
    CALL choose_ghost_direction ; chama a função que escolhe em que direção o fantasma se mexe
    MOV R3, DEF_GHOST           ; move o endereço da tabela que define a versão animada do fantasma para R3
    MOV R4, R3                  ; move o endereco da tabela que define o fantasma para R4
    CALL move_object		    ; chama a função que move o fantasma
    MOV [GHOST1_LIN], R1
    MOV [GHOST1_COL], R2

    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET				        ; Return From Exception

; *****************************************************************************************************************************
; CHOOSE_GHOST_DIRECTION - Rotina para determinar em que direção o fantasma se deve mover para se aproximar do pacman.
;
; Argumentos:   R1 - linha em que se encontra o fantasma
;               R2 - coluna em que se encontra o fantasma
;               R5 - linha em que se encontra o pacman
;               R6 - coluna em que se encontra o pacman
;
; Retorna:      R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
; *****************************************************************************************************************************
choose_ghost_direction:
    CMP R5, R1
    JLT up
    JGT down
    MOV R7, 0
    JMP check_horizontal
        
    up:
    MOV R7, -1
    JMP check_horizontal
    
    down:
    MOV R7, 1
    JMP check_horizontal

    check_horizontal:
        CMP R6, R2
        JLT left
        JGT right
        MOV R8, 0
        JMP leave_ghost_direction

        left:
        MOV R8, -1
        JMP leave_ghost_direction

        right:
        MOV R8, 1
        JMP leave_ghost_direction

    leave_ghost_direction:
        RET