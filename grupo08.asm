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

DEFINE_LINE    		   EQU 600AH       ; endereço do comando para definir a linha
DEFINE_COLUMN   	   EQU 600CH       ; endereço do comando para definir a coluna
DEFINE_PIXEL    	   EQU 6012H       ; endereço do comando para escrever um pixel
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

MIN_COL		           EQU  0		   ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COL		           EQU  63         ; número da coluna mais à direita que o objeto pode ocupar

PAC_HEIGHT             EQU 5           ; altura do pacman
PAC_WIDTH		       EQU 4		   ; largura do pacman
YELLOW_PIXEL           EQU 0FFF0H	   ; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)

GHOST_HEIGHT           EQU 4           ; altura do fantasma
GHOST_WIDTH		       EQU 4		   ; largura do fantasma
GREEN_PIXEL            EQU 0F0A5H	   ; cor do pixel: verde em ARGB (opaco no máximo, verde a 10, azul a 5 e vermelho a 0)

CANDY_HEIGHT           EQU 4           ; altura do rebuçado
CANDY_WIDTH            EQU 4           ; largura do rebuçado
RED_PIXEL              EQU 0FF00H      ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

EXPLOSION_HEIGHT       EQU 5           ; altura da explosão
EXPLOSION_WIDTH        EQU 5           ; largura da explosão
CYAN_PIXEL             EQU 0F4FFH      ; cor do pixel: ciano em ARGB (opaco, verde e azul no máximo, vermelho a 4)

BOX_HEIGHT             EQU 8           ; altura da caixa
BOX_WIDTH		       EQU 12		   ; largura da caixa
BLUE_PIXEL             EQU 0F469H	   ; cor do pixel: azul em ARGB (opaco e azul a 9, verde a 6 e vermelho a 4)

; *****************************************************************************************************************************
; * Dados 
; *****************************************************************************************************************************
    PLACE 1000H

pilha:
    STACK 100H  ; espaço reservado para a pilha (200H bytes, pois são 100H words)

SP_initial:     ; este é o endereço (1200H) com que o SP deve ser inicializado.
                ; O 1.º end. de retorno será armazenado em 11FEH (1200H-2)

DEFINE_PACMAN:  ; tabela que define o pacman (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YELLOW_PIXEL, YELLOW_PIXEL, 0	                        ;  ## 
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; ####   
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; ####   
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; #### 
	WORD		0, YELLOW_PIXEL, YELLOW_PIXEL, 0	                        ;  ## 

DEFINE_OPEN_PACMAN_RIGHT:  ; tabela que define o pacman com a boca aberta para a direita (altura, largura, pixels, cor)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
	WORD		0, YELLOW_PIXEL, YELLOW_PIXEL, 0	                        ;  ## 
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; ####   
    WORD		YELLOW_PIXEL, 0, 0, 0		                                ; #   
    WORD		YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL, YELLOW_PIXEL		; #### 
	WORD		0, YELLOW_PIXEL, YELLOW_PIXEL, 0	                        ;  ## 

DEFINE_GHOST:   ; tabela que define o fantasma (altura, largura, pixels, cor)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, GREEN_PIXEL, GREEN_PIXEL, 0                              ;  ## 
    WORD        GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL          ; ####
    WORD        GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL, GREEN_PIXEL          ; ####
    WORD        GREEN_PIXEL, 0, 0, GREEN_PIXEL                              ; #  #

DEFINE_CANDY:   ; tabela que define o rebuçado (altura, largura, pixels, cor)
    WORD        CANDY_HEIGHT
    WORD        CANDY_WIDTH
    WORD        0, 0, 0, RED_PIXEL                                          ;    #
    WORD        0, RED_PIXEL, RED_PIXEL, 0                                  ;  ## 
    WORD        0, RED_PIXEL, RED_PIXEL, 0                                  ;  ##
    WORD        RED_PIXEL, 0, 0, 0                                          ; #

DEFINE_EXPLOSION:   ; tabela que define a explosão (altura, largura, pixels, cor)
    WORD        EXPLOSION_HEIGHT
    WORD        EXPLOSION_WIDTH
    WORD        CYAN_PIXEL, 0, 0, 0, CYAN_PIXEL                              ; #   #
    WORD        0, CYAN_PIXEL, 0, CYAN_PIXEL, 0                              ;  # # 
    WORD        0, 0, CYAN_PIXEL, 0, 0                                       ;   #  
    WORD        0, CYAN_PIXEL, 0, CYAN_PIXEL, 0                              ;  # # 
    WORD        CYAN_PIXEL, 0, 0, 0, CYAN_PIXEL                              ; #   #

DEFINE_BOX:     ; tabela que define a caixa onde nasce o pacman (altura, largura, pixels, cor)
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
    MOV R4, DEFINE_BOX                  ; endereço da tabela que define a caixa     
    CALL draw_object                    ; chama a função para desenhar a caixa

pacman_position:
    MOV R1, START_LIN                   ; linha inicial do pacman
    MOV R2, START_COL                   ; coluna inicial do pacman
    MOV R4, DEFINE_OPEN_PACMAN_RIGHT    ; endereço da tabela que define o pacman

show_pacman:
    CALL draw_object                    ; chama a função para desenhar o pacman

ghost_position:
    MOV R1, GHOST_LIN                   ; linha inicial do fantasma
    MOV R2, GHOST_COL                   ; coluna inicial do fantasma
    MOV R4, DEFINE_GHOST                ; endereço da tabela que define o fantasma

show_ghost:
    CALL draw_object                    ; chama a função para desenhar o fantasma

MOV R4, DISPLAYS                        ; guarda o endereço do periférico dos displays em R4
MOV R11, INITIAL_COUNTER                ; inicializa o contador a 0
MOV [R4], R11                           ; põe o valor do contador no display
MOV R10, 0                              ; inicializa R10 a 0

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
	MOV  [DEFINE_LINE], R1		; seleciona a linha
	MOV  [DEFINE_COLUMN], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
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
    MOV R8, R2                  ; cria cópia do numero da coluna em que o objeto vai ser desenhado
    MOV R9, R6                  ; cria cópia da largura do objeto 

draw_rows:
    MOV R7, R5                  ; contador linhas que faltam desenhar
    draw_pixels:
        MOV R3, [R4]            ; obtém a cor do próximo pixel do objeto
        CALL write_pixel        ; chama a função que desenha cada pixel do objeto
        ADD R4, 2               ; obtem o endereço da cor do próximo pixel
        ADD R2, 1               ; próxima coluna
        SUB R6, 1               ; diminui contador do numero de pixels que faltam desenhar nesta linha
        JNZ draw_pixels
    MOV R2, R8                  ; reset valor coluna
    MOV R6, R9                  ; reset contador pixels que faltam desenhar numa linha
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

    MOV R0, 0                   ; inicializa R0 para guardar a tecla pressionada
    MOV R2, TEC_L               ; endereço do periférico das linhas do teclado
    MOV R3, TEC_C               ; endereço do periférico das colunas do teclado
    MOV R5, MASK_TEC            ; máscara para a leitura do teclado

    reset_line: 
        MOV R1, LINHA           ; define a linha a ler (inicialmente a 1)
        MOV R7, 0               ; inicializa o contador de linhas a 0

    check_key:
        MOVB [R2], R1           ; ativa a linha para leitura do teclado
        MOVB R0, [R3]           ; lê a coluna do teclado
        AND R0, R5              ; aplica a máscara
        CMP R0, 0               ; verifica se alguma tecla foi pressionada
        JZ next_line            ; se nenhuma tecla foi pressionada, passa para a próxima linha
        PUSH R0                 ; guarda a coluna pressionada
        MOV	R8, 0			    ; som com número 0
        MOV [PLAY_SOUND], R8    ; comando para tocar o som
        JMP is_key_pressed      ; caso contrário, espera que a tecla deixe de ser pressionada

    next_line:
        SHL R1, 1               ; passa para a próxima linha do teclado
        INC R7                  ; incrementa o contador de linhas
        CMP R7, 4               ; verifica se já leu todas as linhas
        JNZ check_key           ; se não leu todas as linhas, verifica a próxima
        JMP reset_line          ; caso contrário, volta para a 1ª linha

    is_key_pressed: 
        CALL keyboard_counter   ; chama a função que incrementa ou decrementa o contador
        MOVB [R2], R1           ; ativa a linha para leitura do teclado
        MOVB R0, [R3]           ; lê a coluna do teclado
        AND R0, R5              ; aplica a máscara
        CMP R0, 0               ; verifica se a tecla foi libertada
        JNZ is_key_pressed      ; se não foi libertada, espera que seja

    POP R0                      ; recupera a coluna pressionada
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
; KEYBOARD_COUNTER - Incrementa ou decrementa o contador com base na tecla pressionada e atualiza o display
; Argumentos:   R0 - valor da coluna pressionada
;               R1 - valor da linha pressionada
;               R11 - valor atual do contador 
;
; Retorna:      R11 - valor atualizado do contador
; *****************************************************************************************************************************
keyboard_counter:
    PUSH R1                 ; guarda os valores anteriores dos registos que são alterados nesta função
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    MOV R5, 500             ; inicializa R5 com o valor de iterações para delay
    MOV R6, TEC_INCREMENTA  ; inicializa R6 com o endereço do display
    MOV R7, TEC_DECREMENTA  ; inicializa R7 com o valor da tecla que incrementa o contador
    MOV R8, MAX_COUNTER     ; inicializa R8 com o valor da tecla que decrementa o contador
    MOV R9, MIN_COUNTER     ; inicializa R9 com o valor máximo do contador
    SHL R1, 4               ; coloca linha nibble high
    OR R1, R0               ; juntamos a coluna (nibble low)
    CMP R1, R6              ; verificamos se é a tecla que incrementa
    JZ counter_increment    ; incrementa o contador
    CMP R1, R7              ; verificamos se é a tecla que decrementa
    JZ counter_decrement    ; decrementa o contador
    JMP counter_end         ; salta para o fim da rotina
    
    counter_increment:
        CMP R11, R8         ; verifica se o contador está no maior valor possível
        JZ counter_end      ; se sim, não incrementa e salta para o fim da rotina
        CMP R10, R5         ; compara R10 com R5
        JNZ delay_i         ; se R10 não for igual a R5 salta para delay_i
        MOV R10, 0          ; reinicializa R10
        ADD R11, 1          ; se não, incrementa o contador por 1
        MOV R3, MASK_LSD    ; copia a máscara das unidades para R3
        MOV R4, R11         ; copia valor do contador para R4
        AND R4, R3          ; máscara para ter o digito menos significativo de R4
        MOV R2, 0AH         ; copia para R2 o valor hexadecimal A 
        CMP R4, R2          ; verifica se o digito menos significativo é 10 (hex 'A')
        JZ salta_hexa_inc   ; se sim salta para salta_hexa que irá saltar à frente os valores A-F
        MOV [DISPLAYS], R11 ; se não, atualiza o display
        JMP counter_end     ; salta para o fim da rotina
    delay_i:
        ADD R10, 1          ; incrementa R10 por 1
        JMP counter_end     ; salta para o fim da rotina
    
    salta_hexa_inc:
        ADD R11, 6          ; adiciona 6 ao contador para saltar os valores de A - F
        MOV R3, MASK_TENS   ; copia a máscara das dezenas para R3
        MOV R4, R11         ; copia o valor do contador para R4
        AND R4, R3          ; aplica a máscara das dezenas
        MOV R2, 0A0H        ; copia para R2 o valor hexadecimal 0A0H
        CMP R4, R2          ; verifica se as dezenas estão a A
        JZ salta_max_inc    ; se sim salta para salta_mac_inc que irá incrementar para 256H que mostra 100 nos displays
        MOV [DISPLAYS], R11 ; atualiza o display
        JMP counter_end     ; salta para o fim da rotina

    salta_max_inc:
        MOV R3, 96          ; copia 96 para R3
        ADD R11, R3         ; adiciona o valor de R3(96) a R11
        MOV [DISPLAYS], R11 ; atualiza o display
        JMP counter_end     ; salta para o fim da rotina

    counter_decrement:
        CMP R11, R9         ; verifica se o contador está no valor mínimo
        JZ counter_end      ; se sim, não decrementa e salta para o fim da rotina
        CMP R10, R5         ; compara R10 com R5
        JNZ delay_d         ; se R10 não for igual a R5, salta para delay_d
        MOV R10, 0          ; reinicializa R10
        SUB R11, 1          ; se não, decrementa o contador por 1
        MOV R3, MASK_LSD    ; copia a máscara para R3
        MOV R4, R11         ; copia o valor do contador para R4
        AND R4, R3          ; aplica a máscara para isolar o dígito menos significativo
        MOV R2, 0FH         ; copia para R2 o valor hexadecimal F 
        CMP R4, R2          ; verifica se o dígito menos significativo é 10 (hex 'F')
        JZ salta_hexa_dec   ; se sim, salta os valores F-A
        MOV [DISPLAYS], R11 ; atualiza o display
        JMP counter_end     ; salta para o fim da rotina
    
    delay_d:
        ADD R10, 1          ; incrementa R10 por 1
        JMP counter_end     ; salta para o fim da rotina

    salta_hexa_dec:
        SUB R11, 6          ; subtrai 7 ao contador para saltar os valores de F-A
        MOV R3, MASK_TENS   ; copia a máscara das dezenas para R3
        MOV R4, R11         ; copia o valor do contador para R4
        AND R4, R3          ; aplica a máscara das dezenas
        MOV R2, 0F0H        ; copia para R2 o valor hexadecimal 0A0H
        CMP R4, R2          ; verifica se as dezenas estão a A
        JZ salta_max_dec    ; se sim salta para salta_mac_inc que irá decrementar para 99H
        MOV [DISPLAYS], R11 ; atualiza o display
        JMP counter_end     ; salta para o fim da rotina

    salta_max_dec:
        MOV R3, 96          ; copia 96 para R3
        SUB R11, R3         ; subtrai o valor de R3(96) a R11
        MOV [DISPLAYS], R11 ; atualiza o display
        JMP counter_end     ; salta para o fim da rotina

    counter_end:
        POP R9              ; recupera os valores anteriores dos registos modificados
        POP R8
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        RET