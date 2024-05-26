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

; Sons / GIFs
PACMAN_THEME           EQU 0           ; música do jogo
PACMAN_CHOMP           EQU 1           ; som do pacman a movimentar-se
GHOSTS_GIF             EQU 2           ; GIF GAME OVER

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
KEY_START_LINE         EQU 1           ; inicialização da linha
MASK_KEY               EQU 0FH         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; Pontuação
INITIAL_POINTS         EQU 00H         ; valor inicial da pontuação
UPPER_LIMIT            EQU 999H        ; valor máximo do contador de pontos
LOWER_LIMIT            EQU 00H         ; valor mínimo do contador de pontos  
MASK_LSD               EQU 0FH         ; máscara para isolar os 4 btis de menor peso para ver o digito menos significativo
MASK_TENS              EQU 0F0H        ; máscara para isolar os bits que representam as dezenas

; Posições Iniciais
PAC_START_LIN          EQU 13          ; linha inicial do pacman (a meio do ecrã)
PAC_START_COL          EQU 30          ; coluna inicial do pacman (a meio do ecrã)
GHOST_START_LIN        EQU 14          ; linha inicial do fantasma (a meio do ecrã)
GHOST1_START_COL       EQU 0           ; coluna inicial do fantasma1 (encostado ao limite esquerdo)
GHOST2_START_COL       EQU 58          ; coluna inicial do fantasma2 (encostado ao limite esquerdo)
GHOST3_START_COL       EQU 0           ; coluna inicial do fantasma3 (encostado ao limite esquerdo)
GHOST4_START_COL       EQU 58          ; coluna inicial do fantasma4 (encostado ao limite esquerdo)
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
GRN                    EQU 0F0A5H	   ; cor do pixel: verde em ARGB (opaco no máximo, verde a 10, azul a 5 e vermelho a 0)
RED                    EQU 0FF00H      ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
CYAN                   EQU 0F4FFH      ; cor do pixel: ciano em ARGB (opaco, verde e azul no máximo, vermelho a 4)
BLUE                   EQU 0F00FH	   ; cor do pixel: azul em ARGB (opaco e azul a 9, verde a 6 e vermelho a 4)

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

DEF_CANDY_POSITIONS:
    WORD        CANDY1_LIN
    WORD        CANDY1_COL
    WORD        CANDY2_LIN
    WORD        CANDY2_COL
    WORD        CANDY3_LIN
    WORD        CANDY3_COL
    WORD        CANDY4_LIN
    WORD        CANDY4_COL

NUM_GHOSTS:     WORD 0                  ; guarda o número de fantasmas em jogo
SCORE:          WORD 0                  ; guarda a pontução do jogo

; Posições Atuais
PAC_LIN:        WORD PAC_START_LIN      ; guarda a linha atual do pacman, inicializada a PAC_START_LIN
PAC_COL:        WORD PAC_START_COL      ; guarda a coluna atual do pacman, inicializada a PAC_START_COL
GHOST1_LIN:     WORD GHOST_START_LIN    ; guarda a linha atual do fantasma 1, inicializada a GHOST_START_LIN
GHOST1_COL:     WORD GHOST1_START_COL   ; guarda a coluna atual do fantasma 1, inicializada a GHOST1_START_COL
GHOST2_LIN:     WORD GHOST_START_LIN    ; guarda a linha atual do fantasma 2, inicializada a GHOST_START_LIN
GHOST2_COL:     WORD GHOST2_START_COL   ; guarda a coluna atual do fantasma 2, inicializada a GHOST2_START_COL
GHOST3_LIN:     WORD GHOST_START_LIN    ; guarda a linha atual do fantasma 3, inicializada a GHOST_START_LIN
GHOST3_COL:     WORD GHOST3_START_COL   ; guarda a coluna atual do fantasma 3, inicializada a GHOST3_START_COL
GHOST4_LIN:     WORD GHOST_START_LIN    ; guarda a linha atual do fantasma 4, inicializada a GHOST_START_LIN
GHOST4_COL:     WORD GHOST4_START_COL   ; guarda a coluna atual do fantasma 4, inicializada a GHOST4_START_COL

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

CALL spawn_ghosts                       ; chama a função para libertar fantasmas

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
    CALL keyboard                       ; chama a função do teclado para indentificar a tecla pressionada (valor guardado em R0)
    CALL game_state_key                 ; chama uma função para detetar se a tecla pressionada é uma tecla que altera o estado do jogo e executa a ação associada
    CALL movement_key                   ; chama uma função para detetar se a tecla pressionada é uma tecla de movimento e executar a ação associada
    CALL ghost_cycle                    ; chama a função que anima os fantasmas
    CALL score_cycle                    ; chama a função que incrementa a pontuação
    MOV R11, R0                         ; guarda a ultima tecla premida em R11
    JMP main

; *****************************************************************************************************************************
; SPAWN_GHOSTS - Desenha os fantasmas consoante o número máximo de fantasmas permitidos
;
; *****************************************************************************************************************************
spawn_ghosts:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV R0, NUM_GHOSTS                  ; move para R1 o endereço de fantasmas atualmente em jogo
    MOV R1, 0                           ; guarda o número de fantasmas inicialmente em jogo (0 - nenhum)
    MOV [R0], R1                        ; atualiza o número de ghosts para 0
    MOV R5, MAX_GHOSTS                  ; guarda o número máximo de fantasmas permitidos em jogo
    CMP R5, 0                           ; verifica se o número máximo de fantasmas permitidos é 0
    JZ spawn_ghosts_end                 ; se sim salta para o fim da rotina sem lançar nenhum fantasma
    MOV R2, GHOST1_LIN                  ; se não, obtém o endereço da linha atual do fantasma 1
    MOV R1, [R2]                        ; valor da linha atual do fantasma 1 (de momento igual à inicial)
    MOV R3, GHOST1_COL                  ; endereço da coluna atual do fantasma 1
    MOV R2, [R3]                        ; valor da linha atual do fantasma 1 (de momento igual à inicial)
    MOV R4, DEF_GHOST                   ; tabale que define os fantasmas
    CALL draw_object                    ; chama a função que desenha objetos neste caso o fantasma
    MOV R2, 1                           ; guarda o valor 1 pois 1 fantasma já foi libertado
    MOV [R0], R2                        ; atualiza o número de fantasmas em jogo para 1

    init_ghost_2:
        CMP R5, 1                       ; verifica se o número máximo de fantasmas permitidos é 1
        JZ spawn_ghosts_end             ; se sim salta para o fim da rotina sem lançar mais nenhum fantasma
        MOV R2, GHOST2_LIN              ; se não, obtém o endereço da linha atual do fantasma 2
        MOV R1, [R2]                    ; valor da linha atual do fantasma 2 (de momento igual à inicial)
        MOV R3, GHOST2_COL              ; endereço da coluna inicial do fantasma 2
        MOV R2, [R3]                    ; valor da linha atual do fantasma 2 (de momento igual à inicial)
        CALL draw_object                ; chama a função que desenha objetos neste caso o fantasma
        MOV R2, 2                       ; guarda o valor 2 pois 2 fantasmas já foram libertados
        MOV [R0], R2                    ; atualiza o número de fantasmas em jogo para 2

    init_ghost_3:
        CMP R5, 2                       ; verifica se o número máximo de fantasmas permitidos é 2
        JZ spawn_ghosts_end             ; se sim salta para o fim da rotina sem lançar mais nenhum fantasma
        MOV R2, GHOST3_LIN              ; se não, obtém o endereço da linha atual do fantasma 3
        MOV R1, [R2]                    ; valor da linha atual do fantasma 3 (de momento igual à inicial)
        MOV R3, GHOST3_COL              ; endereço da coluna inicial do fantasma 3
        MOV R2, [R3]                    ; valor da linha atual do fantasma 3 (de momento igual à inicial)
        CALL draw_object                ; chama a função que desenha objetos neste caso o fantasma
        MOV R2, 3                       ; guarda o valor 3 pois 3 fantasmas já foram libertados
        MOV [R0], R2                    ; atualiza o número de fantasmas em jogo para 3

    init_ghost_4:
        JZ spawn_ghosts_end             ; se sim salta para o fim da rotina sem lançar mais nenhum fantasma
        MOV R2, GHOST4_LIN              ; se não, obtém o endereço da linha atual do fantasma 4
        MOV R1, [R2]                    ; valor da linha atual do fantasma 4 (de momento igual à inicial)
        MOV R3, GHOST4_COL              ; endereço da coluna inicial do fantasma 4
        MOV R2, [R3]                    ; valor da linha atual do fantasma 4 (de momento igual à inicial)
        CALL draw_object                ; chama a função que desenha objetos neste caso o fantasma
        MOV R2, 4                       ; guarda o valor 4 pois 4 fantasmas já foram libertados
        MOV [R0], R2                    ; atualiza o número de fantasmas em jogo para 4

    spawn_ghosts_end:
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; *****************************************************************************************************************************
; DRAW_CANDY - Desenha os rebuçados nas poições definas na tabela DEF_CANDY_POSITIONS
;
; *****************************************************************************************************************************
draw_candy:
    PUSH R0
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
    
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; *****************************************************************************************************************************
; DRAW_CENTER_BOX - Desenha a caixa central onde nasce o pacman.
; *****************************************************************************************************************************
draw_center_box:
    PUSH R1
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
        MOV R6, 003DH                   ; guarda em R6 o valor da coluna que temos desenhar o spwan dos fantasmas à direita
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
            CALL draw_ghost_spawns      ; desenhamos a primeira parte do spwan dos fantasmas (esquerda cima)
            ADD R2, R6                  ; seleciona a coluna que começa a segunda parte do spawn
            SUB R1, 2                   ; seleciona a linha que começa a segunda parte do spawn
            CALL draw_ghost_spawns      ; desenhamos a segunda parte do spwan dos fantasmas (direita cima)
            SUB R2, R6                  ; seleciona a coluna que começa a segunda parte do spawn
            ADD R1, 7H                  ; seleciona a linha que começa a segunda parte do spawn
            CALL draw_ghost_spawns      ; desenhamos a terceira parte do spwan dos fantasmas (direita baixo)
            ADD R2, R6                  ; seleciona a coluna que começa a segunda parte do spawn
            SUB R1, 2                   ; seleciona a linha que começa a segunda parte do spawn
            CALL draw_ghost_spawns      ; desenhamos a última parte do spwan dos fantasmas (esquerda baixo)
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
; DRAW_GHOST_SPAWNS - Desenha os spwans dos fantasmas
; Argumentos: NUNO FAZ A FUNCTION DESCRIPTION AQUI COM OS ARGUMENTOS E COMENTA ESTA FUNÇÃO
;
; *****************************************************************************************************************************
draw_ghost_spawns:
    PUSH R2                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R3
    PUSH R4
    
    MOV R4, R2

    CALL write_pixel
    ADD R2, 1
    CALL write_pixel
    ADD R2, 1
    CALL write_pixel
    ADD R1, 1
    CMP R4, 0
    JZ left_ghost_spwans
    SUB R2, 2
    CALL write_pixel
    ADD R1, 1
    JMP jump_left_spwans
    
    left_ghost_spwans:
        CALL write_pixel
        ADD R1, 1
        SUB R2, 2

    jump_left_spwans:
        CALL write_pixel
        ADD R2, 1
        CALL write_pixel
        ADD R2, 1
        CALL write_pixel
        POP R4                  ; recupera os valores anteriores dos registos modificados
        POP R3
        POP R2
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
; CHOSE_OBJECT_ACTION - Verifica qual ação que o objeto irá realizar
; Argumentos:	R1 - linha em que o objeto se encontra
;               R2 - coluna em que o objeto se encontra
;			    R4 - tabela que define o objeto
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: R0 - Retorna o valor da ação que o objeto terá:
;               0 - movimento proíbido
;               1 - pode mover
;               2 - pode mover e encontra um candy
;               3 - pode mover e encontra um ghost
; NUNO ADICIONA OS MISSING COMENTÁRIOS A ESTA FUNÇÃO DEPOIS APAGA ESTE TEXTO
; *****************************************************************************************************************************
chose_object_action:
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
    MOV R0, 1                           ; 
    MOV R10, BLUE                       ; guarda em R10 a cor BLUE (cor dos limites)

check_horizontal_pixels:
    MOV R9, [R4+2]                      ;
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
        SUB R9, 1                       ; decrementa ????? (NUNO)
        JZ check_vertical_pixels        ; se já chegou a 0 salta para check_vertical_pixels
        ADD R2, 1                       ; se não, passa para a próxima linha
        JMP next_horizontal_pixels      ; repete o ciclo

check_vertical_pixels:
    MOV R9, [R4]                        ; guarda em R9 a altura do objeto
    next_vertical_pixels:
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ over_limit                   ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CALL identify_action            ; se não, chama a função que atribui os códigos de tipo de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
        SUB R2, R6
        CALL get_color_pixel            ; chama a função que identifica a cor do pixel selecionado
        CMP R3, R10                     ; verifica se o pixel é azul
        JZ over_limit                   ; se sim, o objeto está a tentar mover-se para lá de um limite então salta para over_limit
        CALL identify_action            ; se não, chama a função que atribui os códigos de tipo de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
        ADD R2, R6                      ;
        SUB R9, 1                       ;
        JZ not_over_limit               ; se já chegou a 0 salta para not_over_limit
        ADD R1, 1                       ; se não, passa para a próxima coluna
        JMP next_vertical_pixels        ; repete o ciclo

over_limit:
    MOV R0, 0                           ; como o objeto está a tentar mover-se para cima de um limite guardamos 0 em R0 para indicar que o movimento é proíbido
    JMP exit_limit_tests                ; salta para o fim da rotina

not_over_limit:
    MOV R0, 1                           ; guarda em R0 o valor 1 (código que indica que o pacman se pode movimentar e não vai collidir com nada)
    JMP exit_limit_tests                ; salta para o fim da rotina

exit_limit_tests:
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
; IDENTIFY_ACTION - Identifica a ação a ação do pacman.
; Atribui os códigos indentificadores de ação consoante a cor dos pixels que o pacman quer ocupar (descobre se vai colidir com um doce ou um fantasma)
; Argumentos:   R3 - cor do pixel
;
; Retorna:      R0 - código identificador de ação
;               2 - pode mover e encontra um candy
;               3 - pode mover e encontra um ghost
; 
; *****************************************************************************************************************************
identify_action:
    PUSH R1                         ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2

    MOV R1, GRN                     ; guarda em R1 o valor hexa que define a cor utilizada para o pixels verdes
    MOV R2, RED                     ; guarda em R2 o valor hexa que define a cor utlizada para os pixels vermelhos
    CMP R0, R1                      ; verifica se o ??? é um pixel verde ??? (NUNO)
    JZ exit_chose_pacman_action     ; se sim, salta para o fim da rotina
    CMP R3, R1                      ; se não, verifica se o pixel selecionado é verde
    JZ caught_ghost                 ; se sim, apanhou um fantasma e salta para caught_ghost
    CMP R3, R2                      ; se não, verifica se o pixel selecionado é vermelho
    JZ caught_candy                 ; se sim, apanhou um doce e salta para caught_candy
    JMP exit_chose_pacman_action    ; repete o ciclo

caught_ghost:
    MOV R0, 3                       ; guarda em R0 o valor 3, código que representa que encontrou um doce
    JMP exit_chose_pacman_action    ; salta para o fim da rotina

caught_candy:
    MOV R0, 2                       ; guarda em R0 o valor 2, código que representa que apanhou um fantasma
    JMP exit_chose_pacman_action    ; salta para o fim da rotina

exit_chose_pacman_action:
    POP R2                          ; recupera os valores anteriores dos registos modificados
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

    CALL chose_object_action    ; chama a função que verifica que tipo de movimento o objeto está a tentar ultrapassar algum limite com este movimento
    CMP R0, FALSE               ; compara o retorno da função (R0) com o valor para FALSE
    JZ end_movement             ; se a função retornar false, saltamos para end_movement pois o movimento é proíbido
    CALL delete_object          ; se não, apaga o objeto
    ADD R1, R7                  ; obtém nova linha
    ADD R2, R8                  ; obtém nova coluna
    CALL draw_object            ; desenha versão animada do objeto
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento
    CALL delete_object          ; apaga a versão animada do objeto
    MOV R4, R3                  ; guarda em R4 a tabela de define o objeto (versão não animada)
    CALL draw_object            ; desenha versão final do objeto
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento 

end_movement:
    POP R9                      ; recupera os valores anteriores dos registos modificados
    POP R6
    POP R0
    RET


; *****************************************************************************************************************************
; MOVE_PACMAN - Incrementa ou decrementa o contador com base na tecla pressionada e atualiza o display
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - tabela que define o pacman
;               R4 - tabela que define a animação do pacman
;               R7 - sentido do movimento do objeto na vertical (valor a somar à linha em cada movimento: +1 para baixo, -1 para cima)
;               R8 - sentido do movimento do objeto na horizontal (valor a somar à coluna em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna:      R1 - novo valor da linha, após o movimento
;               R2 - novo valor da coluna, após o movimento
; NUNO - MAIS COMENTÁRIOS PLUS TEMOS QUE ALTERAR ESTA FUNÇÃO (LIGA-ME E EU EXPlICO)
; *****************************************************************************************************************************
move_pacman:
    PUSH R0                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R6
    PUSH R9

    CALL chose_object_action    ; chama a função que verifica se o pacman está a tentar ultrapassar algum limite com este movimento
    CMP R0, 0                   ; compara o retorno da função (R0) com o valor 0
    JZ end_pacman_movement      ; se a função retornar 0 então saltamos para end_movement pois o movimento é proíbido
    CMP R0, 3
    JNZ check_pacman_candy
    CALL explosion
    JMP new_position_pacman

check_pacman_candy:
    CMP R0, 2
    JNZ new_position_pacman
    CALL delete_candy
    JMP new_position_pacman

new_position_pacman:
    CALL delete_object          ; se não, apaga o pacman
    ADD R1, R7                  ; obtém nova linha
    ADD R2, R8                  ; obtém nova coluna
    PUSH R4                     ; guarda o valor de R4
    MOV R4, R3                  ; move o valor de R3 para R4 para ser usado como argumento na função seguinte
    CALL draw_object            ; desenha versão animada do pacman
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento
    CALL delete_object          ; apaga a versão animada do pacman
    POP R4                      ; recupera o valor de R4
    CALL draw_object            ; desenha versão final do pacman
    CALL delay                  ; chama uma função para atrasar/abrandar o movimento 


end_pacman_movement:
    POP R9                      ; recupera os valores anteriores dos registos modificados
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; DELETE_CANDY - Verifica qual o candy que o pacman apanhou e apaga-o
; NUNO TERMINA - IK ITS A FUNCTION TEMPLATE
; *****************************************************************************************************************************
delete_candy:
    PUSH R1
    POP R1
    RET

; *****************************************************************************************************************************
; EXPLOSTION - Verifica qual o candy que o pacman apanhou e apaga-o
; NUNO TERMINA - IK ITS A FUNCTION TEMPLATE
; *****************************************************************************************************************************
explosion:
    PUSH R1
    POP R1
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
    MOV R1, KEY_START_LINE      ; define a linha a ler (inicialmente a 1)
    MOV R3, KEY_LIN             ; endereço do periférico das linhas do teclado
    MOV R4, KEY_COL             ; endereço do periférico das colunas do teclado
    MOV R5, MASK_KEY            ; máscara para a leitura do teclado
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
    CMP R0, R11                         ; verifica se a tecla premida é igual à anterior
    JZ no_sound                         ; se sim o movimento é contínuo logo salta para no_sound para não tocar o som outra vez
    MOV R1, PACMAN_CHOMP                ; se não guarda o número do som pacman chomp em R1
    MOV [PLAY_MEDIA], R1                ; reproduz o som PACMAN_CHOMP
    no_sound:
        MOV R1, [PAC_LIN]               ; guarda em R1 a linha atual do pacman
        MOV R2, [PAC_COL]               ; guarda em R2 a coluna atual do pacman
        MOV R4, DEF_PACMAN              ; move para R4 a tabela que define o pacman de boca fechada
        CALL move_object                ; chama a função move_object
        MOV [PAC_LIN], R1               ; atualiza a linha atual do pacman
        MOV [PAC_COL], R2               ; atualiza a coluna atual do pacman

end_move:
    POP R8                          ; recupera os valores anteriores dos registos modificados
    POP R7
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
    PUSH R1
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
        POP R2
        POP R1
        RET

; *****************************************************************************************************************************
; PAUSE_GAME - Pauses the game.
; Atualiza o estado do jogo para PAUSED e seleciona um cenário frontal diferente para indicar visualmente que o jogo está em
; pausa. Para além disso pausa todos os sons.
; *****************************************************************************************************************************
pause_game:
    PUSH R1
    DI                                      ; desativa interrupções
    MOV [PAUSE_ALL_SOUND], R1               ; pausa a reprodução de todos os sons (o valor de R1 é irrelevante)          
    MOV R1, PAUSED_IMG                      ; guarda em R1 o nº da imagem de pausa
    MOV [SELECT_FRONT_IMG], R1              ; seleciona a imagem de pausa como o cenário frontal
    MOV R1, PAUSED                          ; guarda em R1 o valor do estado de jogo PAUSED
    MOV [GAME_STATE], R1                    ; atualiza o estado de jogo atual para PAUSED
    POP R1
    RET

; *****************************************************************************************************************************
; RESUME_GAME - Resume o jogo.
; Atualiza o estado do jogo para PLAYING e apaga o cenário frontal que diz PAUSED para indicar visualmente que o jogo saiu de
; pausa. Para além disso resume a reprodução da música de fundo PACMAN THEME.
; *****************************************************************************************************************************
resume_game:
    PUSH R1
    EI                                     ; reativa interrupções
    MOV R1, PACMAN_THEME                   ; guarda em R1 o nº do som PACMAN THEME
    MOV [RESUME_SOUND], R1                 ; resume a reprodução do som PACMAN THEME
    MOV R1, PAUSED_IMG                     ; guarda em R1 o nº da imagem de pausa
    MOV [DELETE_FRONT_IMG], R1             ; apaga a imagem de pausa como cenário frontal
    MOV R1, PLAYING                        ; guarda em R1 o valor do estado de jogo PLAYING
    MOV [GAME_STATE], R1                   ; atualiza o estado de jogo atual para PLAYING
    POP R1
    RET

; *****************************************************************************************************************************
; END_GAME - Termina o jogo.
; Atualiza o estado do jogo para GAME_OVER e muda o cenário de fundo para indicar visualmente que o jogo terminou. Toca o som
; de GAME OVER. Para de aceitar interrupções
; *****************************************************************************************************************************
end_game:
    PUSH R1
    DI                                     ; desativa interrupções
    DI0                                    ; desativa a interrupção a 0
    DI1                                    ; desativa a interrupção a 1
    DI2                                    ; desativa a interrupção a 2
    DI3                                    ; desativa a interrupção a 3
    MOV [DELETE_SCREEN], R1                ; apaga todos os pixels do ecrã (o valor de R1 é irrelevante)
    MOV R1, GHOSTS_GIF                     ; guarda em R1 o nº do video GHOSTS_GIF
    MOV [LOOP_MEDIA], R1                   ; reproduz em loop o video GHOSTS_GIF
    MOV R1, GAME_OVER_IMG                  ; guarda em R1 o nº do cenário frontal GAME_OVER_IMG
    MOV [SELECT_FRONT_IMG], R1             ; seleciona GAME_OVER_IMG como o cenário frontal
    MOV R1, GAME_OVER                      ; guarda em R1 o valor do estado GAME_OVER
    MOV [GAME_STATE], R1                   ; atualiza o estado atual do jogo para GAME_OVER
    POP R1
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
; INT_ROT_0 - Rotina de atendimento da interrupção 0.
;			  Usada para sinalizar que os fantasmas devem ser movidos.
; *****************************************************************************************************************************
int_rot_0:
    PUSH R1
    MOV R1, 1
    MOV [int_0], R1             ; sinaliza que a interrupção ocorreu
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_1 - Rotina de atendimento da interrupção 1
;			  Usada sinalizar que o contador tem de atualizado.
; *****************************************************************************************************************************
int_rot_1:
    PUSH R1
    MOV R1, 1
    MOV [int_1], R1             ; sinaliza que a interrupção ocorreu
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_2 - Rotina de atendimento da interrupção 2
;			  ???
; *****************************************************************************************************************************
int_rot_2:
    PUSH R1
    MOV R1, 1
    MOV [int_2], R1             ; sinaliza que a interrupção ocorreu
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_3 - Rotina de atendimento da interrupção 3
;			  ???
; *****************************************************************************************************************************
int_rot_3:
    PUSH R1
    MOV R1, 1
    MOV [int_3], R1             ; sinaliza que a interrupção ocorreu
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; GHOST_CYCLE - Escolhe que fantasmas se vão movimentar após uma interrupção e chama a função para os mexer.
;
; *****************************************************************************************************************************
ghost_cycle:
    PUSH R0
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    
    MOV R0, [int_0]             ; guarda em R0 o valor que indica a occurência da interrupção 0
    CMP R0, TRUE                ; se o valor for igual a TRUE (1), então a interrupção occureu
    JNZ exit_ghost_cycle        ; se não tiver occurido salta para o fim da rotina
    MOV R0, NUM_GHOSTS          ; move para R0 o nº de fantasmas atualmente em jogo
    CMP R0, 0                   ; determina se o número de fantasmas é 0
    JZ exit_ghost_cycle         ; se for 0 não há fantasmas para mexer, então sai da rotina
    MOV R3, DEF_GHOST           ; move o endereço da tabela que define a versão o fantasma para R3
    MOV R4, R3                  ; copia o endereco da tabela que define o fantasma para R4
    MOV R5, [PAC_LIN]           ; guarda em R5 a linha atual do pacman
    MOV R6, [PAC_COL]           ; guarda em R6 a coluna atual do pacman
    CALL ghost1                 ; se não, chama a função que movimenta automáticamente o fantasma 1
    CMP R0, 1                   ; determina se o número de fantasmas é 1
    JZ exit_ghost_cycle         ; se for 1 não há mais fantasmas para mexer, então sai da rotina
    CALL ghost2                 ; se não, chama a função que movimenta automáticamente o fantasma 2
    CMP R0, 2                   ; determina se o número de fantasmas é 2
    JZ exit_ghost_cycle         ; se for 2 não há mais fantasmas para mexer, então sai da rotina
    CALL ghost3                 ; se não, chama a função que movimenta automáticamente o fantasma 3
    CMP R0,3                    ; determina se o número de fantasmas é 3
    JZ exit_ghost_cycle         ; se for 3 não há mais fantasmas para mexer, então sai da rotina
    CALL ghost4                 ; se não, chama a função que movimenta automáticamente o fantasma 4

    exit_ghost_cycle:
        MOV R0, FALSE           ; guarda em R0 o valor FALSE (0)
        MOV [int_0], R0         ; repõem o indicador de occurência da interrupção a 0 uma vez que já lidámos com ela
        POP R6
        POP R5
        POP R4
        POP R3
        POP R0
        RET

; *****************************************************************************************************************************
; GHOST1 - Movimenta o fantasma 1 de forma automónoma verificando colisões.
;
; *****************************************************************************************************************************
ghost1:
    PUSH R1
    PUSH R2

    MOV R1, [GHOST1_LIN]        ; guarda em R1 a linha atual do fantasma 1 (pre movimento)
    MOV R2, [GHOST1_COL]        ; guarda em R2 a coluna atual do fantasma 1 (pre movimento)
    CALL choose_ghost_direction ; chama a função que escolhe em que direção o fantasma se mexe para se aproximar do pacman
    CALL move_object		    ; chama a função que move o fantasma
    MOV [GHOST1_LIN], R1        ; atualiza a memória com a nova linha atual do fantasma (pós movimento)
    MOV [GHOST1_COL], R2        ; atualiza a memória com a nova coluna atual do fantasma (pós movimento)

    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; GHOST2 - Movimenta o fantasma 2 de forma automónoma verificando colisões.
;
; *****************************************************************************************************************************
ghost2:
    PUSH R1
    PUSH R2

    MOV R1, [GHOST2_LIN]        ; guarda em R1 a linha atual do fantasma 1 (pre movimento)
    MOV R2, [GHOST2_COL]        ; guarda em R2 a coluna atual do fantasma 1 (pre movimento)
    CALL choose_ghost_direction ; chama a função que escolhe em que direção o fantasma se mexe para se aproximar do pacman
    CALL move_object		    ; chama a função que move o fantasma
    MOV [GHOST2_LIN], R1        ; atualiza a memória com a nova linha atual do fantasma (pós movimento)
    MOV [GHOST2_COL], R2        ; atualiza a memória com a nova coluna atual do fantasma (pós movimento)

    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; GHOST3 - Movimenta o fantasma 3 de forma automónoma verificando colisões.
;
; *****************************************************************************************************************************
ghost3:
    PUSH R1
    PUSH R2

    MOV R1, [GHOST3_LIN]        ; guarda em R1 a linha atual do fantasma 1 (pre movimento)
    MOV R2, [GHOST3_COL]        ; guarda em R2 a coluna atual do fantasma 1 (pre movimento)
    CALL choose_ghost_direction ; chama a função que escolhe em que direção o fantasma se mexe para se aproximar do pacman
    CALL move_object		    ; chama a função que move o fantasma
    MOV [GHOST3_LIN], R1        ; atualiza a memória com a nova linha atual do fantasma (pós movimento)
    MOV [GHOST3_COL], R2        ; atualiza a memória com a nova coluna atual do fantasma (pós movimento)

    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; GHOST4 - Movimenta o fantasma 4 de forma automónoma verificando colisões.
;
; *****************************************************************************************************************************
ghost4:
    PUSH R1
    PUSH R2

    MOV R1, [GHOST4_LIN]        ; guarda em R1 a linha atual do fantasma 1 (pre movimento)
    MOV R2, [GHOST4_COL]        ; guarda em R2 a coluna atual do fantasma 1 (pre movimento)
    CALL choose_ghost_direction ; chama a função que escolhe em que direção o fantasma se mexe para se aproximar do pacman
    CALL move_object		    ; chama a função que move o fantasma
    MOV [GHOST4_LIN], R1        ; atualiza a memória com a nova linha atual do fantasma (pós movimento)
    MOV [GHOST4_COL], R2        ; atualiza a memória com a nova coluna atual do fantasma (pós movimento)

    POP R2
    POP R1
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


; *****************************************************************************************************************************
; SCORE_CYCLE - Incrementa o contador dos pontos.
; INÊS ISTO TEM DE TER HAVER COM A INT ROT 1 DESACELERA ISTO
; *****************************************************************************************************************************
score_cycle:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    
    MOV R0, [int_1]             ; guarda em R0 o valor que indica a occurência da interrupção 1
    CMP R0, TRUE                ; se o valor for igual a TRUE (1), então a interrupção occureu
    JNZ exit_score_cycle        ; se não tiver occurido salta para o fim da rotina
    MOV R0, SCORE               ; obtém o endereço da pontuação atual
    MOV R1, [R0]                ; obtém o valor da pontuação atual
    MOV R2, UPPER_LIMIT         ; obtém o valor do limite superior
    CMP R1, R2                  ; determina se o valor atual é o limite superior
    JZ exit_score_cycle         ; se for, sai da rotina, sem alterar a pontuação
    ADD R1, 1                   ; caso contrário, incrementa a pontuação por 1
    MOV R3, MASK_LSD            ; copia a máscara das unidades para R3
    MOV R4, R1                  ; copia valor da pontuação para R4
    AND R4, R3                  ; máscara para obter o digito menos significativo de R4
    MOV R2, 0AH                 ; copia para R2 o valor hexadecimal A 
    CMP R4, R2                  ; verifica se o digito menos significativo é 10 (hex 'A')
    JZ skip_hex                 ; se sim salta para jump_hex que irá saltar à frente os valores A-F
    MOV [DISPLAYS], R1          ; se não, atualiza o display
    MOV [R0], R1                ; guarda o novo valor na memória
    JMP exit_score_cycle        ; salta para o fim da rotina
    
    skip_hex:
        ADD R1, 6               ; adiciona 6 ao contador para saltar os valores de A - F
        MOV R3, MASK_TENS       ; copia a máscara das dezenas para R3
        MOV R4, R1              ; copia o valor do contador para R4
        AND R4, R3              ; aplica a máscara das dezenas
        MOV R2, 0A0H            ; copia para R2 o valor hexadecimal 0A0H
        CMP R4, R2              ; verifica se as dezenas estão a A
        JZ jump_hundreds        ; se sim salta para jump_hundreds que irá incrementar para 256H que mostra 100 nos displays
        MOV [DISPLAYS], R1      ; atualiza o display
        MOV [R0], R1            ; guarda o novo valor na memória
        JMP exit_score_cycle    ; salta para o fim da rotina

    jump_hundreds:
        MOV R3, 96              ; copia 96 para R3
        ADD R1, R3              ; adiciona o valor de R3(96) a R1
        MOV [DISPLAYS], R1      ; atualiza o display
        MOV [R0], R1            ; guarda o novo valor na memória
        JMP exit_score_cycle    ; salta para o fim da rotina

    exit_score_cycle:
        MOV R0, FALSE           ; guarda em R0 o valor FALSE (0)
        MOV [int_0], R0         ; repõem o indicador de occurência da interrupção a 0 uma vez que já lidámos com ela
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET