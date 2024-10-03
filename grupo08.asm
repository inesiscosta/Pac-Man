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
DELAY                  EQU 05000H      ; numero de ciclos de delay para atrasar a animação do movimento
DISPLAYS               EQU 0A000H      ; endereço dos displays de 7 segmentos (periférico POUT-1)
MAX_GHOSTS             EQU 4           ; número máximo de fantasmas premitidos em jogo (0-4)
INITAL_NUM_GHOSTS      EQU 0           ; número de fantasmas inicalmente em jogo
NUM_COL                EQU 64          ; número decimal do número de colunas no ecrã
MIDDLE_LIN             EQU 10H         ; número hexadecimal para a linha a meio do ecrã
MIDDLE_COL             EQU 20H         ; número hexadecimal para a coluna a meio do ecrã
GHOST_RYTHM            EQU 6            ; mude o valor para mudar a velocidade de evolução dos fantasmas ((clock * GHOST_RYTHM) / 1000 = evolução fantasmas em segundos, clock = 500 ms)

; MediaCenter
DEF_LINE    		   EQU 600AH       ; endereço do comando para definir a linha
DEF_COLUMN   	       EQU 600CH       ; endereço do comando para definir a coluna
DEF_COLOR              EQU 6014H       ; endereço do comando para definir a cor a usar
DEF_PIXEL    	       EQU 6012H       ; endereço do comando para escrever um pixel
DEF_8_PIXELS           EQU 601CH       ; endereço do comando para escrever em 8 pixels
GET_COLOR              EQU 6010H       ; endereço do comando para obter a cor de um pixel
DELETE_WARNING     	   EQU 6040H       ; endereço do comando para apagar o aviso de nenhum cenário selecionado
DELETE_SCREEN	 	   EQU 6002H       ; endereço do comando para apagar todos os pixels já desenhados
SELECT_BACKGROUND_IMG  EQU 6042H       ; endereço do comando para selecionar uma imagem de fundo
SELECT_FRONT_IMG       EQU 6046H       ; endereço do comando para selecionar uma imagem frontal
DELETE_FRONT_IMG       EQU 6044H       ; endereço do comando para apagar o cenário frontal
SELECT_MEDIA           EQU 6048H       ; endereco do comando para selecionar um som/video para os comandos seguintes
PLAY_MEDIA             EQU 605AH       ; endereço do comando para tocar som
LOOP_MEDIA             EQU 605CH       ; endereço do comando para reproduzir o som ou video especificado em ciclo
PAUSE_SOUND            EQU 605EH       ; endereço do comando para pausar a reprodução do som ou video especificado
PAUSE_ALL_SOUND        EQU 6062H       ; endereço do comando para pausar a reprodução de todos os sons ou videos
RESUME_SOUND           EQU 6006H       ; endereço do comando para resumir a reprodução do som ou video especificado
STOP_MEDIA             EQU 6066H       ; endereço do comando para terminar a reprodução do som ou video especificado
STOP_ALL_MEDIA         EQU 6068H       ; endereço do comando para terminar a reprodução de todos os sons/videos

; Imagens
START_MENU_IMG         EQU 0           ; imagem para o ecrã inicial
GAME_BACKGROUND        EQU 1           ; imagem para o fundo do jogo
PAUSED_IMG             EQU 2           ; imagem frontal para quando o jogo está em pausa
GAME_OVER_IMG          EQU 3           ; imagem frontal para quando o jogador perde
TIME_LIMIT_IMG         EQU 4           ; imagem frontal para quando o jogador perde por tempo
VICTORY_IMG            EQU 5           ; imagem de fundo para vitória

; Sons / GIFs
PACMAN_THEME           EQU 0           ; música do jogo
PACMAN_CHOMP           EQU 1           ; som do pacman a movimentar-se
GHOSTS_GIF             EQU 2           ; GIF GAME OVER
GAME_OVER_SOUND        EQU 3           ; som game_over
WIN_SOUND              EQU 4           ; som vitória
EAT_CANDY              EQU 5           ; som de comer candy

; Controlos
UP_LEFT_KEY            EQU 11H         ; key 0 for moving up and left
UP_KEY                 EQU 12H         ; key 1 for moving up
UP_RIGHT_KEY           EQU 14H         ; key 2 for moving up and right
LEFT_KEY               EQU 21H         ; key 4 for moving left
RIGHT_KEY              EQU 24H         ; key 6 for moving right
DOWN_LEFT_KEY          EQU 41H         ; key 8 for moving down and left
DOWN__KEY              EQU 42H         ; key 9 for moving down
DOWN_RIGHT_KEY         EQU 44H         ; key A for moving down and right
START_KEY              EQU 81H         ; key C for starting the game
PAUSE_KEY              EQU 82H         ; key D for pausing and resuming/unpausing the game
END_GAME_KEY           EQU 84H         ; key to terminate the game

; Teclado
KEY_LIN                EQU 0C000H      ; endereço das linhas do teclado (periférico POUT-2)
KEY_COL                EQU 0E000H      ; endereço das colunas do teclado (periférico PIN)
KEY_START_LIN          EQU 1           ; inicialização da linha

; Pontuação
INITIAL_POINTS         EQU 00H         ; valor inicial da pontuação
UPPER_LIMIT            EQU 999H        ; valor máximo do contador de pontos
LOWER_LIMIT            EQU 00H         ; valor mínimo do contador de pontos  
MASK_LSD               EQU 0FH         ; máscara para isolar os 4 btis de menor peso para ver o digito menos significativo
MASK_TENS              EQU 0F0H        ; máscara para isolar os bits que representam as dezenas
INC_HUNDREDS           EQU 96          ; número para incrementar para representar as centenas no contador
INC_TENS               EQU 6           ; número para incrementar para representar as dezenas no contador

; Posições Iniciais
PAC_START_LIN          EQU 13          ; linha inicial do pacman (a meio do ecrã)
PAC_START_COL          EQU 30          ; coluna inicial do pacman (a meio do ecrã)
GHOST_START_LIN        EQU 14          ; linha inicial do fantasma (a meio do ecrã)
GHOST0_START_COL       EQU 0           ; coluna inicial do fantasma 0 (encostado ao limite esquerdo)
GHOST1_START_COL       EQU 58          ; coluna inicial do fantasma 1 (encostado ao limite esquerdo)
GHOST2_START_COL       EQU 0           ; coluna inicial do fantasma 2 (encostado ao limite esquerdo)
GHOST3_START_COL       EQU 58          ; coluna inicial do fantasma 3 (encostado ao limite esquerdo)
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

; Cores
YLW                    EQU 0FFF0H	   ; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)
RED                    EQU 0FF00H      ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
CYAN                   EQU 0F4FFH      ; cor do pixel: ciano em ARGB (opaco, vermelho a 4, verde e azul no máximo)
BLUE                   EQU 0F00FH	   ; cor do pixel: azul em ARGB (opaco, vermelho e verde a 0, azul no máximo)
PINK                   EQU 0FFAFH      ; cor do pixel: rosa em ARGB (opaco e vermelho no máximo, verde a 10 e azul no máximo)
ORNG                   EQU 0FFA0H      ; cor do pixel: laranja em ARGB (opaco e vermelho no máximo, verde a 10 e azul a 0)
L_RED                  EQU 0FF55H      ; cor do pixel: vermelho mais claro em ARGB (opaco e vermelho no máximo, ver e azul a 5)
L_BLUE                 EQU 0F0FFH      ; cor do pixel: azul mais claro em ARGB (opaco, vermelho a 0, ver e azul no máximo)

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
BOX_WIDTH	           EQU 12		   ; largura da caixa

; Estados de jogo
GAME_STATE             EQU 3FEAH       ; endereço da memoria onde se encontra o estado atual do jogo
INITIAL                EQU 0           ; indica que o jogo ainda não foi iniciado
PLAYING                EQU 1           ; indica que o jogo está a decorrer
PAUSED                 EQU 2           ; indica que o jogo se encontra em pausa
WON                    EQU 3           ; indica que o jogo terminou e o jogador ganhou
GAME_OVER              EQU 4           ; indica que o jogo terminou e o jogador perdeu

; *****************************************************************************************************************************
; * Dados 
; *****************************************************************************************************************************
    PLACE 1000H

pilha:
    STACK 200H          ; espaço reservado para a pilha (200H bytes, pois são 100H words)

SP_initial:             ; este é o endereço (1200H) com que o SP deve ser inicializado.
                        ; O 1.º end. de retorno será armazenado em 11FEH (1200H-2)

tab:
    WORD int_rot_0      ; rotina de interrupção 0
    WORD int_rot_1      ; rotina de interrupção 1
    WORD int_rot_2      ; rotina de interrupção 2
    WORD int_rot_3      ; rotina de interrupção 3

int_0: WORD 0           ; se 1, indica que a interrupção 0 ocorreu
int_1: WORD 0           ; se 1, indica que a interrupção 1 ocorreu
int_2: WORD 0           ; se 1, indica que a interrupção 2 ocorreu
int_3: WORD 0           ; se 1, indica que a interrupção 3 ocorreu

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

DEF_L_BLUE_GHOST:   ; tabela que define o fantasma azul (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, L_BLUE, L_BLUE, 0                    ;  ## 
    WORD        L_BLUE, L_BLUE, L_BLUE, L_BLUE          ; ####
    WORD        L_BLUE, L_BLUE, L_BLUE, L_BLUE          ; ####
    WORD        L_BLUE, 0, 0, L_BLUE                    ; #  #

DEF_L_RED_GHOST:   ; tabela que define o fantasma vermelho (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, L_RED, L_RED, 0                      ;  ## 
    WORD        L_RED, L_RED, L_RED, L_RED              ; ####
    WORD        L_RED, L_RED, L_RED, L_RED              ; ####
    WORD        L_RED, 0, 0, L_RED                      ; #  #

DEF_ORNG_GHOST:   ; tabela que define o fantasma laranja (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, ORNG, ORNG, 0                        ;  ## 
    WORD        ORNG, ORNG, ORNG, ORNG                  ; ####
    WORD        ORNG, ORNG, ORNG, ORNG                  ; ####
    WORD        ORNG, 0, 0, ORNG                        ; #  #

DEF_PINK_GHOST:   ; tabela que define o fantasma rosa (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, PINK, PINK, 0                        ;  ## 
    WORD        PINK, PINK, PINK, PINK                  ; ####
    WORD        PINK, PINK, PINK, PINK                  ; ####
    WORD        PINK, 0, 0, PINK                        ; #  #

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

DEF_CANDY_POSITIONS:    ; tabela que define as posições dos doçes
    WORD        CANDY1_LIN              ; linha do rebuçado 1
    WORD        CANDY1_COL              ; coluna do rebuçado 1
    WORD        CANDY2_LIN              ; linha do rebuçado 2
    WORD        CANDY2_COL              ; coluna do rebuçado 2
    WORD        CANDY3_LIN              ; linha do rebuçado 3
    WORD        CANDY3_COL              ; coluna do rebuçado 3
    WORD        CANDY4_LIN              ; linha do rebuçado 4
    WORD        CANDY4_COL              ; coluna do rebuçado 4

REMAINING_CANDIES:    WORD 4            ; guarda o número de rebuçados em jogo
NUM_GHOSTS:           WORD 0            ; guarda o número de fantasmas em jogo
SCORE:                WORD 0            ; guarda a pontução do jogo
COUNT_INT_0:          WORD 0            ; guarda o número de vezes que lidámos com a count_int_0 (resets a 10)
COUNT_INT_1:          WORD 0            ; guarda o número de vezes que lidámos com a count_int_1 (resets a 5)
COUNT_INT_2:          WORD 0            ; guarda o número de vezes que lidámos com a count_int_2 (resets a 5)
EXPLOSION_EVENT:      WORD 0            ; indica se a explosão já ocorreu, 0 se não, 1 se sim

; Posições Atuais
PAC_LIN:        WORD PAC_START_LIN      ; guarda a linha atual do pacman, inicializada a PAC_START_LIN
PAC_COL:        WORD PAC_START_COL      ; guarda a coluna atual do pacman, inicializada a PAC_START_COL

GHOST_POS:
    WORD GHOST_START_LIN                ; guarda a linha atual do fantasma 0, inicializada a GHOST_START_LIN
    WORD GHOST0_START_COL               ; guarda a coluna atual do fantasma 0, inicializada a GHOST1_START_COL
    WORD DEF_L_BLUE_GHOST               ; guarda a tabela do fantasma 0 (Light Blue Ghost)
    WORD GHOST_START_LIN                ; guarda a linha atual do fantasma 1, inicializada a GHOST_START_LIN
    WORD GHOST1_START_COL               ; guarda a coluna atual do fantasma 1, inicializada a GHOST2_START_COL
    WORD DEF_L_RED_GHOST                ; guarda a tabela do fantasma 1 (Light Red Ghost)
    WORD GHOST_START_LIN                ; guarda a linha atual do fantasma 2, inicializada a GHOST_START_LIN
    WORD GHOST2_START_COL               ; guarda a coluna atual do fantasma 2, inicializada a GHOST3_START_COL
    WORD DEF_ORNG_GHOST                 ; guarda a tabela do fantasma 2 (Orange Ghost)
    WORD GHOST_START_LIN                ; guarda a linha atual do fantasma 3, inicializada a GHOST_START_LIN
    WORD GHOST3_START_COL               ; guarda a coluna atual do fantasma 3, inicializada a GHOST4_START_COL
    WORD DEF_PINK_GHOST                 ; guarda a tabela do fantasma 3 (Pink Ghost)

ALIVE_GHOSTS:
    WORD 0                              ; guarda 0 ou 1 para indicar se o fantasma 0 está vivo ou morto respetivamente, inicializado a 0
    WORD 0                              ; guarda 0 ou 1 para indicar se o fantasma 1 está vivo ou morto respetivamente, inicializado a 0
    WORD 0                              ; guarda 0 ou 1 para indicar se o fantasma 2 está vivo ou morto respetivamente, inicializado a 0
    WORD 0                              ; guarda 0 ou 1 para indicar se o fantasma 3 está vivo ou morto respetivamente, inicializado a 0

; *****************************************************************************************************************************
; * Código
; *****************************************************************************************************************************
    PLACE 0
start:
    MOV SP, SP_initial
    MOV BTE, tab                        ; inicializar a tabela de exceções
    EI0                                 ; ativa a interrupção 0
    EI1                                 ; ativa a interrupção 1
    EI2                                 ; ativa a interrupção 2
    EI3                                 ; ativa a interrupção 3
    MOV R0, GHOSTS_GIF                  ; guarda em R0 o nº do GIF ghosts
    MOV [SELECT_MEDIA], R0              ; seleciona o GIF ghosts para os comandos seguintes
    MOV [STOP_MEDIA], R0                ; para de reproduzir o GIF ghosts, (o valor de R0 não é relevante)
    MOV [STOP_ALL_MEDIA], R0            ; para de reproduzir todos os sons/videos (o valor de R0 não é relevante)
    MOV [DELETE_FRONT_IMG], R0          ; apaga a imagem frontal (o valor de R0 não é relevante)
    MOV [DELETE_WARNING], R0	        ; apaga o aviso de nenhum cenário selecionado (o valor de R0 não é relevante)
    MOV [DELETE_SCREEN], R0	            ; apaga todos os pixels já desenhados (o valor de R0 não é relevante)
    MOV R0, INITIAL_POINTS              ; guarda em R0 o valor da pontuação inicial (000)
    MOV [DISPLAYS], R0                  ; move para os displays os valores inciais da pontuação (000)
    MOV [SCORE], R0                     ; move para a memória o valor inicial de R0
    MOV R0, INITAL_NUM_GHOSTS           ; guarda o número de fantasmas inicialmente em jogo (0 - nenhum)
    MOV [NUM_GHOSTS], R0                ; atualiza o número de ghosts em jogo para 0
    MOV R0, START_MENU_IMG              ; move para R0 o nº do cenário de fundo 
    MOV [SELECT_BACKGROUND_IMG], R0     ; seleciona o cenário de fundo       
    MOV R0, PACMAN_THEME                ; guarda o nº do som da música do pacman
    MOV [LOOP_MEDIA], R0                ; reproduz em loop a música do pacman
    MOV R0, GAME_STATE                  ; move para R0 o endereço na memória que contém o estado atual do jogo
    MOV R1, INITIAL                     ; move para R1 o nº que representa o estado inicial
    MOV [R0], R1                        ; guarda na memória o estado_autal do jogo como INITIAL
    MOV R11, 9                          ; move para R11 (irá guardar a ultima tecla pressionada) o valor 9 pois "9" nunca representará uma tecla

waiting_press_start:
    CALL keyboard                       ; chama a função do teclado para indentificar a tecla pressionada (valor guardado em R0)
    CALL game_state_key                 ; chama uma função para detetar se a tecla pressionada é uma tecla que altera o estado do jogo e executa a ação associada
    MOV R1, [GAME_STATE]                ; move para R1 o estado atual do jogo
    CMP R1, PLAYING                     ; compara o estado atual do jogo com o estado PLAYING
    JNZ waiting_press_start             ; repete o ciclo enquanto o jogo não estiver PLAYING

CALL draw_center_box                    ; quando o jogo começa (estado = PLAYING) chama a função draw_center_box para desenhar a caixa central
CALL draw_limit_box                     ; chama a função para desenhar os limites do jogo
CALL draw_candy                         ; chama a função para desenhar os rebuçados nos 4 cantos
spawn_pacman:
    MOV R2, PAC_LIN                     ; endereço da linha atual do pacman
    MOV R1, PAC_START_LIN               ; valor da linha inicial do pacman
    MOV [R2], R1                        ; guarda na RAM a linha atual do pacman (de momento a inicial)
    MOV R3, PAC_COL                     ; endereço da coluna inicial do pacman
    MOV R2, PAC_START_COL               ; valor da coluna inicial do pacman
    MOV [R3], R2                        ; guarda na RAM a coluna atual do pacman (de momento a inicial)
    MOV R4, DEF_OPEN_PAC_RIGHT          ; endereço da tabela que define o pacman
    CALL draw_object                    ; chama a função para desenhar um objeto neste caso, o pacman
EI                                      ; ativa interrupções

main: ; ciclo principal
    CALL check_explosion                ; chama a função que apaga a explosão passado 1.5 segundos
    CALL keyboard                       ; chama a função do teclado para indentificar a tecla pressionada (valor guardado em R0)
    CALL game_state_key                 ; chama uma função para detetar se a tecla pressionada é uma tecla que altera o estado do jogo e executa a ação associada
    CALL movement_key                   ; chama uma função para detetar se a tecla pressionada é uma tecla de movimento e executar a ação associada
    CALL spawn_ghosts                   ; chama a função para libertar fantasmas
    CALL ghost_cycle                    ; chama a função que anima os fantasmas
    CALL score_cycle                    ; chama a função que incrementa a pontuação
    MOV R11, R0                         ; guarda a ultima tecla premida em R11
    JMP main

; *****************************************************************************************************************************
; GET_COLOR_PIXEL - Vê a cor do pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;
; Retorna:      R3 - cor do pixel (em formato ARGB de 16 bits)
; *****************************************************************************************************************************
get_color_pixel:
    MOV [DEF_LINE], R1          ; seleciona a linha
    MOV [DEF_COLUMN], R2        ; seleciona a coluna
    MOV R3, [GET_COLOR]         ; identifica a cor do pixel na linha e coluna já selecionadas
    RET 

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

; *****************************************************************************************************************************
; DELETE_OBJECT - Apaga um objeto na linha e coluna indicadas
;			      com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o objeto
;
; *****************************************************************************************************************************
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
; MOVE_OBJECT - Incrementa ou decrementa o contador com base na tecla pressionada e atualiza o display
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - tabela que define o objeto
;               R4 - tabela que define a animação do objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna:      R1 - novo valor da linha, após o movimento
; *****************************************************************************************************************************
move_object:
    PUSH R0                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R6
    PUSH R9

    CALL choose_ghost_action    ; chama a função que verifica que tipo de movimento o objeto está a tentar ultrapassar algum limite com este movimento
    CMP R0, 0                   ; compara o retorno da função (R0) com o valor 0
    JZ end_movement             ; se a função retornar 0, saltamos para end_movement pois o movimento é proíbido
    CMP R0, 2   
    JZ ghost_pacman
    CALL delete_object          ; se não, apaga o objeto
    ADD R1, R7                  ; obtém nova linha
    ADD R2, R8                  ; obtém nova coluna
    CALL draw_object            ; desenha versão animada do objeto
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento
    CALL delete_object          ; apaga a versão animada do objeto
    MOV R4, R3                  ; guarda em R4 a tabela de define o objeto (versão não animada)
    CALL draw_object            ; desenha versão final do objeto
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento 
    JMP end_movement

ghost_pacman:
    CALL explosion

end_movement:
    POP R9                      ; recupera os valores anteriores dos registos modificados
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; DRAW_CENTER_BOX - Desenha a caixa central onde nasce o pacman.
; *****************************************************************************************************************************
draw_center_box:
    PUSH R1                            ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R1, BOX_LIN                     ; linha inicial da caixa
    MOV R2, BOX_COL                     ; coluna inicial da caixa
    MOV R3, BLUE                        ; guarda cor pixel
    MOV R4, BOX_HEIGHT                  ; altura da caixa
    MOV R7, R4                          ; contador linhas por desenhar
    SUB R4, 1                           ; subtrai um à altura da caixa
    MOV R5, BOX_WIDTH                   ; largura da caixa
    SUB R5, 1                           ; subtrai um à largura da caixa

draw_vertical_lines:
    CALL write_pixel                    ; chama a função para pintar o pixel
    ADD R2, R5                          ; addiciona o número de pixels para saltar do limite esquerdo da caixa para o limite direito (largura - 1) 
    CALL write_pixel                    ; chama a função para pintar o pixel
    MOV R2, BOX_COL                     ; retorna para o limite esquerdo
    ADD R1, 1                           ; avança para a proxima linha
    SUB R7, 1                           ; decrementa o contador das linhas por desenhar
    JNZ draw_vertical_lines             ; repete o ciclo até não faltar nenhuna linha
    MOV R1, BOX_LIN                     ; recupera a linha inicial da caixa
    MOV R2, BOX_COL                     ; recupera a coluna inicial da caixa
    MOV R7, 2                           ; guarda o valor 2 em R7 (contador do número de pixeis antes da abertura na caixa)
    MOV R8, FALSE                       ; flag para saber se já passámos a quebra da caixa

draw_horizontal_lines:
    ADD R2, 1                           ; avança um pixel para a direita
    CALL write_pixel                    ; chama a função para pintar o pixel
    ADD R1, R4                          ; adiciona à linha inical a altura da caixa - 1
    CALL write_pixel                    ; chama a função para pintar o pixel
    MOV R1, BOX_LIN                     ; subtraí de volta a altura da caixa voltando à linha inicial
    SUB R7, 1                           ; decrementa o contador de pixels que faltam desenhar antes da quebra
    JNZ draw_horizontal_lines           ; repete o ciclo até desenhar todos os pixels antes da quebra
    CMP R8, 1                           ; verifica se já passámos a quebra
    JZ end_draw_center_box              ; se sim saltamos para o fim da rotina
    ADD R2, 6                           ; se não adiciona 6 ao valor da coluna atual assim saltando a quebra
    MOV R7, 2                           ; guarda o valor 2 em R7 (contador do número de pixeis depois da abertura na caixa)
    MOV R8, TRUE                        ; atualizamos a flag
    JMP draw_horizontal_lines           ; saltamos para draw_horizontal_lines para desenhar o lado direito da caixa

end_draw_center_box:
    POP R8                              ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; DRAW_LIMIT_BOX - Desenha os limites do jogo
;
; *****************************************************************************************************************************
draw_limit_box:
    PUSH R1                             ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7

    MOV R1, 0                           ; guarda em R1 a linha que vamos começar a desenhar (limite superior do jogo)
    MOV R2, 0                           ; guarda em R0 a coluna que vamos começar a desenhar
    MOV R3, BLUE                        ; guarda em R3 a cor que vamos usar (azul)
    MOV R4, 00FFH                       ; guarda em R4 a linha superior que vamos desenhar (limite superior do jogo)
    MOV R5, 001FH                       ; guarda em R5 a linha inferior que vamos desenhar (limite inferior do jogo)
    MOV R6, 08H                         ; guarda em R6 o valor que temos de incrementar no valor da coluna cada vez que pintamos (já que estamos a pintar 8 de cada vez)
    MOV R7, 8                           ; guarda em R7 o contador que conta as vezes que temos de pintar (8 * 8 = 64 = nº pixels horizontais)
    MOV [DEF_LINE], R1                  ; seleciona a linha superior
    MOV [DEF_COLUMN], R2                ; seleciona a coluna zero
    MOV [DEF_COLOR], R3                 ; seleciona a cor (azul) para pintar o pixel

    next_horizontal_limit:              ; começa o ciclo de desenhar os limites horizontais
        MOV [DEF_8_PIXELS], R4          ; pinta os próximos 8 pixeis com a cor selecionada
        ADD R1, R5                      ; passamos para o limite inferior
        MOV [DEF_LINE], R1              ; seleciona a linha inferior (limite limite em baixo)
        MOV [DEF_8_PIXELS], R4          ; pinta os próximos 8 pixeis com a cor selecionada
        SUB R1, R5                      ; voltamos para o limite superior
        MOV [DEF_LINE], R1              ; seleciona de novo a linha superior (limite em cima)
        SUB R7, 1                       ; decrementa o contador
        JZ draw_vertical_limit          ; verifica se já fizemos as vezes necessários, se estiver saltamos para a função que desenha os limites verticais
        ADD R2, R6                      ; se não seleciona a coluna a seguir aos 8 pixeis pintados
        MOV [DEF_COLUMN], R2            ; define essa coluna 
        JMP next_horizontal_limit       ; volta ao início do ciclo

    draw_vertical_limit:                ; começa o ciclo de desenhar os limites verticais
        MOV R1, 1                       ; guarda em R1 a linha que vamos começar a desenhar
        MOV R2, 0                       ; guarda em R2 a coluna que vamos começar a desenhar (limite mais à esquerda do jogo)
        MOV R4, 003FH                   ; guarda em R4 a coluna mais à direita que vamos desenhar (limite mais à direita)
        MOV R5, 9                       ; guarda em R5 as vezes que vamos pintar em cada ciclo
        MOV R6, 003DH                   ; guarda em R6 o valor da coluna que temos desenhar o spawn dos fantasmas à direita
        mov R7, 0020H                   ; guarda em R7 a última linha que temos de desenhar + 1

        next_vertical_limit:
            CALL write_pixel            ; chama a função que pintar o pixel
            ADD R2, R4                  ; seleciona a coluna mais à direita
            CALL write_pixel            ; chama a função que pintar o pixel
            SUB R2, R4                  ; seleciona a coluna mais à esquerda
            ADD R1, 1                   ; desce uma linha
            CMP R1, R7                  ; vê se já pintamos a última linha
            JZ exit_draw_limit_box      ; se sim, saimos da função
            CMP R1, R5                  ; vemos se chegamos à linha que temos de desenhar os spawns dos fantasmas
            JNZ next_vertical_limit     ; se não chegamos, continuamos a desenhar
            CALL draw_ghost_spawns      ; desenhamos a primeira parte do spawn dos fantasmas (esquerda cima)
            ADD R2, R6                  ; seleciona a coluna que começa a segunda parte do spawn
            SUB R1, 2                   ; seleciona a linha que começa a segunda parte do spawn
            CALL draw_ghost_spawns      ; desenhamos a segunda parte do spawn dos fantasmas (direita cima)
            SUB R2, R6                  ; seleciona a coluna que começa a segunda parte do spawn
            ADD R1, 7H                  ; seleciona a linha que começa a segunda parte do spawn
            CALL draw_ghost_spawns      ; desenhamos a terceira parte do spawn dos fantasmas (direita baixo)
            ADD R2, R6                  ; seleciona a coluna que começa a segunda parte do spawn
            SUB R1, 2                   ; seleciona a linha que começa a segunda parte do spawn
            CALL draw_ghost_spawns      ; desenhamos a última parte do spawn dos fantasmas (esquerda baixo)
            SUB R2, R6                  ; voltamos para a primeira coluna para continuar a desenhar os limites verticais
            JMP next_vertical_limit     ; voltamos a desenhar o resto dos pixeis dos limites verticais
        
exit_draw_limit_box:
    POP R7                              ; recupera os valores anteriores dos registos modificados
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; DRAW_GHOST_SPAWNS - Desenha os spawns dos fantasmas
;
; *****************************************************************************************************************************
draw_ghost_spawns:
    PUSH R2                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R3
    PUSH R4
    
    MOV R4, R2                  ; copia o valor de R2 para R4 para poder ser usada
    CALL write_pixel            ; chama a função para escrever pixel
    ADD R2, 1                   ; avança para a próxima coluna
    CALL write_pixel            ; chama a função para escrever pixel
    ADD R2, 1                   ; avança para a próxima coluna
    CALL write_pixel            ; chama a função para escrever pixel
    ADD R1, 1                   ; avança para a próxima linha
    CMP R4, 0                   ; verifica se o valor de R4 é 0
    JZ left_ghost_spawns        ; se 0 salta para left_ghost_spawns
    SUB R2, 2                   ; anda duas colunas para trás
    CALL write_pixel            ; chama a função para escrever pixel
    ADD R1, 1                   ; avança para a próxima linha
    JMP jump_left_spawns        ; salta para jump_left_spawns
    
    left_ghost_spawns:
        CALL write_pixel        ; chama a função para escrever pixel
        ADD R1, 1               ; avança para a próxima linha
        SUB R2, 2               ; anda duas colunas para trás

    jump_left_spawns:
        CALL write_pixel        ; chama a função para desenhar o pixel
        ADD R2, 1               ; anda uma coluna para trás
        CALL write_pixel        ; chama a função para desenhar o pixel
        ADD R2, 1               ; anda outra coluna para trás
        CALL write_pixel        ; chama a função para desenhar o pixel
        
        POP R4                  ; recupera os valores anteriores dos registos modificados
        POP R3
        POP R2
        RET

; *****************************************************************************************************************************
; DRAW_CANDY - Desenha os rebuçados nas poições definas na tabela DEF_CANDY_POSITIONS
;
; *****************************************************************************************************************************
draw_candy:
    PUSH R0                                 ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    MOV R0, DEF_CANDY_POSITIONS             ; guarda em R0 o endereço da tabela que contêm as posições (linha, coluna) dos 4 rebuçados
    MOV R4, DEF_CANDY                       ; guarda em R4 a tabela que define cada rebuçado
    MOV R3, 4                               ; R3 indica o nº de rebuçados que falta desenhar, inicalmente todos os 4
    draw_each_candy:
        MOV R1, [R0]                        ; obtem a linha do rebuçado que vai desenhar
        ADD R0, 2                           ; avança para o endereço da coluna do rebuçado
        MOV R2, [R0]                        ; obtem a coluna do rebuçado que vai desenhar
        ADD R0, 2                           ; avança para o endereço da lina do rebuçado
        CALL draw_object                    ; chama a função para desenhar o objeto (neste caso o rebuçado)
        SUB R3, 1                           ; decrementa o número de rebuçados que faltam desenhar
        JNZ draw_each_candy                 ; se ainda faltar desenhar rebuçados repete o ciclo draw_each_candy
    
    POP R4                                  ; recupera os valores anteriores dos registos modificados
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; *****************************************************************************************************************************
; CHOOSE_OBJECT_ACTION - Verifica qual ação que o objeto irá realizar
; Argumentos:   R1 - linha em que o objeto se encontra
;               R2 - coluna em que o objeto se encontra
;               R4 - tabela que define o objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: R0 - Retorna o valor da ação que o objeto terá:
;               0 - movimento proíbido
;               1 - pode mover
;               2 - pode mover e encontra um candy
;               3 - pode mover e encontra um fantasma
;
; *****************************************************************************************************************************
choose_object_action:
    PUSH R1                             ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10

    MOV R5, [R4]                        ; obtém a altura objeto
    SUB R5, 1                           ; subtrai 1 à altura do objeto
    MOV R6, [R4+2]                      ; obtém a largura objeto     
    SUB R6, 1                           ; subtrai 1 à largura do objeto
    ADD R1, R7                          ; soma à linha o valor do eventual movimento
    ADD R2, R8                          ; soma à coluna o valor do eventual movimento
    MOV R0, 1                           ; guarda o valor 1 em R0 (por default assumimos que se pode mover)
    MOV R10, BLUE                       ; guarda em R10 a cor BLUE (cor dos limites)

check_horizontal_pixels:
    MOV R9, [R4+2]                      ; guarda em R9 a altura do objeto
    next_horizontal_pixels:
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ over_limit                   ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CALL identify_action            ; se não, chama a função que atribui os códigos de tipo de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
        ADD R1, R5                      ; adiciona a altura - 1 à linha corrente
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ over_limit                   ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CALL identify_action            ; se não, chama a função que atribui os códigos de tipo de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
        SUB R1, R5                      ; recupera a linha inicial
        SUB R9, 1                       ; decrementa R9
        JZ check_vertical_pixels        ; se já chegou a 0 salta para check_vertical_pixels
        ADD R2, 1                       ; se não, passa para a próxima linha
        JMP next_horizontal_pixels      ; repete o ciclo

check_vertical_pixels:
    MOV R9, [R4]                        ; guarda em R9 a largura do objeto
    next_vertical_pixels:
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ over_limit                   ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CALL identify_action            ; se não, chama a função que atribui os códigos de tipo de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
        SUB R2, R6                      ; subtrai à coluna a largura do objeto - 1
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ over_limit                   ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CALL identify_action            ; se não, chama a função que atribui os códigos de tipo de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
        ADD R2, R6                      ; recupera o valor de R6 antigo 
        SUB R9, 1                       ; decrementa o contador da largura
        JZ not_over_limit               ; se já chegou a 0 salta para not_over_limit
        ADD R1, 1                       ; se não, passa para a próxima coluna
        JMP next_vertical_pixels        ; repete o ciclo

over_limit:
    MOV R0, 0                           ; como o objeto está a tentar mover-se para cima de um limite guardamos 0 em R0 para indicar que o movimento é proíbido
    JMP exit_choose_object_action       ; salta para o fim da rotina

not_over_limit:
    CMP R0, 1                           ; compara o código com 1
    JGT exit_choose_object_action       ; se o código for maior que 1 salta para o fim da rotina
    MOV R0, 1                           ; guarda em R0 o valor 1 (código que indica que o pacman se pode movimentar e não vai collidir com nada)
    JMP exit_choose_object_action       ; salta para o fim da rotina

exit_choose_object_action:
    POP R10                             ; recupera os valores anteriores dos registos modificados
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

;*****************************************************************************************************************************
; CHOOSE_GHOST_ACTION - Verifica qual ação que o objeto irá realizar
; Argumentos:	R1 - linha em que o objeto se encontra
;               R2 - coluna em que o objeto se encontra
;			    R4 - tabela que define o objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: R0 - Retorna o valor da ação que o objeto terá:
;               0 - movimento proíbido
;               1 - pode mover
;               2 - pode mover e encontra o pacman
;
; *****************************************************************************************************************************
choose_ghost_action:
    PUSH R1                             ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11

    MOV R5, [R4]                        ; obtém a altura objeto
    SUB R5, 1                           ; subtrai 1 à altura do objeto
    MOV R6, [R4+2]                      ; obtém a largura objeto     
    SUB R6, 1                           ; subtrai 1 à largura do objeto
    ADD R1, R7                          ; soma à linha o valor do eventual movimento
    ADD R2, R8                          ; soma à coluna o valor do eventual movimento
    MOV R0, 1                           ; guarda o valor 1 em R0
    MOV R10, BLUE                       ; guarda em R10 a cor BLUE (cor dos limites)
    MOV R11, YLW                        ; guarda em R11 a cor YLW  (cor do pacmans)

check_horizontal_ghost:
    MOV R9, [R4+2]                      ; guarda a largura do objeto em R9
    next_horizontal_ghost:
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ ghost_over_limit             ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CMP R3, R11
        JZ caught_pacman

        ADD R1, R5                      ; adiciona a altura - 1 à linha corrente
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ ghost_over_limit             ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CMP R3, R11
        JZ caught_pacman

        SUB R1, R5                      ; recupera a linha inicial
        SUB R9, 1                       ; decrementa por 1 a largura
        JZ check_vertical_ghost         ; se já chegou a 0 salta para check_vertical_pixels
        ADD R2, 1                       ; se não, passa para a próxima linha
        JMP next_horizontal_ghost       ; repete o ciclo

check_vertical_ghost:
    MOV R9, [R4]                        ; guarda em R9 a altura do objeto
    next_vertical_ghost:
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ ghost_over_limit             ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CMP R3, R11                     ; verifica se o pixel é amarelo
        JZ caught_pacman                ; se sim, salta para caught_pacman

        SUB R2, R6                      ; coluna mais à esquerda do objeto
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ ghost_over_limit             ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CMP R3, R11                     ; verifica se o pixel é amarelo
        JZ caught_pacman                ; se sim, salta para caught_pacman

        ADD R2, R6                      ; coluna mais à direita do objeto
        SUB R9, 1                       ; decrementa por 1 a altura
        JZ ghost_not_over_limit         ; se já chegou a 0 salta para not_over_limit
        ADD R1, 1                       ; se não, passa para a próxima coluna
        JMP next_vertical_ghost         ; repete o ciclo

caught_pacman:
    MOV R0, 2                           ; guarda em R0 o valor 1 (código que indica que o fantasma se encontrou o pacman)
    JMP exit_choose_ghost_action        ; salta para o fim da rotina

ghost_over_limit:
    MOV R0, 0                           ; como o objeto está a tentar mover-se para cima de um limite guardamos 0 em R0 para indicar que o movimento é proíbido
    JMP exit_choose_ghost_action        ; salta para o fim da rotina

ghost_not_over_limit:
    MOV R0, 1                           ; guarda em R0 o valor 1 (código que indica que o fantasma se pode movimentar e não vai collidir com nada)
    JMP exit_choose_ghost_action        ; salta para o fim da rotina

exit_choose_ghost_action:
    POP R11                             ; recupera os valores anteriores dos registos modificados
    POP R10                             
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

; *****************************************************************************************************************************
; IDENTIFY_ACTION - Identifica a ação do pacman
; Atribui os códigos indentificadores de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
; Argumentos:   R3 - cor do pixel
;
; Retorna:      R0 - código identificador de ação
;               0 - movimento proíbido
;               1 - pode mover
;               2 - pode mover e encontrou um rebuçado
;               3 - pode mover e encontrou um fantasma
;
; *****************************************************************************************************************************
identify_action:
    PUSH R1                         ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R1, L_BLUE                  ; guarda em R1 o valor hexa que define a cor utilizada para o pixels verdes
    MOV R2, L_RED                   ; guarda em R2 o valor hexa que define a cor utlizada para os pixels vermelhos
    MOV R4, ORNG                    ; guarda em R4 o valor hexa que define a cor utlizada para os pixels laranja
    MOV R5, PINK                    ; guarda em R5 o valor hexa que define a cor utlizada para os pixels rosa
    MOV R6, RED                     ; guarda em R6 o valor hexa que define a cor utlizada para os pixels vermelhos rebuçado
    CMP R0, 3                       ; verifica se já apanhou um fantasma
    JZ exit_identify_action         ; se sim, salta para o fim da rotina
    CMP R3, R1                      ; se não, verifica se o pixel selecionado é l_blue
    JZ caught_ghost                 ; se sim, apanhou um fantasma e salta para caught_ghost
    CMP R3, R2                      ; se não, verifica se o pixel selecionado é l_red
    JZ caught_ghost                 ; se sim, apanhou um fantasma e salta para caught_ghost
    CMP R3, R4                      ; se não, verifica se o pixel selecionado é orange
    JZ caught_ghost                 ; se sim, apanhou um fantasma e salta para caught_ghost
    CMP R3, R5                      ; se não, verifica se o pixel selecionado é pink
    JZ caught_ghost                 ; se sim, apanhou um fantasma e salta para caught_ghost
    CMP R3, R6                      ; se não, verifica se o pixel selecionado é red candy
    JZ caught_candy                 ; se sim, apanhou um doce e salta para caught_candy
    JMP exit_identify_action        ; repete o ciclo

caught_ghost:
    MOV R0, 3                       ; guarda em R0 o valor 3, código que representa que apanhou um fantasma
    JMP exit_identify_action        ; salta para o fim da rotina

caught_candy:
    MOV R0, 2                       ; guarda em R0 o valor 2, código que representa que apanhou um rebuçado
    JMP exit_identify_action        ; salta para o fim da rotina

exit_identify_action:
    POP R6                          ; recupera os valores anteriores dos registos modificados
    POP R5
    POP R4
    POP R3
    POP R2                          
    POP R1
    RET

; *****************************************************************************************************************************
; DELETE_CANDY - Verifica qual o candy que o pacman apanhou e apaga-o.
; Argumentos:    R1 - linha
;                R2 - coluna
;                R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;                R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
; 
; *****************************************************************************************************************************
delete_candy:
    PUSH R0                             ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R5, MIDDLE_LIN                  ; guarda em R5 o número da linha que representa o meio do ecrã
    MOV R6, MIDDLE_COL                  ; guarda em R6 o número da coluna que representa o meio do ecrã
    MOV R0, DEF_CANDY_POSITIONS         ; guarda em R0 o endereço da tabela que contêm as posições (linha, coluna) dos 4 rebuçados
    MOV R4, DEF_CANDY                   ; guarda em R4 a tabela que define cada rebuçado
    ADD R1, R7                          ; obtém a nova linha onde pacman encontrou o rebuçado
    ADD R2, R8                          ; obtém a nova coluna onde pacman encontrou o rebuçado
    CMP R2, R6                          ; compara a coluna onde o pacman encontrou o rebuçado com a coluna do meio do ecrã
    JLT left_candies                    ; se a coluna do rebuçado for maior então é um dos rebuçados da esquerda
    JGT right_candies                   ; se a coluna do rebuçado for menor então é um dos rebuçados da direita

    left_candies:
        CMP R1, R5                      ; compara a linha onde o pacman encontrou o rebuçado com a linha do meio do ecrã
        JLT left_up_candy               ; se for menor sabemos que é o rebuçado no canto superior esquerdo
        JGT left_down_candy             ; se for maior sabemos que é o rebuçado no canto inferior esquerdo

    right_candies:
        CMP R1, R5                      ; compara a linha onde o pacman encontrou o rebuçado com a linha do meio do ecrã
        JLT right_up_candy              ; se for menor sabemos que é o rebuçado no canto superior direito
        JGT right_down_candy            ; se for maior sabemos que é o rebuçado no canto inferior direito

    left_up_candy:
        MOV R1, [R0]                    ; linha do rebuçado
        MOV R2, [R0+2]                  ; coluna do rebuçado
        JMP exit_delete_candy           ; salta para o fim da rotina

    right_up_candy:
        MOV R1, [R0+4]                  ; linha do rebuçado
        MOV R2, [R0+6]                  ; coluna do rebuçado
        JMP exit_delete_candy           ; salta para o fim da rotina

    left_down_candy:
        MOV R1, [R0+8]                  ; linha do rebuçado
        MOV R2, [R0+10]                 ; coluna do rebuçado
        JMP exit_delete_candy           ; salta para o fim da rotina

    right_down_candy:
        MOV R1, [R0+12]                 ; linha do rebuçado
        MOV R2, [R0+14]                 ; coluna do rebuçado
        JMP exit_delete_candy           ; salta para o fim da rotina

    exit_delete_candy:
        CALL delete_object              ; apaga o rebuçado identificado

        POP R6                          ; recupera os valores anteriores dos registos modificados
        POP R5
        POP R4
        POP R3
        POP R2 
        POP R1
        POP R0
        RET

; *****************************************************************************************************************************
; EXPLOSION - Apaga o pacman, mostra uma explosão e altera EXPLOSION_EVENT para refletir que a explosão já ocorreu.
; Argumentos: R1 - linha do pacman
;             R2 - coluna do pacman
;             R4 - tabela que define o pacman
;
; *****************************************************************************************************************************
explosion:
    PUSH R4                     ; guarda o valor anterior do registo que será alterado nesta função
    
    CALL delete_object          ; apaga o pacman
    MOV R4, DEF_EXPLOSION       ; guarda a tabela que define a explosão em R4
    CALL draw_object            ; desenha a explosão
    MOV R4, TRUE                ; guarda o valor de TRUE em R4
    MOV [EXPLOSION_EVENT], R4   ; guarda na RAM em no endereço EXPLOSION_EVENT o valor TRUE (indicando assim que a explosão já occureu)
    
    POP R4                      ; recupera o valor anterior do registo modificado
    RET

; *****************************************************************************************************************************
; KEYBOARD - Verifica se uma tecla foi pressionada
;
; *****************************************************************************************************************************
keyboard:
    PUSH R1                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R0, 0                   ; inicializa R0 a 0 para guarda a tecla pressionada
    MOV R2, 0                   ; inicializa R2 a 0 para guarda a coluna pressionada
    MOV R1, KEY_START_LIN       ; define a linha a ler (inicialmente a 1)
    MOV R3, KEY_LIN             ; endereço do periférico das linhas do teclado
    MOV R4, KEY_COL             ; endereço do periférico das colunas do teclado
    MOV R5, MASK_LSD            ; máscara para isolar os 4 btis de menor peso
    MOV R6, 0                   ; inicializa o contador de linhas a 0

    check_key:
        MOVB [R3], R1           ; ativa a linha para leitura do teclado
        MOVB R2, [R4]           ; lê a coluna do teclado
        AND R2, R5              ; aplica a máscara
        CMP R2, 0               ; verifica se alguma tecla foi pressionada
        JZ next_line            ; se nenhuma tecla foi pressionada, passa para a próxima linha
        JMP is_key_pressed      ; caso contrário, espera que a tecla deixe de ser pressionada

    next_line:
        SHL R1, 1               ; passa para a próxima linha do teclado
        INC R6                  ; incrementa o contador de linhas
        CMP R6, 4               ; verifica se já leu todas as linhas
        JNZ check_key           ; se não leu todas as linhas, verifica a próxima
        JMP exit_keyboard       ; se já leu todas as linhas salta para o fim da rotina

    is_key_pressed:
        MOV R0, R1              ; guarda a linha da tecla pressionada em R0
        SHL R0, 4               ; coloca linha nibble high
        OR R0, R2               ; juntamos a coluna (nibble low), agora R0 tem a tecla pressionada

    exit_keyboard:
        POP R8                  ; recupera os valores anteriores dos registos modificados      
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        RET

; *****************************************************************************************************************************
; MOVEMENT_KEY - Verifica se a tecla premida é uma tecla de movimento e executa a ação associada, se o jogo estiver a decorrer.
; Argumentos: R0 - tecla premida
;             R11 - tecla premida anterior
;
; *****************************************************************************************************************************
movement_key:
    PUSH R1                         ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R4
    PUSH R5
    PUSH R7
    PUSH R8

    MOV R1, [GAME_STATE]            ; move para R1 o estado atual do jogo
    CMP R1, PLAYING                 ; compara o estado atual do jogo com o estado PLAYING
    JNZ end_move                    ; se o jogo não estiver PLAYING salta para end_move
    ; Key mappings for movement
    MOV R2, UP_LEFT_KEY             ; move para R2 o valor hexadecimal que representa o movimento UP/LEFT
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_up_left                 ; se a tecla pressionada for UP/LEFT salta para move_up_left
    MOV R2, UP_KEY                  ; move para R2 o valor hexadecimal que representa o movimento UP
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_up                      ; se a tecla pressionada for UP salta para move_up
    MOV R2, UP_RIGHT_KEY            ; move para R2 o valor hexadecimal que representa o movimento UP/RIGHT
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_up_right                ; se a tecla pressionada for UP/RIGHT salta para move_up_right
    MOV R2, LEFT_KEY                ; move para R2 o valor hexadecimal que representa o movimento LEFT
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_left                    ; se a tecla pressionada for LEFT salta para move_left
    MOV R2, RIGHT_KEY               ; move para R2 o valor hexadecimal que representa o movimento RIGHT
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_right                   ; se a tecla pressionada for RIGHT salta para move_right
    MOV R2, DOWN_LEFT_KEY           ; move para R2 o valor hexadecimal que representa o movimento DOWN/LEFT
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_down_left               ; se a tecla pressionada for DOWN/LEFT salta para move_down_left
    MOV R2, DOWN__KEY               ; move para R2 o valor hexadecimal que representa o movimento DOWN
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_down                    ; se a tecla pressionada for DOWN salta para move_down
    MOV R2, DOWN_RIGHT_KEY          ; move para R2 o valor hexadecimal que representa o movimento DOWN_RIGHT
    CMP R0, R2                      ; compara a tecla pressionada como o valor em R2
    JZ move_down_right              ; se a tecla pressionada for DOWN salta para move_down_right
    JMP end_move                    ; se a tecla pressionada não for nenhuma das teclas testadas acima então salta para end_move

move_up_left:
    MOV R3, DEF_OPEN_PAC_UP_LEFT    ; guarda em R3 o valor da tabela que define o pacman de boca aberta para cima e para a esquerda
    MOV R7, -1                      ; guarda em R7 o valor -1, R7 representa o movimento vertical ao mover para cima o objeto sutrai 1 à sua linha atual
    MOV R8, -1                      ; guarda em R8 o valor -1, R8 representa o movimento horizontal ao mover para a esquerda o objeto sutrai 1 à sua coluna atual
    JMP move                        ; salta para move para não alterar os valores de R3, R7 e R8

move_up:
    MOV R3, DEF_OPEN_PAC_UP         ; guarda em R3 o valor da tabela que define o pacman de boca aberta para cima
    MOV R7, -1                      ; guarda em R7 o valor -1
    MOV R8, 0                       ; guarda em R8 o valor 0. O movimento UP não requer translações horizontais
    JMP move                        ; salta para move

move_up_right:
    MOV R3, DEF_OPEN_PAC_UP_RIGHT   ; guarda em R3 o valor da tabela que define o pacman de boca aberta para cima e para a direita
    MOV R7, -1                      ; guarda em R7 o valor -1
    MOV R8, 1                       ; guarda em R8 o valor 1
    JMP move                        ; salta para move

move_left:
    MOV R3, DEF_OPEN_PAC_LEFT       ; guarda em R3 o valor da tabela que define o pacman de boca aberta para a esquerda
    MOV R7, 0                       ; guarda em R7 o valor 0. O movimento LEFT não requer translações verticais
    MOV R8, -1                      ; guarda em R8 o valor -1
    JMP move                        ; salta para move

move_right:
    MOV R3, DEF_OPEN_PAC_RIGHT      ; guarda em R3 o valor da tabela que define o pacman de boca aberta para a direita
    MOV R7, 0                       ; guarda em R7 o valor 0
    MOV R8, 1                       ; guarda em R8 o valor 1
    JMP move                        ; salta para move

move_down_left:
    MOV R3, DEF_OPEN_PAC_DOWN_LEFT  ; guarda em R3 o valor da tabela que define o pacman de boca aberta para baixo e para a esquerda
    MOV R7, 1                       ; guarda em R7 o valor 1
    MOV R8, -1                      ; guarda em R8 o valor -1
    JMP move                        ; salta para move

move_down:
    MOV R3, DEF_OPEN_PAC_DOWN       ; guarda em R3 o valor da tabela que define o pacman de boca aberta para baixo
    MOV R7, 1                       ; guarda em R7 o valor 1
    MOV R8, 0                       ; guarda em R8 o valor 0
    JMP move                        ; salta para move

move_down_right:
    MOV R3, DEF_OPEN_PAC_DOWN_RIGHT ; guarda em R3 o valor da tabela que define o pacman de boca aberta para baixo e para a direita
    MOV R7, 1                       ; guarda em R7 o valor 1 
    MOV R8, 1                       ; guarda em R8 o valor 1 

move:
    CMP R0, R11                     ; verifica se a tecla premida é igual à anterior
    JZ no_sound                     ; se sim o movimento é contínuo logo salta para no_sound para não tocar o som outra vez
    MOV R1, PACMAN_CHOMP            ; se não guarda o número do som pacman chomp em R1
    MOV [PLAY_MEDIA], R1            ; reproduz o som PACMAN_CHOMP
    no_sound:
        MOV R1, [PAC_LIN]           ; guarda em R1 a linha atual do pacman
        MOV R2, [PAC_COL]           ; guarda em R2 a coluna atual do pacman
        MOV R5, NUM_COL             ; guarda em R4 o número de colunas no ecrã
        CMP R2, R5                  ; verifica se a pacman ultrapassou o ecrã no lado direito
        JZ tunnel_right             ; se sim, coloca o pacman no lado esquerdo
        MOV R5, -5                  ;
        CMP R2, R5                  ; verifica se o pacman ultrapassou o ecrã no lado esquerdo
        JZ tunnel_left              ; se sim, coloca o pacman no lado direito
        JMP end_tunnel

        tunnel_right: 
            MOV R2, -4              ; coloca o pacman na esquerda
            JMP end_tunnel          ; salta para o fim do túnel    
        
        tunnel_left:
            MOV R2, 63              ; coloca o pacman na direita

        end_tunnel:
        MOV R4, DEF_PACMAN          ; move para R4 a tabela que define o pacman de boca fechada
        CALL move_pacman            ; chama a função move_pacman
        MOV [PAC_LIN], R1           ; atualiza a linha atual do pacman
        MOV [PAC_COL], R2           ; atualiza a coluna atual do pacman

end_move:
    POP R8                          ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R5
    POP R4
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; GAME_STATE_KEY - Determina se a tecla premida é uma que altera o estado do jogo e executa a ação associada.
; Argumentos:   R0 - tecla premida
;               R11 - tecla premida anteriormente
;
; *****************************************************************************************************************************
game_state_key:
    PUSH R1                                 ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2

    CMP R0, R11                             ; verifica se a tecla premida e a tecla premida anteriormente são iguais
    JZ exit_state_key                       ; se sim salta para exit_state_key (o jogador tem de largar a tecla e premir outra vez)
    
    ; Key mappings
    MOV R2, [GAME_STATE]                    ; guarda em R2 o valor do estado de jogo atual
    MOV R1, START_KEY                       ; move para R1 o valor hexadecimal que representa a tecla start (tecla C)
    CMP R0, R1                              ; verifica se a tecla pressionada é a tecla de start
    JZ start_key_pressed                    ; se sim, salta para start_key_pressed
    MOV R1, PAUSE_KEY                       ; se não, move para R1 o valor hexadecimal que representa a tecla pause (tecla D)
    CMP R0, R1                              ; verifica se a tecla pressionada é a tecla de pause
    JZ pause_key_pressed                    ; se sim, salta para pause_key_pressed
    MOV R1, END_GAME_KEY                    ; se não, move para R1 o valor hexadecimal que representa a tecla end game (tecla E)
    CMP R0, R1                              ; verifica se a tecla pressionada é a tecla de terminar o jogo
    JZ end_game_key_pressed                 ; se sim, salta para end_game_key_pressed
    JMP exit_state_key                      ; se não, salta para o fim da rotina

    start_key_pressed:
        CMP R3, INITIAL                     ; verifica se o estado atual do jogo é o estado inicial
        JNZ exit_state_key                  ; se não, salta para o fim da rotina
        MOV R1, PLAYING                     ; se sim, guarda em R1 o valor do estado PLAYING
        MOV [GAME_STATE], R1                ; atualiza o estado de jogo atual para PLAYING
        MOV R1, GAME_BACKGROUND             ; move para R1 o nº do cenário de fundo do jogo
        MOV [SELECT_BACKGROUND_IMG], R1     ; seleciona o valor em R1 como o nº do cenário de fundo
        MOV R1, PACMAN_THEME                ; move para R1 o nº do som PACMAN THEME
        MOV [STOP_MEDIA], R1                ; para de reproduzir o som PACMAN THEME
        JMP exit_state_key                  ; salta para o fim da rotina
    
    pause_key_pressed:
        CMP R2, PLAYING                     ; verifica se o estado atual do jogo é o estado PLAYING
        JZ pausing_game                     ; se sim, salta para pausing_game
        CMP R2, PAUSED                      ; se não, vertifica se o estado atual do jogo é o estado PAUSED
        JZ resuming_game                    ; se sim, salta para resuming_game
        JMP exit_state_key                  ; se não, salta para o fim da rotina

    pausing_game:
        CALL pause_game                     ; chama a função para pausar o jogo
        JMP exit_state_key                  ; salta para o fim da rotina

    resuming_game:
        CALL resume_game                    ; chama a função para resumir o jogo
        JMP exit_state_key                  ; salta para o fim da rotina

    end_game_key_pressed:
        CMP R2, PLAYING                     ; verifica se o estado atual do jogo é o estado PLAYING
        JZ ending_game                      ; se sim, salta para ending_game
        CMP R2, PAUSED                      ; se não, vertifica se o estado atual do jogo é o estado PAUSED
        JZ ending_game                      ; se sim, salta para ending_game
        JMP exit_state_key                  ; se não, salta para o fim da rotina

    ending_game:
        CALL end_game                       ; chama a função para terminar o jogo

    exit_state_key:
        POP R2                              ; recupera os valores anteriores dos registos modificados
        POP R1
        RET

; *****************************************************************************************************************************
; PAUSE_GAME - Pausa o jogo.
; Atualiza o estado do jogo para PAUSED e seleciona um cenário frontal diferente para indicar visualmente que o jogo está em
; pausa. Para além disso pausa todos os sons.
; *****************************************************************************************************************************
pause_game:
    PUSH R1                                 ; guarda o valor anterior do registo que é alterado nesta função

    DI                                      ; desativa interrupções
    MOV [PAUSE_ALL_SOUND], R1               ; pausa a reprodução de todos os sons (o valor de R1 é irrelevante)          
    MOV R1, PAUSED_IMG                      ; guarda em R1 o nº da imagem de pausa
    MOV [SELECT_FRONT_IMG], R1              ; seleciona a imagem de pausa como o cenário frontal
    MOV R1, PAUSED                          ; guarda em R1 o valor do estado de jogo PAUSED
    MOV [GAME_STATE], R1                    ; atualiza o estado de jogo atual para PAUSED
    
    POP R1                                  ; recupera o valor anterior do registo modificado
    RET

; *****************************************************************************************************************************
; RESUME_GAME - Resume o jogo.
; Atualiza o estado do jogo para PLAYING e apaga o cenário frontal que diz PAUSED para indicar visualmente que o jogo saiu de
; pausa. Para além disso resume a reprodução da música de fundo PACMAN THEME.
; *****************************************************************************************************************************
resume_game:
    PUSH R1                                ; guarda o valor anterior do registo que é alterado nesta função

    EI                                     ; reativa interrupções
    MOV R1, PACMAN_THEME                   ; guarda em R1 o nº do som PACMAN THEME
    MOV [RESUME_SOUND], R1                 ; resume a reprodução do som PACMAN THEME
    MOV R1, PAUSED_IMG                     ; guarda em R1 o nº da imagem de pausa
    MOV [DELETE_FRONT_IMG], R1             ; apaga a imagem de pausa como cenário frontal
    MOV R1, PLAYING                        ; guarda em R1 o valor do estado de jogo PLAYING
    MOV [GAME_STATE], R1                   ; atualiza o estado de jogo atual para PLAYING
    
    POP R1                                 ; recupera o valor anterior do registo modificado
    RET

; *****************************************************************************************************************************
; END_GAME - Termina o jogo.
; Atualiza o estado do jogo para GAME_OVER e muda o cenário de fundo para indicar visualmente que o jogo terminou. Toca o som
; de GAME OVER. Para de aceitar interrupções
; *****************************************************************************************************************************
end_game:
    PUSH R1                                ; guarda o valor anterior do registo que é alterado nesta função

    DI                                     ; desativa interrupções
    DI0                                    ; desativa a interrupção a 0
    DI1                                    ; desativa a interrupção a 1
    DI2                                    ; desativa a interrupção a 2
    DI3                                    ; desativa a interrupção a 3
    MOV [DELETE_SCREEN], R1                ; apaga todos os pixels do ecrã (o valor de R1 é irrelevante)
    MOV R1, GAME_OVER_SOUND                ; guarda em R1 o nº do som GAME_OVER_SOUND
    MOV [PLAY_MEDIA], R1                   ; toca o som game over
    MOV R1, GHOSTS_GIF                     ; guarda em R1 o nº do video GHOSTS_GIF
    MOV [LOOP_MEDIA], R1                   ; reproduz em loop o video GHOSTS_GIF
    MOV R1, GAME_OVER_IMG                  ; guarda em R1 o nº do cenário frontal GAME_OVER_IMG
    MOV [SELECT_FRONT_IMG], R1             ; seleciona GAME_OVER_IMG como o cenário frontal
    MOV R1, GAME_OVER                      ; guarda em R1 o valor do estado GAME_OVER
    MOV [GAME_STATE], R1                   ; atualiza o estado atual do jogo para GAME_OVER

    POP R1                                 ; recupera o valor anterior do registo modificado
    RET

; *****************************************************************************************************************************
; VICTORY - Termina o jogo com um ecrã de vitória.
; ATUALIZA o estado de jogo para WON e mostra o ecrã de vitória.
; *****************************************************************************************************************************
victory:
    PUSH R1                                ; guarda o valor anterior do registo que é alterado nesta função

    DI                                     ; desativa interrupções
    DI0                                    ; desativa a interrupção a 0
    DI1                                    ; desativa a interrupção a 1
    DI2                                    ; desativa a interrupção a 2
    DI3                                    ; desativa a interrupção a 3
    MOV R1, WIN_SOUND                      ; guarda em R1 o nº do som WIN_SOUND
    MOV [PLAY_MEDIA], R1                   ; toca o som win
    MOV R1, VICTORY_IMG                    ; guarda em R1 o nº do video GHOSTS_GIF
    MOV [SELECT_BACKGROUND_IMG], R1        ; seleciona VICTORY_IMG como o fundo
    MOV [DELETE_SCREEN], R1                ; apaga todos os pixels do ecrã (o valor de R1 é irrelevante)
    MOV R1, WON                            ; guarda em R1 o valor do estado WON
    MOV [GAME_STATE], R1                   ; atualiza o estado atual do jogo para WON

    POP R1                                 ; recupera o valor anterior do registo modificado
    RET

; *****************************************************************************************************************************
; DELAY - Introduz um delay
;
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
; INT_ROT_0 - Rotina de atendimento da interrupção 0.
;			  Usada para sinalizar que os fantasmas devem ser movidos.
; *****************************************************************************************************************************
int_rot_0:
    PUSH R1                     ; guarda o valor anterior do registo que é alterado nesta função
    PUSH R0
    
    MOV R1, 1                   ; guarda em R1 o valor 1
    MOV [int_0], R1             ; sinaliza que a interrupção ocorreu
    MOV R1, 10                  ; guarda em R1 o valor 10
    MOV R0, [COUNT_INT_0]       ; guarda em R0 o valor de COUNT_INT_0
    INC R0                      ; incrementa o valor de COUNT_INT_0
    CMP R0, R1                  ; compara o valor de COUNT_INT_0 com 10
    JNZ int_rot_0_end           ; se não for igual a 10, não faz nada
    MOV R0, 0                   ; se for igual a 10, reseta o contador de interrupções
    int_rot_0_end:
        MOV [COUNT_INT_0], R0   ; atualiza o valor de COUNT_INT_0
    POP R0
    POP R1                      ; recupera o valor anterior do registo modificado
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_1 - Rotina de atendimento da interrupção 1
;			  Usada sinalizar que o contador tem de atualizado.
; *****************************************************************************************************************************
int_rot_1:
    PUSH R1                     ; guarda o valor anterior do registo que é alterado nesta função

    MOV R1, 1                   ; guarda em R1 o valor 1
    MOV [int_1], R1             ; sinaliza que a interrupção ocorreu

    POP R1                      ; recupera o valor anterior do registo modificado
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_2 - Rotina de atendimento da interrupção 2
;             Usada sinalizar contar o tempo que a explosão fica vísivel.
; *****************************************************************************************************************************
int_rot_2:
    PUSH R1                     ; guarda o valor anterior do registo que é alterado nesta função

    MOV R1, 1                   ; guarda em R1 o valor 1
    MOV [int_2], R1             ; sinaliza que a interrupção ocorreu
    
    POP R1                      ; recupera o valor anterior do registo modificado
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_3 - Rotina de atendimento da interrupção 3
;
; *****************************************************************************************************************************
int_rot_3:
    PUSH R1                     ; guarda o valor anterior do registo que é alterado nesta função

    MOV R1, 1                   ; guarda em R1 o valor 1
    MOV [int_3], R1             ; sinaliza que a interrupção ocorreu
    
    POP R1                      ; recupera o valor anterior do registo modificado
    RFE                         ; Return From Exception

;*****************************************************************************************************************************
; PSEUDO_RANDOM - Gera um número pseudo-aleatório entre 0 e 15.
; Retorna: R6 - o número pseudo-aleatório
;               
; *****************************************************************************************************************************
pseudo_random:
    PUSH R1                     ; guarda o valor anterior do registo que é alterado nesta função

	MOV  R1, KEY_COL            ; periférico PIN
    MOVB R6, [R1]               ; lê o periférico
    SHR R6, 4                   ; faz shift dos bits no ar para as casas de menor peso
    
    POP R1                      ; recupera o valor anterior do registo modificado
    RET

; *****************************************************************************************************************************
; SPAWN_GHOSTS - Desenha os fantasmas consoante o número máximo de fantasmas permitidos
;
; *****************************************************************************************************************************
spawn_ghosts:
    PUSH R1                                 ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9

    MOV R3, [NUM_GHOSTS]                    ; guarda o numero de fantasmas em jogo
    MOV R5, MAX_GHOSTS                      ; guarda o numero máximo de fantasmas
    CMP R3, R5                              ; verifica se já estamos no número máximo
    JZ spawn_ghosts_end                     ; se sim, salta para o fim da rotina
    CALL pseudo_random                      ; se não, chamamos a função para gerar um número aleatório entre 0 e 15 guardado em R0
    CMP R6, 3                               ; verifica se o número aleatório é 3
    JNZ spawn_ghosts_end                    ; se não for 3, salta para o fim da rotina
    MOV R0, [COUNT_INT_0]                   ; guarda em R0 o número de vezes que lidámos com a interrupção 0
    MOV R2, 9                               ; guarda em R2 o valor 10
    CMP R0, R2                              ; verifica se o número de vezes que lidámos com a interrupção 0 é igual a 10
    JNZ spawn_ghosts_end                    ; se não for igual a 10, salta para o fim da rotina
    MOV R2, 0                               ; se for igual a 10, reseta o contador de interrupções
    MOV [COUNT_INT_0], R2                   ; reseta o contador de interrupções
    MOV R8, 0                               ; vamos começar por ver o fantasma 0
    for_max_ghosts:
        CMP R5, 0                           ; verifica se já vimos todos os ghosts
        JZ spawn_ghosts_end                 ; se já, saltamos para o fim da rotina
        check_aliveness:
            MOV R9, R8                      ; cria uma cópia de R8 que será editada
            MOV R1, ALIVE_GHOSTS            ; endereço da tabela alive_ghosts
            SHL R9, 1                       ; multiplica o valor de R9 por dois (2 porque WORD)
            ADD R9, R1                      ; endereço do valor indentificador da "aliveness" do fantasma em questão
            MOV R7, [R9]                    ; R7 guarda o valor indicador de se o fantasma está vivo
            CMP R7, 1                       ; verifica se o fantasma está vivo
            JZ next_ghost                   ; se estiver, vamos ver o próximo ghost
    continue:
            MOV R7, R8                      ; cria uma cópia de R8 que será alterada
            MOV R4, 6                       ; guarda em R4 o número 3 que é o que queremos multiplicar 
            MUL R7, R4                      ; se for 3, obtemos a posição relativa ao topo da tabela GHOST_POS da linha do fantasma em causa
            MOV R4, GHOST_POS               ; endereço da tabela ghost_pos
            ADD R7, R4                      ; endereço da linha do fantasma em causa 
            MOV R1, [R7]                    ; linha do fantasma em causa
            ADD R7, 2                       ; endereço da coluna
            MOV R2, [R7]                    ; coluna do fantasma em causa
            ADD R7, 2                       ; endereço da tabela que define o fantasma em causa
            MOV R4, [R7]                    ; guarda tabela que define o fantasma em causa em R4
            CALL draw_object                ; função que desenha um objeto neste caso o fantasma
            MOV R1, ALIVE_GHOSTS            ; endereço da tabela alive_ghosts 
            MOV R9, R8                      ; cópia de R8
            SHL R9, 1                       ; multiplica o valor de 98 por dois (2 porque WORD)
            ADD R9, R1                      ; endereço do valor indentificador da "aliveness" do fantasma em questão
            MOV R2, 1                       ; guarda em R2 o valor 1 que o fantasma estar vivo
            MOV [R9], R2                    ; atualizamos o estado do ghost para alive
            INC R3                          ; incrementa o número de alive ghosts
            JMP spawn_ghosts_end            ; salta para o fim da rotina
        next_ghost:
            INC R8                          ; próximo fantasma
            DEC R5                          ; decrementa o valor de R3 para avançar o for loop
            JMP for_max_ghosts              ; salta para o inicio do "for" loop
    
spawn_ghosts_end:
    MOV [NUM_GHOSTS], R3                    ; guarda na memória o novo número de alive ghosts
    POP R9                                  ; recupera os valores anteriores dos registos modificados
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; GHOST_CYCLE - Escolhe que fantasmas se vão movimentar após uma interrupção e chama a função para os mexer. Vão evoluir de
;               3.2 em 3.2 segundos.
; *****************************************************************************************************************************
ghost_cycle:
    PUSH R0                                 ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11

    MOV R0, [int_0]                         ; guarda em R0 o valor que indica a occurência da interrupção 0
    CMP R0, TRUE                            ; se o valor for igual a TRUE (1), então a interrupção ocorreu
    JNZ exit_ghost_cycle                    ; se não tiver occurido salta para o fim da rotina
    MOV R0, [COUNT_INT_0]                   ; guarda em R0 o número de vezes de lidámos com o interrupção 0 nesta função
    MOV R2, GHOST_RYTHM                     ; guarda em R2 o valor 8 (cada X vezes queremos mexer o fantasma)
    MOD R0, R2                              ; guarda em R0 o resto da divisão inteira por 10
    JNZ exit_ghost_cycle                    ; se o resto da divisão não for 0 salta para o fim da rotina
    MOV R3, MAX_GHOSTS                      ; guarda o numero máximo de fantasmas
    MOV R0, 0                               ; vamos começar pelo fantasma 0
    check_all_ghosts:
        CMP R3, 0                           ; verifica se já vimos todos os ghosts
        JZ exit_ghost_cycle                 ; se já, saltamos para o fim da rotina
        MOV R9, R0                      ; cria uma cópia de R0 que será editada
        MOV R1, ALIVE_GHOSTS            ; endereço da tabela alive_ghosts
        SHL R9, 1                       ; multiplica o valor de R9 por dois (2 porque WORD)
        ADD R9, R1                      ; endereço do valor que indentifica se o fantasma em questão está vivo ou não
        MOV R7, [R9]                    ; R7 guarda o valor indicador de se o fantasma está vivo
        CMP R7, 1                       ; verifica se o fantasma está vivo
        JNZ check_next_ghost            ; se não estiver, vamos ver o próximo ghost
        MOV R7, R0                      ; se estiver vivo, cria uma cópia de R0 que será alterada
        MOV R4, 6                       ; guarda em R4 o número 3 que é o que queremos multiplicar
        MUL R7, R4                      ; obtemos a posição relativa ao topo da tabela GHOST_POS da linha do fantasma em causa
        MOV R4, GHOST_POS               ; endereço da tabela ghost_pos
        ADD R7, R4                      ; endereço da linha do fantasma em causa 
        MOV R10, R7                     ; guardamos uma cópia do endereço da linha
        MOV R1, [R7]                    ; linha do fantasma em causa
        ADD R7, 2                       ; endereço da coluna
        MOV R11, R7                     ; guardamos uma cópia do endereço da coluna
        MOV R2, [R7]                    ; coluna do fantasma em causa
        ADD R7, 2                       ; endereço da tabela que define o fantasma 
        MOV R4, [R7]                    ; guarda o endereço da tabela que define o fantasma em R4
        CALL animate_ghost              ; chama a função que anima o fantasma
        MOV [R10], R1                   ; atualiza a memória com a nova linha atual do fantasma (pós movimento)
        MOV [R11], R2                   ; atualiza a memória com a nova coluna atual do fantasma (pós movimento)
        INC R3                          ; incrementa o número de alive ghosts
    
    check_next_ghost:
        INC R0                          ; próximo fantasma
        DEC R3                          ; decrementa o valor de R3 para avançar o loop
        JMP check_all_ghosts            ; salta para o inicio do loop
    
    exit_ghost_cycle:
        MOV R0, FALSE                   ; guarda em R0 o valor FALSE (0)
        MOV [int_0], R0                 ; repõem o indicador de occurência da interrupção a 0 uma vez que já lidámos com ela
        POP R11                         ; recupera os valores anteriores dos registos modificados
        POP R10
        POP R9
        POP R8
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

; *****************************************************************************************************************************
; ANIMATE_GHOST - Anima o fantasma.
; Argumentos:   R1 - linha em que se encontra o fantasma
;               R2 - coluna em que se encontra o fantasma
;               R4 - endereço da tabela que define o fantasma
;
;
; *****************************************************************************************************************************
animate_ghost:
    PUSH R3                         ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, [PAC_LIN]               ; linha do pacman
    MOV R6, [PAC_COL]               ; coluna do pacman
    CALL choose_ghost_direction     ; chama a função que escolhe em que direção o fantasma se mexe para se aproximar do pacman
    MOV R3, R4                      ; cópia de R4 para argumento na função move_object
    CALL move_object		        ; chama a função que move o fantasma
    
    POP R8                          ; recupera os valores anteriores dos registos modificados
    POP R7
    POP R6
    POP R5
    POP R3
    RET

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
    CMP R5, R1                      ; compara a coluna onde se encotra o pacman com a coluna do fantasma
    JLT up                          ; se a coluna do pacman for menor salta para up pois o fantasma tem que subir
    JGT down                        ; se a coluna do pacman for maior salta para down pois o fantasma tem que descer
    MOV R7, 0                       ; se não for nenhum dos dois é porque se encontram na mesma coluna, nesse caso o fantasma não precisa de se mexer verticalmente
    JMP check_horizontal            ; salta para check_horizontal
        
    up:
    MOV R7, -1                      ; guarda em R7 o valor -1 (indica para cima)
    JMP check_horizontal            ; salta para check_horizontal
    
    down:
    MOV R7, 1                       ; guarda em R7 o valor 1 (indica para baixo)

    check_horizontal:
        CMP R6, R2                  ; compara a linha onde se encotra o pacman com a linha do fantasma
        JLT left                    ; se a linha do pacman for menor salta para left pois o fantasma tem que ir para a esquerda
        JGT right                   ; se a linha do pacman for maior salta para right pois o fantasma tem que ir para a direita
        MOV R8, 0                   ; se não for nenhum dos dois é por se encontram na mesma linha, nesse caso o fantasma não precisa de se mexer horizontalmente
        JMP leave_ghost_direction   ; salta para o fim da rotina

        left:
        MOV R8, -1                  ; guarda em R8 o valor -1 (indica para a esquerda)
        JMP leave_ghost_direction   ; salta para o fim da rotina

        right:
        MOV R8, 1                   ; guarda em R8 o valor 1 (indica para a direita)

    leave_ghost_direction:
        RET

; *****************************************************************************************************************************
; MOVE_PACMAN - Move o Pacman de forma animada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - tabela que define o pacman
;               R4 - tabela que define a animação do pacman
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna:      R1 - novo valor da linha, após o movimento
;               R2 - novo valor da coluna, após o movimento
; *****************************************************************************************************************************
move_pacman:
    PUSH R0                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R6
    PUSH R9
    PUSH R10

    CALL choose_object_action   ; chama a função que verifica se o pacman está a tentar ultrapassar algum limite com este movimento
    CMP R0, 0                   ; compara o retorno da função (R0) com o valor 0
    JZ end_pacman_movement      ; se a função retornar 0 então saltamos para end_movement pois o movimento é proíbido
    CMP R0, 3                   ; compara o retorno da função (R0) com o valor 3
    JLT check_pacman_candy      ; se a função retornar 3 então não saltamos e chamamos a função da explosão
    CALL explosion              ; chama a função da explosão
    JMP end_pacman_movement     ; salta para o fim da rotina

check_pacman_candy:
    CMP R0, 2                           ; compara o retorno da função (R0) com o valor 2
    JNZ new_position_pacman             ; se o retorno da função não for 2 salta para o new_position_pacman
    MOV R0, EAT_CANDY                   ; vai buscar o endereço do som a comer o rebuçado
    MOV [PLAY_MEDIA], R0                ; dá play do som
    CALL delete_candy                   ; apaga o rebuçado
    MOV R10, [REMAINING_CANDIES]        ; guarda no registo R10 quantos rebuçados faltam comer
    SUB R10, 1                          ; subtrai o rebuçado comido
    CMP R10, 0                          ; verifica se falta algum rebuçado
    JNZ skip_victory                    ; se ainda faltar dá skip à victory
    CALL victory                        ; se não falta, chama a função victory
    skip_victory:
        MOV [REMAINING_CANDIES], R10    ; guarda o número de rebuçados que ainda faltam comer
        JMP end_pacman_movement         ; salta para o fim da rotina

new_position_pacman:
    CALL delete_object          ; apaga o pacman
    ADD R1, R7                  ; obtém nova linha
    ADD R2, R8                  ; obtém nova coluna
    CALL draw_object            ; desenha versão animada do pacman
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento
    CALL delete_object          ; apaga a versão animada do pacman
    MOV R4, R3                  ; move o valor de R3 para R4 para ser usado como argumento na função seguinte
    CALL draw_object            ; desenha versão final do pacman
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento 

end_pacman_movement:
    POP R10
    POP R9                      ; recupera os valores anteriores dos registos modificados
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; SCORE_CYCLE - Incrementa o contador dos pontos cada 5 interrupções 1 para contar em segundos (200ms *  5 = 1 segundo).
; 
; *****************************************************************************************************************************
score_cycle:
    PUSH R0                         ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    
    MOV R0, [int_1]                 ; guarda em R0 o valor que indica a occurência da interrupção 1
    CMP R0, TRUE                    ; se o valor for igual a TRUE (1), então a interrupção ocorreu
    JNZ exit_score_cycle            ; se não tiver occurido salta para o fim da rotina
    MOV R0, [COUNT_INT_1]           ; guarda em R0 o número de vezes de lidámos com o interrupção 1 nesta função
    INC R0                          ; incrementa R0
    MOV R2, 5                       ; guarda em R2 o valor 5 (cada 5 vezes queremos incrementar o contador)
    MOD R0, R2                      ; guarda em R0 o resto da divisão inteira por 5
    MOV [COUNT_INT_1], R0           ; atualiza na memoria o valor de R0
    JNZ exit_score_cycle            ; se o resto da divisão não for 0 salta para o fim da rotina
    MOV R0, SCORE                   ; obtém o endereço da pontuação atual
    MOV R1, [R0]                    ; obtém o valor da pontuação atual
    MOV R2, UPPER_LIMIT             ; obtém o valor do limite superior
    CMP R1, R2                      ; determina se o valor atual é o limite superior
    JZ time_exceeded                ; se for, salta para time_exceeded para terminar o jogo
    ADD R1, 1                       ; caso contrário, incrementa a pontuação por 1
    MOV R3, MASK_LSD                ; copia a máscara das unidades para R3
    MOV R4, R1                      ; copia valor da pontuação para R4
    AND R4, R3                      ; máscara para obter o digito menos significativo de R4
    MOV R2, 0AH                     ; copia para R2 o valor hexadecimal A 
    CMP R4, R2                      ; verifica se o digito menos significativo é 10 (hex 'A')
    JZ skip_hex                     ; se sim salta para jump_hex que irá saltar à frente os valores A-F
    MOV [DISPLAYS], R1              ; se não, atualiza o display
    MOV [R0], R1                    ; guarda o novo valor na memória
    JMP exit_score_cycle            ; salta para o fim da rotina
    
    skip_hex:
        ADD R1, INC_TENS            ; adiciona 6 ao contador para saltar os valores de A - F
        MOV R3, MASK_TENS           ; copia a máscara das dezenas para R3
        MOV R4, R1                  ; copia o valor do contador para R4
        AND R4, R3                  ; aplica a máscara das dezenas
        MOV R2, 0A0H                ; copia para R2 o valor hexadecimal 0A0H
        CMP R4, R2                  ; verifica se as dezenas estão a A
        JZ jump_hundreds            ; se sim salta para jump_hundreds que irá incrementar para 256H que mostra 100 nos displays
        MOV [DISPLAYS], R1          ; atualiza o display
        MOV [R0], R1                ; guarda o novo valor na memória
        JMP exit_score_cycle        ; salta para o fim da rotina

    jump_hundreds:
        MOV R3, INC_HUNDREDS        ; copia 96 para R3 para saltar para simular as centenas em hexadecinal
        ADD R1, R3                  ; adiciona o valor de R3(96) a R1
        MOV [DISPLAYS], R1          ; atualiza o display
        MOV [R0], R1                ; guarda o novo valor na memória
        JMP exit_score_cycle        ; salta para o fim da rotina

    time_exceeded:
        CALL end_game               ; chama a função para terminar o jogo
        MOV R1, TIME_LIMIT_IMG      ; guarda em R1 o nº do cenário frontal TIME_LIMIT_IMG
        MOV [SELECT_FRONT_IMG], R1  ; seleciona TIME_LIMIT_IMG como o cenário frontal

    exit_score_cycle:
        MOV R0, FALSE               ; guarda em R0 o valor FALSE (0)
        MOV [int_1], R0             ; repõem o indicador de occurência da interrupção a 0 uma vez que já lidámos com ela
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

; *****************************************************************************************************************************
; CHECK_EXPLOSION - Verifica se a explosão já ocorreu e apaga-a passado 1.5 segundos.
;  
; *****************************************************************************************************************************
check_explosion:
    PUSH R0                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R1
    PUSH R2
    PUSH R4

    MOV R0, TRUE                ; guarda o valor de TRUE (1) em R0
    MOV R4, [EXPLOSION_EVENT]   ; guarda em R4 o valor que indica se a explosão já ocorreu
    CMP R4, R0                  ; verifica se a explosão já ocorreu
    JNZ exit_check_explosion    ; se não, salta para o fim da rotina
    MOV R0, [int_2]             ; se sim, guarda em R0 o valor que indica a occurência da interrupção 2
    CMP R0, TRUE                ; se o valor for igual a TRUE (1), então a interrupção ocorreu
    JNZ exit_check_explosion    ; se não tiver occurido salta para o fim da rotina
    MOV R0, [COUNT_INT_2]       ; guarda em R0 o número de vezes de lidámos com o interrupção 2 nesta função
    INC R0                      ; incrementa R0
    MOV R2, 500                 ; guarda em R2 o valor 5 (cada 5 vezes queremos incrementar o contador)
    MOD R0, R2                  ; guarda em R0 o resto da divisão inteira por 5
    MOV [COUNT_INT_2], R0       ; atualiza na memoria o valor de R0
    JNZ exit_check_explosion    ; se o resto da divisão não for 0 salta para o fim da rotina
    MOV R1, FALSE               ; guarda o valor de TRUE (1) em R1
    MOV [EXPLOSION_EVENT], R1   ; atualiza a memória com o valor FALSE (0) 
    MOV R1, [PAC_LIN]           ; guarda em R1 a linha onde a explosão ocorreu
    MOV R2, [PAC_COL]           ; guarda em R2 a coluna onde a explosão ocorreu
    MOV R4, DEF_EXPLOSION       ; guarda em R4 a tabela que define a explosão
    CALL delete_object          ; chama a função para apagar a explosão
    CALL end_game               ; chama a função para terminar o jogo

exit_check_explosion:
    POP R4                      ; recupera os valores anteriores dos registos modificados
    POP R2
    POP R1
    POP R0
    RET