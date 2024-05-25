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
NUM_GHOSTS             EQU 3FE8H       ; endereço do número de fantasmas atualmente em jogo

; MediaCenter
DEF_LINE    		   EQU 600AH       ; endereço do comando para definir a linha
DEF_COLUMN   	       EQU 600CH       ; endereço do comando para definir a coluna
DEF_PIXEL    	       EQU 6012H       ; endereço do comando para escrever um pixel
GET_PIXEL_COLOR        EQU 6010H       ; endereço do comando para obter a cor de um pixel
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
MASK_TEC               EQU 0FH         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; Contador
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
    MOV R0, START_MENU_IMG              ; move para R0 o nº do cenário de fundo 
    MOV [SELECT_BACKGROUND_IMG], R0     ; seleciona o cenário de fundo       
    MOV R0, PACMAN_THEME                ; guarda o nº do som da música do pacman
    MOV [LOOP_MEDIA], R0                ; reproduz em loop a música do pacman
    MOV R0, GAME_STATE                  ; move para R0 o endereço na memória que contém o estado atual do jogo
    MOV R1, INITIAL                     ; move para R1 o nº que representa o estado inicial
    MOV [R0], R1                        ; guarda na memória o estado_autal do jogo como INITIAL

waiting_press_start:
    CALL keyboard                       ; chama a função do teclado para indentificar as teclas pressionadas e executar os comandos às teclas associados
    MOV R1, PLAYING                     ; move para R1 o nº que representa o estado PLAYING
    MOV R2, [R0]                        ; move para R2 o estado atual do jogo
    CMP R1, R2                          ; compara o estado atual do jogo com o estado PLAYING
    JNZ waiting_press_start             ; repete o ciclo enquanto o jogo não estiver PLAYING

CALL draw_center_box                    ; quando o jogo começa (estado = PLAYING) chama a função draw_center_box para desenhar a caixa central

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

EI                                      ; ativar interrupções

main: ; ciclo principal
    CALL keyboard                       ; chama a função do teclado para indentificar as teclas pressionadas e executar os comandos às teclas associados
    CALL ghost_cycle                    ; chama a função que anima os fantasmas
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
    MOV R1, GHOST_START_LIN             ; se não, obtém o valor da linha inicial dos fantasmas
    MOV R2, GHOST1_START_COL            ; valor da coluna inicial do fantasma 1
    MOV R3, GHOST1_LIN                  ; endereço da linha atual do fantasma 1
    MOV R4, GHOST1_COL                  ; endereço da coluna inicial do fantasma 1
    CALL init_ghost                     ; chama a função que inicializa fantasmas
    MOV R2, 1                           ; guarda o valor 1 pois 1 fantasma já foi libertado
    MOV [R0], R2                         ; atualiza o número de fantasmas em jogo para 1

    init_ghost_2:
        CMP R5, 1                       ; verifica se o número máximo de fantasmas permitidos é 1
        JZ spawn_ghosts_end             ; se sim salta para o fim da rotina sem lançar mais nenhum fantasma
        MOV R2, GHOST2_START_COL        ; se não, obtém o valor da coluna inicial do fantasma 2
        MOV R3, GHOST2_LIN              ; endereço da linha atual do fantasma 2
        MOV R4, GHOST2_COL              ; endereço da coluna inicial do fantasma 2
        CALL init_ghost                 ; chama a função que inicializa fantasmas
        MOV R2, 2                       ; guarda o valor 2 pois 2 fantasmas já foram libertados
        MOV [R0], R2                    ; atualiza o número de fantasmas em jogo para 2

    init_ghost_3:
        CMP R5, 2                       ; verifica se o número máximo de fantasmas permitidos é 2
        JZ spawn_ghosts_end             ; se sim salta para o fim da rotina sem lançar mais nenhum fantasma
        MOV R2, GHOST3_START_COL        ; se não, obtém o valor da coluna inicial do fantasma 3
        MOV R3, GHOST3_LIN              ; endereço da linha atual do fantasma 3
        MOV R4, GHOST3_COL              ; endereço da coluna inicial do fantasma 3
        CALL init_ghost                 ; chama a função que inicializa fantasmas
        MOV R2, 3                       ; guarda o valor 3 pois 3 fantasmas já foram libertados
        MOV [R0], R2                     ; atualiza o número de fantasmas em jogo para 3

    init_ghost_4:
        CMP R5, 3                       ; verifica se o número máximo de fantasmas permitidos é 3
        JZ spawn_ghosts_end             ; se sim salta para o fim da rotina sem lançar mais nenhum fantasma
        MOV R2, GHOST4_START_COL        ; se não, obtém o valor da coluna inicial do fantasma 4
        MOV R3, GHOST4_LIN              ; endereço da linha atual do fantasma 4
        MOV R4, GHOST4_COL              ; endereço da coluna inicial do fantasma 4
        CALL init_ghost                 ; chama a função que inicializa fantasmas
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
; INIT_GHOST - Inicializa um fantasma no programa
; Argumentos: 
;               R1 - linha inicial
;               R2 - coluna inicial
;               R3 - linha
;               R4 - coluna
;
; *****************************************************************************************************************************
init_ghost:
    MOV [R3], R1                        ; guarda na RAM a linha atual do fantasma (de momento a inicial)
    MOV [R4], R2                        ; guarda na RAM a coluna atual do fantasma (de momento a inicial)
    MOV R4, DEF_GHOST                   ; endereço da tabela que define o fantasma
    CALL draw_object                    ; chama a função para desenhar o fantasma
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
; DRAW_CENTER_BOX - Desenha a caixa central onde nasce o pacman
;
; *****************************************************************************************************************************
draw_center_box:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7

    MOV R1, BOX_LIN                     ; linha inicial da caixa
    MOV R2, BOX_COL                     ; coluna inicial da caixa
    MOV R3, BLUE                        ; guarda cor pixel
    MOV R4, BOX_HEIGHT                  ; altura da caixa
    SUB R4, 1                           ; 
    MOV R5, BOX_WIDTH                   ; largura da caixa
    SUB R5, 1                           ;
    MOV R7, R4                          ;

draw_vertical_lines:
    CALL write_pixel                    ; chama a função para pintar o pixel
    ADD R2, R5                          ;
    CALL write_pixel                    ; chama a função para pintar o pixel
    SUB R2, R5                          ;
    ADD R1, 1                           ;
    SUB R7, 1                           ;
    JNZ draw_vertical_lines             ;
    MOV R1, BOX_LIN                     ;
    MOV R2, BOX_COL                     ;
    MOV R7, 3                           ;

draw_horizontal_lines:
    CALL write_pixel                    ; chama a função para pintar o pixel
    ADD R1, R4                          ;
    CALL write_pixel                    ; chama a função para pintar o pixel
    SUB R1, R4                          ;
    ADD R2, 1                           ;
    SUB R7, 1                           ;
    JNZ draw_horizontal_lines           ;
    ADD R2, 6                           ;
    MOV R7, 3                           ;
    draw_second_half:
        CALL write_pixel                ; chama a função para pintar o pixel
        ADD R1, R4                      ;
        CALL write_pixel                ; chama a função para pintar o pixel
        SUB R1, R4                      ;
        ADD R2, 1                       ;
        SUB R7, 1                       ;
        JNZ draw_second_half            ;
    
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
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
    PUSH    R5
    PUSH    R6
    PUSH    R7
    PUSH    R8
    PUSH    R9
    PUSH    R10
    PUSH    R11
    MOV R5, [R4]                ; obtém a altura objeto
    MOV R6, [R4+2]              ; obtém a largura objeto
    MOV R11, BLUE               ; guarda o valor ARGB dos limites                  
    ADD R1, R7                  ; soma à linha o valor do eventual movimento
    ADD R2, R8                  ; soma à coluna o valor do eventual movimento

check_top_pixels:
    MOV R9, R6
    SUB R9, 1
    next_top_pixel:
    MOV  [DEF_LINE], R1		    ; seleciona a linha
	MOV  [DEF_COLUMN], R2	    ; seleciona a coluna
	MOV  R10, [GET_PIXEL_COLOR]	; vê a cor do pixel na linha e coluna já selecionadas 
    CMP R10, R11
    JZ over_limit
    ADD R2, 1
    SUB R9, 1
    JZ check_right_pixels
    JMP next_top_pixel

check_right_pixels:
    MOV R9, R5
    SUB R9, 1
    next_right_pixel:
    MOV  [DEF_LINE], R1		    ; seleciona a linha
	MOV  [DEF_COLUMN], R2	    ; seleciona a coluna
	MOV  R10, [GET_PIXEL_COLOR]	; vê a cor do pixel na linha e coluna já selecionadas 
    CMP R10, R11
    JZ over_limit
    ADD R1, 1
    SUB R9, 1
    JZ check_bottom_pixels
    JMP next_right_pixel

check_bottom_pixels:
    MOV R9, R6
    SUB R9, 1
    next_bottom_pixel:
    MOV  [DEF_LINE], R1		    ; seleciona a linha
	MOV  [DEF_COLUMN], R2	    ; seleciona a coluna
	MOV  R10, [GET_PIXEL_COLOR]	; vê a cor do pixel na linha e coluna já selecionadas 
    CMP R10, R11
    JZ over_limit
    SUB R2, 1
    SUB R9, 1
    JZ check_left_pixels
    JMP next_bottom_pixel

check_left_pixels:
    MOV R9, R5
    SUB R9, 1
    next_left_pixel:
    MOV  [DEF_LINE], R1		    ; seleciona a linha
	MOV  [DEF_COLUMN], R2	    ; seleciona a coluna
	MOV  R10, [GET_PIXEL_COLOR]	; vê a cor do pixel na linha e coluna já selecionadas 
    CMP R10, R11
    JZ over_limit
    SUB R1, 1
    SUB R9, 1
    JZ not_over_limits
    JMP next_left_pixel    

over_limit:
    MOV R0, TRUE
    JMP exit_limit_tests

not_over_limits:
    MOV R0, FALSE
    JMP exit_limit_tests

exit_limit_tests:
    POP     R11
    POP     R10
    POP     R9
    POP     R8
    POP     R7
    POP     R6
    POP     R5
    POP     R2
    POP     R1
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

    MOV R3, KEY_START_LINE      ; define a linha a ler (inicialmente a 1)
    MOV R0, 0                   ; inicializa R0 para guardar a tecla pressionada
    MOV R4, KEY_LIN             ; endereço do periférico das linhas do teclado
    MOV R5, KEY_COL             ; endereço do periférico das colunas do teclado
    MOV R7, MASK_TEC            ; máscara para a leitura do teclado
    MOV R9, 0                   ; inicializa o contador de linhas a 0

    check_key:
        MOVB [R4], R3           ; ativa a linha para leitura do teclado
        MOVB R0, [R5]           ; lê a coluna do teclado
        AND R0, R7              ; aplica a máscara
        CMP R0, 0               ; verifica se alguma tecla foi pressionada
        JZ next_line            ; se nenhuma tecla foi pressionada, passa para a próxima linha
        MOV	R10, 0			    ; som com número 0
        MOV [PLAY_MEDIA], R10   ; comando para tocar o som
        JMP is_key_pressed      ; caso contrário, espera que a tecla deixe de ser pressionada

    next_line:
        SHL R3, 1               ; passa para a próxima linha do teclado
        INC R9                  ; incrementa o contador de linhas
        CMP R9, 4               ; verifica se já leu todas as linhas
        JNZ check_key           ; se não leu todas as linhas, verifica a próxima
        JMP exit_keyboard

    is_key_pressed:
        CALL game_state_key     ; chama uma função para detetar se a tecla pressionada é uma tecla que altera o estado do jogo
        MOV R8, PLAYING
        MOV R9, GAME_STATE
        MOV R10, [R9]
        CMP R10, R8
        JNZ exit_keyboard
        CALL movement_key       ; chama uma função para detetar se a tecla pressionada é uma tecla de movimento

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
; MOVEMENT_KEY - ????
; Argumentos:   ????
;
; Retorna:      
; *****************************************************************************************************************************
movement_key:
    PUSH R3                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, DELAY               ; inicializa R5 com o valor de iterações para delay

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
; GAME_STATE_KEY - ????
; Argumentos:   ????
;
; Retorna:      
; *****************************************************************************************************************************
game_state_key:
    PUSH R3                     ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R4
    PUSH R5
    PUSH R6

    ; Key mappings
    SHL R3, 4                   ; coloca linha nibble high
    OR R3, R0                   ; juntamos a coluna (nibble low)
    MOV R4, GAME_STATE
    MOV R5, [R4]
    MOV R6, START_KEY           ; move para R6 o valor hexadecimal que representa o movimento UP/LEFT
    CMP R3, R6
    JZ start_key_pressed
    MOV R6, PAUSE_KEY
    CMP R3, R6
    JZ pause_key_pressed
    MOV R6, END_GAME_KEY
    CMP R3, R6
    JZ end_game_key_pressed
    JMP exit_state_key

    start_key_pressed:
        CMP R5, INITIAL
        JNZ exit_state_key
        MOV R6, PLAYING
        MOV [R4], R6
        MOV R6, GAME_BACKGROUND             ; move para R0 o nº do cenário de fundo 
        MOV [SELECT_BACKGROUND_IMG], R6     ; seleciona o cenário de fundo       
        JMP exit_state_key
    
    pause_key_pressed:
        CMP R5, PLAYING
        JZ pausing_game
        MOV R6, PAUSED
        CMP R5, R6
        JZ resuming_game
        JMP exit_state_key

    pausing_game:
        CALL pause_game
        JMP exit_state_key

    resuming_game:
        CALL resume_game
        JMP exit_state_key

    end_game_key_pressed:
        MOV R6, PLAYING
        CMP R5, R6
        JZ ending_game
        MOV R6, PAUSED
        CMP R5, R6
        JZ ending_game
        JMP exit_state_key

    ending_game:
        CALL end_game

    exit_state_key:
        POP R6                  ; recupera os valores anteriores dos registos modificados
        POP R5
        POP R4
        POP R3
        RET

; *****************************************************************************************************************************
; PAUSE_GAME - Pauses the game
; To be implemented???
; *****************************************************************************************************************************
pause_game:
    PUSH R1 
    PUSH R2

    MOV [PAUSE_ALL_SOUND], R1
    MOV R1, PAUSED_IMG
    MOV R2, SELECT_FRONT_IMG
    MOV [R2], R1
    MOV R1, PAUSED
    MOV R2, GAME_STATE
    MOV [R2], R1
    
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; RESUME_GAME - Resumes the game
; *****************************************************************************************************************************
resume_game:
    PUSH R1 
    PUSH R2
    MOV R1, PAUSED_IMG
    MOV R2, DELETE_FRONT_IMG
    MOV [R2], R1
    MOV R1, PLAYING
    MOV R2, GAME_STATE
    MOV [R2], R1
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; END_GAME - Ends the game
; *****************************************************************************************************************************
end_game:
    PUSH R1
    PUSH R2
    DI0
    DI
    MOV R1, DELETE_SCREEN
    MOV [R1], R2
    MOV R1, LOOP_MEDIA
    MOV R2, GHOSTS_GIF
    MOV [R1], R2
    MOV R1, GAME_OVER_IMG
    MOV R2, SELECT_FRONT_IMG
    MOV [R2], R1
    MOV R1, GAME_OVER
    MOV R2, GAME_STATE
    MOV [R2], R1
    POP R2
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
    MOV [int_0], R1
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_1 - Rotina de atendimento da interrupção 1
;			  ???
; *****************************************************************************************************************************
int_rot_1:
    PUSH R1
    MOV R1, 1
    MOV [int_1], R1
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_2 - Rotina de atendimento da interrupção 2
;			  ???
; *****************************************************************************************************************************
int_rot_2:
    PUSH R1
    MOV R1, 1
    MOV [int_2], R1
    POP R1
    RFE                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_3 - Rotina de atendimento da interrupção 3
;			  ???
; *****************************************************************************************************************************
int_rot_3:
    PUSH R1
    MOV R1, 1
    MOV [int_3], R1
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
; GHOST_1 - Movimenta o fantasma 1 de forma automónoma verificando colisões.
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
; GHOST_2 - Movimenta o fantasma 2 de forma automónoma verificando colisões.
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
; GHOST_3 - Movimenta o fantasma 3 de forma automónoma verificando colisões.
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
; GHOST_4 - Movimenta o fantasma 4 de forma automónoma verificando colisões.
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