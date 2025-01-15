; *****************************************************************************************************************************
; * Group 08 Computer Architecture Class Project - Pac-Man Modified
; * Module:    projeto.asm
; * Description: This program runs a modified version of pac-man, the objective is two eat the 4 pieces of candy without being
;                caught by a ghost.
; * Collaborators: @inesiscosta, @mc8mac, @S3nutna
; *****************************************************************************************************************************

; *****************************************************************************************************************************
; * Constants
; *****************************************************************************************************************************
TRUE                   EQU 1                    ; numeric value to represent TRUE (1)
FALSE                  EQU 0                    ; numeric value to represent FALSE (0)
DELAY                  EQU 05000H               ; number of delay cycles to slow down the movement animation
DISPLAYS               EQU 0A000H               ; address of the 7-segment displays (POUT-1 peripheral)
MAX_GHOSTS             EQU 4                    ; maximum number of ghosts allowed in the game (0-4)
INITAL_NUM_GHOSTS      EQU 0                    ; number of ghosts initially in the game
NUM_COL                EQU 64                   ; decimal number of columns on the screen
MIDDLE_LIN             EQU 10H                  ; hexadecimal number for the middle row of the screen
MIDDLE_COL             EQU 20H                  ; hexadecimal number for the middle column of the screen
GHOST_RYTHM            EQU 6                    ; change the value to change the speed of ghost evolution ((clock * GHOST_RYTHM) / 1000 = ghost evolution in seconds, clock = 500 ms)

; MediaCenter
DEF_LINE               EQU 600AH                ; address of the command to define the line
DEF_COLUMN             EQU 600CH                ; address of the command to define the column
DEF_COLOR              EQU 6014H                ; address of the command to define the color to use
DEF_PIXEL              EQU 6012H                ; address of the command to write a pixel
DEF_8_PIXELS           EQU 601CH                ; address of the command to write in 8 pixels
GET_COLOR              EQU 6010H                ; address of the command to get the color of a pixel
DELETE_WARNING         EQU 6040H                ; address of the command to delete the warning of no scenario selected
DELETE_SCREEN          EQU 6002H                ; address of the command to delete all pixels already drawn
SELECT_BACKGROUND_IMG  EQU 6042H                ; address of the command to select a background image
SELECT_FRONT_IMG       EQU 6046H                ; address of the command to select a front image
DELETE_FRONT_IMG       EQU 6044H                ; address of the command to delete the front scenario
SELECT_MEDIA           EQU 6048H                ; address of the command to select a sound/video for the following commands
PLAY_MEDIA             EQU 605AH                ; address of the command to play sound
LOOP_MEDIA             EQU 605CH                ; address of the command to loop the specified sound or video
PAUSE_SOUND            EQU 605EH                ; address of the command to pause the playback of the specified sound or video
PAUSE_ALL_SOUND        EQU 6062H                ; address of the command to pause the playback of all sounds or videos
RESUME_SOUND           EQU 6006H                ; address of the command to resume the playback of the specified sound or video
STOP_MEDIA             EQU 6066H                ; address of the command to stop the playback of the specified sound or video
STOP_ALL_MEDIA         EQU 6068H                ; address of the command to stop the playback of all sounds/videos

; Images
START_MENU_IMG         EQU 0                    ; image for the start screen
GAME_BACKGROUND        EQU 1                    ; image for the game background
PAUSED_IMG             EQU 2                    ; front image for when the game is paused
GAME_OVER_IMG          EQU 3                    ; front image for when the player loses
TIME_LIMIT_IMG         EQU 4                    ; front image for when the player loses due to time
VICTORY_IMG            EQU 5                    ; background image for victory

; Sounds / GIFs
PACMAN_THEME           EQU 0                    ; game music
PACMAN_CHOMP           EQU 1                    ; sound of pacman moving
GHOSTS_GIF             EQU 2                    ; GAME OVER GIF
GAME_OVER_SOUND        EQU 3                    ; game over sound
WIN_SOUND              EQU 4                    ; victory sound
EAT_CANDY              EQU 5                    ; sound of eating candy

; Controls
UP_LEFT_KEY            EQU 11H                  ; key 0 for moving up and left
UP_KEY                 EQU 12H                  ; key 1 for moving up
UP_RIGHT_KEY           EQU 14H                  ; key 2 for moving up and right
LEFT_KEY               EQU 21H                  ; key 4 for moving left
RIGHT_KEY              EQU 24H                  ; key 6 for moving right
DOWN_LEFT_KEY          EQU 41H                  ; key 8 for moving down and left
DOWN__KEY              EQU 42H                  ; key 9 for moving down
DOWN_RIGHT_KEY         EQU 44H                  ; key A for moving down and right
START_KEY              EQU 81H                  ; key C for starting the game
PAUSE_KEY              EQU 82H                  ; key D for pausing and resuming/unpausing the game
END_GAME_KEY           EQU 84H                  ; key to terminate the game

; Keyboard
KEY_LIN                EQU 0C000H               ; address of the keyboard lines (POUT-2 peripheral)
KEY_COL                EQU 0E000H               ; address of the keyboard columns (PIN peripheral)
KEY_START_LIN          EQU 1                    ; initialization of the line

; Score
INITIAL_POINTS         EQU 00H                  ; initial score value
UPPER_LIMIT            EQU 999H                 ; maximum score counter value
LOWER_LIMIT            EQU 00H                  ; minimum score counter value  
MASK_LSD               EQU 0FH                  ; mask to isolate the 4 least significant bits to see the least significant digit
MASK_TENS              EQU 0F0H                 ; mask to isolate the bits representing the tens
INC_HUNDREDS           EQU 96                   ; number to increment to represent hundreds in the counter
INC_TENS               EQU 6                    ; number to increment to represent tens in the counter

; Initial Position
PAC_START_LIN          EQU 13                   ; initial row of pacman (middle of the screen)
PAC_START_COL          EQU 30                   ; initial column of pacman (middle of the screen)
GHOST_START_LIN        EQU 14                   ; initial row of the ghost (middle of the screen)
GHOST0_START_COL       EQU 0                    ; initial column of ghost 0 (next to the left limit)
GHOST1_START_COL       EQU 58                   ; initial column of ghost 1 (next to the left limit)
GHOST2_START_COL       EQU 0                    ; initial column of ghost 2 (next to the left limit)
GHOST3_START_COL       EQU 58                   ; initial column of ghost 3 (next to the left limit)
BOX_LIN                EQU 11                   ; row of the box
BOX_COL	               EQU 26                   ; column of the box
CANDY1_LIN             EQU  1                   ; row of the 1st candy
CANDY1_COL             EQU  1                   ; column of the 1st candy
CANDY2_LIN             EQU  1                   ; row of the 2nd candy
CANDY2_COL             EQU  59                  ; column of the 2nd candy
CANDY3_LIN             EQU  27                  ; row of the 3rd candy
CANDY3_COL             EQU  1                   ; column of the 3rd candy
CANDY4_LIN             EQU  27                  ; row of the 4th candy
CANDY4_COL             EQU  59                  ; column of the 4th candy

; Colours
YLW                    EQU 0FFF0H               ; pixel color: yellow in ARGB (opaque, red and green at maximum, blue at 0)
RED                    EQU 0FF00H               ; pixel color: red in ARGB (opaque and red at maximum, green and blue at 0)
CYAN                   EQU 0F4FFH               ; pixel color: cyan in ARGB (opaque, red at 4, green and blue at maximum)
BLUE                   EQU 0F00FH               ; pixel color: blue in ARGB (opaque, red and green at 0, blue at maximum)
PINK                   EQU 0FFAFH               ; pixel color: pink in ARGB (opaque and red at maximum, green at 10 and blue at maximum)
ORNG                   EQU 0FFA0H               ; pixel color: orange in ARGB (opaque and red at maximum, green at 10 and blue at 0)
L_RED                  EQU 0FF55H               ; pixel color: light red in ARGB (opaque and red at maximum, green and blue at 5)
L_BLUE                 EQU 0F0FFH               ; pixel color: light blue in ARGB (opaque, red at 0, green and blue at maximum)


; Measurements
PAC_HEIGHT             EQU 5                    ; pacman's height
PAC_WIDTH              EQU 5                    ; pacman's width
GHOST_HEIGHT           EQU 4                    ; the height of the ghost
GHOST_WIDTH            EQU 4                    ; the width of the ghost
CANDY_HEIGHT           EQU 4                    ; the height of the candy
CANDY_WIDTH            EQU 4                    ; the width of the candy
EXPLOSION_HEIGHT       EQU 5                    ; the height of the explosion
EXPLOSION_WIDTH        EQU 5                    ; the width of the explosion
BOX_HEIGHT             EQU 8                    ; the height of the box
BOX_WIDTH              EQU 12                   ; the width of the box

; Game States
GAME_STATE             EQU 3FEAH                ; address in memory where the current game state is stored
INITIAL                EQU 0                    ; indicates that the game has not started yet
PLAYING                EQU 1                    ; indicates that the game is in progress
PAUSED                 EQU 2                    ; indicates that the game is paused
WON                    EQU 3                    ; indicates that the game has ended and the player won
GAME_OVER              EQU 4                    ; indicates that the game has ended and the player lost

; *****************************************************************************************************************************
; * Data 
; *****************************************************************************************************************************
    PLACE 1000H

pilha:
    STACK 200H                                  ; reserved space for the stack (200H bytes, as they are 100H words)

SP_initial:                                     ; this is the address (1200H) with which the SP should be initialized. the 1st return address will be stored in 11FEH (1200H-2)

tab:
    WORD int_rot_0                              ; interrupt routine 0
    WORD int_rot_1                              ; interrupt routine 1
    WORD int_rot_2                              ; interrupt routine 2
    WORD int_rot_3                              ; interrupt routine 3

int_0: WORD 0                                   ; if 1, indicates that interrupt 0 occurred
int_1: WORD 0                                   ; if 1, indicates that interrupt 1 occurred
int_2: WORD 0                                   ; if 1, indicates that interrupt 2 occurred
int_3: WORD 0                                   ; if 1, indicates that interrupt 3 occurred

DEF_PACMAN:                                     ; table that defines pacman (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, YLW, YLW, YLW, 0             ;  ### 
    WORD        YLW, YLW, YLW, YLW, YLW         ; #####   
    WORD        YLW, YLW, YLW, YLW, YLW         ; #####   
    WORD        YLW, YLW, YLW, YLW, YLW         ; ##### 
    WORD        0, YLW, YLW, YLW, 0             ;  ### 

DEF_OPEN_PAC_LEFT:                              ; table that defines pacman with its mouth open to the left (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        YLW, YLW, YLW, 0, 0             ; ### 
    WORD        0, YLW, YLW, YLW, 0             ;  ###
    WORD        0, 0, YLW, YLW, 0               ;   ##
    WORD        0, YLW, YLW, YLW, 0             ;  ###
    WORD        YLW, YLW, YLW, 0, 0             ; ###

DEF_OPEN_PAC_RIGHT:                             ; table that defines pacman with its mouth open to the right (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, 0, YLW, YLW, YLW             ;  ### 
    WORD        0, YLW, YLW, YLW, 0             ; ###   
    WORD        0, YLW, YLW, 0, 0               ; ##
    WORD        0, YLW, YLW, YLW, 0             ; ### 
    WORD        0, 0, YLW, YLW, YLW             ;  ###

DEF_OPEN_PAC_UP:                                ; table that defines pacman with its mouth open upwards (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        YLW, 0, 0, 0, YLW               ; #   #   
    WORD        YLW, YLW, 0, YLW, YLW           ; ## ##
    WORD        YLW, YLW, YLW, YLW, YLW         ; ##### 
    WORD        0, YLW, YLW, YLW, 0             ;  ###
    WORD        0, 0, 0, 0, 0                   ;

DEF_OPEN_PAC_DOWN:                              ; table that defines pacman with its mouth open downwards (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, 0, 0, 0, 0                   ; 
    WORD        0, YLW, YLW, YLW, 0             ;  ###
    WORD        YLW, YLW, YLW, YLW, YLW         ; ##### 
    WORD        YLW, YLW, 0, YLW, YLW           ; ## ## 
    WORD        YLW, 0, 0, 0, YLW               ; #   # 

DEF_OPEN_PAC_UP_LEFT:                           ; table that defines pacman with its mouth open upwards and to the left (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, 0, YLW, YLW, 0               ;   ##
    WORD        0, 0, 0, YLW, YLW               ;    ## 
    WORD        YLW, 0, 0, YLW, YLW             ; #  ## 
    WORD        YLW, YLW, YLW, YLW, YLW         ; ##### 
    WORD        0, YLW, YLW, YLW, 0             ;  ### 

DEF_OPEN_PAC_UP_RIGHT:                          ; table that defines pacman with its mouth open upwards and to the right (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, YLW, YLW, 0, 0               ;   ##
    WORD        YLW, YLW, 0, 0, 0               ; ##   
    WORD        YLW, YLW, 0, 0, YLW             ; ##  # 
    WORD        YLW, YLW, YLW, YLW, YLW         ; ##### 
    WORD        0, YLW, YLW, YLW, 0             ;  ### 

DEF_OPEN_PAC_DOWN_LEFT:                         ; table that defines pacman with its mouth open downwards and to the left (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, YLW, YLW, YLW, 0             ;  ###
    WORD        YLW, YLW, YLW, YLW, YLW         ; ##### 
    WORD        YLW, 0, 0, YLW, YLW             ; #  ##
    WORD        0, 0, 0, YLW, YLW               ;    ##  
    WORD        0, 0, YLW, YLW, 0               ;   ##

DEF_OPEN_PAC_DOWN_RIGHT:                        ; table that defines pacman with its mouth open downwards and to the right (height, width, pixels, color)
    WORD        PAC_HEIGHT
    WORD        PAC_WIDTH
    WORD        0, YLW, YLW, YLW, 0             ;  ### 
    WORD        YLW, YLW, YLW, YLW, YLW         ; #####
    WORD        YLW, YLW, 0, 0, YLW             ; ##  #  
    WORD        YLW, YLW, 0, 0, 0               ; ##   
    WORD        0, YLW, YLW, 0, 0               ;   ##

DEF_L_BLUE_GHOST:                               ; table that defines the blue ghost (height, width, pixels, color)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, L_BLUE, L_BLUE, 0            ;  ## 
    WORD        L_BLUE, L_BLUE, L_BLUE, L_BLUE  ; ####
    WORD        L_BLUE, L_BLUE, L_BLUE, L_BLUE  ; ####
    WORD        L_BLUE, 0, 0, L_BLUE            ; #  #

DEF_L_RED_GHOST:                                ; table that defines the red ghost (height, width, pixels, color)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, L_RED, L_RED, 0              ;  ## 
    WORD        L_RED, L_RED, L_RED, L_RED      ; ####
    WORD        L_RED, L_RED, L_RED, L_RED      ; ####
    WORD        L_RED, 0, 0, L_RED              ; #  #

DEF_ORNG_GHOST:                                 ; table that defines the orange ghost (height, width, pixels, color)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, ORNG, ORNG, 0                ;  ## 
    WORD        ORNG, ORNG, ORNG, ORNG          ; ####
    WORD        ORNG, ORNG, ORNG, ORNG          ; ####
    WORD        ORNG, 0, 0, ORNG                ; #  #

DEF_PINK_GHOST:                                 ; table that defines the pink ghost (height, width, pixels, color)
    WORD        GHOST_HEIGHT
    WORD        GHOST_WIDTH
    WORD        0, PINK, PINK, 0                ;  ## 
    WORD        PINK, PINK, PINK, PINK          ; ####
    WORD        PINK, PINK, PINK, PINK          ; ####
    WORD        PINK, 0, 0, PINK                ; #  #

DEF_CANDY:                                      ; table that defines the candy (height, width, pixels, color)
    WORD        CANDY_HEIGHT
    WORD        CANDY_WIDTH
    WORD        0, 0, 0, RED                    ;    #
    WORD        0, RED, RED, 0                  ;  ## 
    WORD        0, RED, RED, 0                  ;  ##
    WORD        RED, 0, 0, 0                    ; #

DEF_EXPLOSION:                                  ; table that defines the explosion (height, width, pixels, color)
    WORD        EXPLOSION_HEIGHT
    WORD        EXPLOSION_WIDTH
    WORD        CYAN, 0, 0, 0, CYAN             ; #   #
    WORD        0, CYAN, 0, CYAN, 0             ;  # # 
    WORD        0, 0, CYAN, 0, 0                ;   #  
    WORD        0, CYAN, 0, CYAN, 0             ;  # # 
    WORD        CYAN, 0, 0, 0, CYAN             ; #   #

DEF_CANDY_POSITIONS:                            ; table that defines the positions of the candies
    WORD              CANDY1_LIN                ; row of candy 1
    WORD              CANDY1_COL                ; column of candy 1
    WORD              CANDY2_LIN                ; row of candy 2
    WORD              CANDY2_COL                ; column of candy 2
    WORD              CANDY3_LIN                ; row of candy 3
    WORD              CANDY3_COL                ; column of candy 3
    WORD              CANDY4_LIN                ; row of candy 4
    WORD              CANDY4_COL                ; column of candy 4

REMAINING_CANDIES:    WORD 4                    ; stores the number of candies in the game
NUM_GHOSTS:           WORD 0                    ; stores the number of ghosts in the game
SCORE:                WORD 0                    ; stores the game score
COUNT_INT_0:          WORD 0                    ; stores the number of times we handled count_int_0 (resets at 10)
COUNT_INT_1:          WORD 0                    ; stores the number of times we handled count_int_1 (resets at 5)
COUNT_INT_2:          WORD 0                    ; stores the number of times we handled count_int_2 (resets at 5)
EXPLOSION_EVENT:      WORD 0                    ; indicates if the explosion has occurred, 0 if not, 1 if yes

; Current Positions
PAC_LIN:              WORD PAC_START_LIN        ; stores the current row of pacman, initialized to PAC_START_LIN
PAC_COL:              WORD PAC_START_COL        ; stores the current column of pacman, initialized to PAC_START_COL

GHOST_POS:
    WORD GHOST_START_LIN                        ; stores the current row of ghost 0, initialized to GHOST_START_LIN
    WORD GHOST0_START_COL                       ; stores the current column of ghost 0, initialized to GHOST0_START_COL
    WORD DEF_L_BLUE_GHOST                       ; stores the table of ghost 0 (Light Blue Ghost)
    WORD GHOST_START_LIN                        ; stores the current row of ghost 1, initialized to GHOST_START_LIN
    WORD GHOST1_START_COL                       ; stores the current column of ghost 1, initialized to GHOST1_START_COL
    WORD DEF_L_RED_GHOST                        ; stores the table of ghost 1 (Light Red Ghost)
    WORD GHOST_START_LIN                        ; stores the current row of ghost 2, initialized to GHOST_START_LIN
    WORD GHOST2_START_COL                       ; stores the current column of ghost 2, initialized to GHOST2_START_COL
    WORD DEF_ORNG_GHOST                         ; stores the table of ghost 2 (Orange Ghost)
    WORD GHOST_START_LIN                        ; stores the current row of ghost 3, initialized to GHOST_START_LIN
    WORD GHOST3_START_COL                       ; stores the current column of ghost 3, initialized to GHOST3_START_COL
    WORD DEF_PINK_GHOST                         ; stores the table of ghost 3 (Pink Ghost)

ALIVE_GHOSTS:
    WORD 0                                      ; stores 0 or 1 to indicate if ghost 0 is alive or dead respectively, initialized to 0
    WORD 0                                      ; stores 0 or 1 to indicate if ghost 1 is alive or dead respectively, initialized to 0
    WORD 0                                      ; stores 0 or 1 to indicate if ghost 2 is alive or dead respectively, initialized to 0
    WORD 0                                      ; stores 0 or 1 to indicate if ghost 3 is alive or dead respectively, initialized to 0

; *****************************************************************************************************************************
; * Code
; *****************************************************************************************************************************
    PLACE 0
start:
    MOV SP, SP_initial
    MOV BTE, tab                                ; initialize the exception table
    EI0                                         ; enable interrupt 0
    EI1                                         ; enable interrupt 1
    EI2                                         ; enable interrupt 2
    EI3                                         ; enable interrupt 3
    MOV R0, GHOSTS_GIF                          ; store the number of the ghosts GIF in R0
    MOV [SELECT_MEDIA], R0                      ; select the ghosts GIF for the following commands
    MOV [STOP_MEDIA], R0                        ; stop playing the ghosts GIF (the value of R0 is irrelevant)
    MOV [STOP_ALL_MEDIA], R0                    ; stop playing all sounds/videos (the value of R0 is irrelevant)
    MOV [DELETE_FRONT_IMG], R0                  ; delete the front image (the value of R0 is irrelevant)
    MOV [DELETE_WARNING], R0                    ; delete the warning of no scenario selected (the value of R0 is irrelevant)
    MOV [DELETE_SCREEN], R0                     ; delete all pixels already drawn (the value of R0 is irrelevant)
    MOV R0, INITIAL_POINTS                      ; store the initial score value (000) in R0
    MOV [DISPLAYS], R0                          ; move the initial score values (000) to the displays
    MOV [SCORE], R0                             ; move the initial value of R0 to memory
    MOV R0, INITAL_NUM_GHOSTS                   ; store the initial number of ghosts in the game (0 - none) in R0
    MOV [NUM_GHOSTS], R0                        ; update the number of ghosts in the game to 0
    MOV R0, START_MENU_IMG                      ; move the number of the start menu background image to R0
    MOV [SELECT_BACKGROUND_IMG], R0             ; select the start menu background image
    MOV R0, PACMAN_THEME                        ; store the number of the pacman theme music in R0
    MOV [LOOP_MEDIA], R0                        ; play the pacman theme music in a loop
    MOV R0, GAME_STATE                          ; move the address in memory that contains the current game state to R0
    MOV R1, INITIAL                             ; move the number that represents the initial state to R1
    MOV [R0], R1                                ; store the current game state as INITIAL in memory
    MOV R11, 9                                  ; move the value 9 to R11 (will store the last key pressed) as "9" will never represent a key

waiting_press_start:
    CALL keyboard                               ; calls the keyboard function to identify the pressed key (value stored in R0)
    CALL game_state_key                         ; calls a function to detect if the pressed key is a key that changes the game state and executes the associated action
    MOV R1, [GAME_STATE]                        ; moves the current game state to R1
    CMP R1, PLAYING                             ; compares the current game state with the PLAYING state
    JNZ waiting_press_start                     ; repeats the loop while the game is not in the PLAYING state

CALL draw_center_box                            ; when the game starts (state = PLAYING) calls the function draw_center_box to draw the center box
CALL draw_limit_box                             ; calls the function to draw the game boundaries
CALL draw_candy                                 ; calls the function to draw the candies in the 4 corners

spawn_pacman:
    MOV R2, PAC_LIN                             ; address of the current row of pacman
    MOV R1, PAC_START_LIN                       ; initial row value of pacman
    MOV [R2], R1                                ; store the current row of pacman (initially the start row) in RAM
    MOV R3, PAC_COL                             ; address of the initial column of pacman
    MOV R2, PAC_START_COL                       ; initial column value of pacman
    MOV [R3], R2                                ; store the current column of pacman (initially the start column) in RAM
    MOV R4, DEF_OPEN_PAC_RIGHT                  ; address of the table that defines pacman
    CALL draw_object                            ; call the function to draw an object, in this case, pacman
EI                                              ; enable interrupts

main: ; ciclo principal
    CALL check_explosion                        ; calls the function that deletes the explosion after 1.5 seconds
    CALL keyboard                               ; calls the keyboard function to identify the pressed key (value stored in R0)
    CALL game_state_key                         ; calls a function to detect if the pressed key is a key that changes the game state and executes the associated action
    CALL movement_key                           ; calls a function to detect if the pressed key is a movement key and executes the associated action
    CALL spawn_ghosts                           ; calls the function to spawn ghosts
    CALL ghost_cycle                            ; calls the function that animates the ghosts
    CALL score_cycle                            ; calls the function that increments the score
    MOV R11, R0                                 ; stores the last pressed key in R11
    JMP main

; *****************************************************************************************************************************
; GET_PIXEL_COLOR - Gets the color of the pixel at the specified row and column.
; Arguments:   R1 - row
;              R2 - column
;
; Returns:     R3 - color of the pixel (in 16-bit ARGB format)
; *****************************************************************************************************************************
get_pixel_color:
    MOV [DEF_LINE], R1                          ; selects the line
    MOV [DEF_COLUMN], R2                        ; selects the column
    MOV R3, [GET_COLOR]                         ; gets the color of the pixel at the selected line and column
    RET 

; *****************************************************************************************************************************
; WRITE_PIXEL - Writes a pixel at the specified row and column.
; Arguments:   R1 - row
;              R2 - column
;              R3 - pixel color (in 16-bit ARGB format)
; *****************************************************************************************************************************
write_pixel:
    MOV  [DEF_LINE], R1                         ; selects the line
    MOV  [DEF_COLUMN], R2                       ; selects the column
    MOV  [DEF_PIXEL], R3                        ; changes the color of the pixel at the selected line and column
    RET

; *****************************************************************************************************************************
; DRAW_OBJECT - Draws the object at the specified row and column with the shape and color defined in the given table.
; Arguments:   R1 - row
;              R2 - column
;              R4 - table that defines the object
; *****************************************************************************************************************************
draw_object:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, [R4]                                ; get the height of the object
    ADD R4, 2                                   ; address of the width of the object
    MOV R6, [R4]                                ; get the width of the object (number of columns)
    ADD R4, 2                                   ; address of the color of the first pixel
    MOV R8, R2                                  ; save the initial column

draw_rows:
    MOV R7, R6                                  ; counter for the number of columns left to draw
    MOV R2, R8                                  ; reset to the initial column for each new row
    draw_pixels:
        MOV R3, [R4]                            ; get the color of the next pixel of the object
        CALL write_pixel                        ; call the function that draws each pixel of the object
        ADD R4, 2                               ; get the address of the color of the next pixel
        ADD R2, 1                               ; next column
        SUB R7, 1                               ; decrease the counter for the number of pixels left to draw in this row
        JNZ draw_pixels
    ADD R1, 1                                   ; next row
    SUB R5, 1                                   ; decrease the counter for the number of rows left to draw
    JNZ draw_rows                               ; if there are still rows left to draw, repeat the cycle

    POP R8                                      ; restore the previous values of the modified registers
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; DELETE_OBJECT - Deletes an object at the specified row and column
;                 with the shape defined in the given table.
; Arguments:   R1 - row
;              R2 - column
;              R4 - table that defines the object
; *****************************************************************************************************************************
delete_object:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, [R4]                                ; get the height of the object
    MOV R6, [R4+2]                              ; get the width of the object (number of columns)
    MOV R8, R2                                  ; save the initial column

delete_rows:                                    ; delete the pixels of the object from the table
    MOV R7, R6                                  ; counter for the number of columns left to delete
    MOV R2, R8                                  ; reset to the initial column for each new row
    delete_pixels:
        MOV R3, 0                               ; color to delete the next pixel of the object
        CALL write_pixel                        ; write each pixel of the object
        ADD R2, 1                               ; next column
        SUB R7, 1                               ; decrease the counter for the number of columns left to delete
        JNZ delete_pixels                       ; continue until the entire width of the object is processed
    ADD R1, 1                                   ; next row
    SUB R5, 1                                   ; decrease the counter for the number of rows left to delete
    JNZ delete_rows                             ; if there are still rows left to delete, repeat the cycle

    POP R8                                      ; restore the previous values of the modified registers
    POP R7
    POP R6
    POP R5
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; MOVE_OBJECT - Increments or decrements the counter based on the pressed key and updates the display
; Arguments:   R1 - row
;              R2 - column
;              R3 - table that defines the object
;              R4 - table that defines the animation of the object
;              R7 - direction of the object's movement vertically (value to add to the row in each movement: +1 for down, -1 for up)
;              R8 - direction of the object's movement horizontally (value to add to the column in each movement: +1 for right, -1 for left)
;
; Returns:     R1 - new row value, after the movement
; *****************************************************************************************************************************
move_object:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
    PUSH R6
    PUSH R9

    CALL choose_ghost_action                    ; calls the function that checks what type of movement the object is trying to make and if it is crossing any limits
    CMP R0, 0                                   ; compares the return value of the function (R0) with 0
    JZ end_movement                             ; if the function returns 0, jumps to end_movement as the movement is prohibited
    CMP R0, 2   
    JZ ghost_pacman
    CALL delete_object                          ; if not, deletes the object
    ADD R1, R7                                  ; gets the new row
    ADD R2, R8                                  ; gets the new column
    CALL draw_object                            ; draws the animated version of the object
    CALL delay                                  ; calls a function to delay/slow down the movement
    CALL delete_object                          ; deletes the animated version of the object
    MOV R4, R3                                  ; saves the table that defines the object (non-animated version) in R4
    CALL draw_object                            ; draws the final version of the object
    CALL delay                                  ; calls a function to delay/slow down the movement 
    JMP end_movement

ghost_pacman:
    CALL explosion

end_movement:
    POP R9                                      ; restores the previous values of the modified registers
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; DRAW_CENTER_BOX - Draws the central box where pacman spawns.
; *****************************************************************************************************************************
draw_center_box:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R1, BOX_LIN                             ; initial row of the box
    MOV R2, BOX_COL                             ; initial column of the box
    MOV R3, BLUE                                ; save pixel color
    MOV R4, BOX_HEIGHT                          ; height of the box
    MOV R7, R4                                  ; counter for rows to draw
    SUB R4, 1                                   ; subtract one from the height of the box
    MOV R5, BOX_WIDTH                           ; width of the box
    SUB R5, 1                                   ; subtract one from the width of the box

draw_vertical_lines:
    CALL write_pixel                            ; call the function to draw the pixel
    ADD R2, R5                                  ; add the number of pixels to jump from the left limit of the box to the right limit (width - 1)
    CALL write_pixel                            ; call the function to draw the pixel
    MOV R2, BOX_COL                             ; return to the left limit
    ADD R1, 1                                   ; move to the next row
    SUB R7, 1                                   ; decrement the counter for rows to draw
    JNZ draw_vertical_lines                     ; repeat the cycle until no rows are left to draw
    MOV R1, BOX_LIN                             ; recover the initial row of the box
    MOV R2, BOX_COL                             ; recover the initial column of the box
    MOV R7, 2                                   ; save the value 2 in R7 (counter for the number of pixels before the opening in the box)
    MOV R8, FALSE                               ; flag to know if we have passed the break in the box

draw_horizontal_lines:
    ADD R2, 1                                   ; move one pixel to the right
    CALL write_pixel                            ; call the function to draw the pixel
    ADD R1, R4                                  ; add the height of the box - 1 to the initial row
    CALL write_pixel                            ; call the function to draw the pixel
    MOV R1, BOX_LIN                             ; subtract back the height of the box returning to the initial row
    SUB R7, 1                                   ; decrement the counter for pixels left to draw before the break
    JNZ draw_horizontal_lines                   ; repeat the cycle until all pixels before the break are drawn
    CMP R8, 1                                   ; check if we have passed the break
    JZ end_draw_center_box                      ; if so, jump to the end of the routine
    ADD R2, 6                                   ; if not, add 6 to the current column value thus jumping the break
    MOV R7, 2                                   ; save the value 2 in R7 (counter for the number of pixels after the opening in the box)
    MOV R8, TRUE                                ; update the flag
    JMP draw_horizontal_lines                   ; jump to draw_horizontal_lines to draw the right side of the box

end_draw_center_box:
    POP R8                                      ; restore the previous values of the modified registers
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; DRAW_LIMIT_BOX - Draws the game boundaries
; *****************************************************************************************************************************
draw_limit_box:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7

    MOV R1, 0                                   ; store in R1 the row to start drawing (upper boundary of the game)
    MOV R2, 0                                   ; store in R0 the column to start drawing
    MOV R3, BLUE                                ; store in R3 the color to use (blue)
    MOV R4, 00FFH                               ; store in R4 the upper row to draw (upper boundary of the game)
    MOV R5, 001FH                               ; store in R5 the lower row to draw (lower boundary of the game)
    MOV R6, 08H                                 ; store in R6 the value to increment the column each time we paint (since we are painting 8 at a time)
    MOV R7, 8                                   ; store in R7 the counter that counts the times we need to paint (8 * 8 = 64 = number of horizontal pixels)
    MOV [DEF_LINE], R1                          ; select the upper row
    MOV [DEF_COLUMN], R2                        ; select column zero
    MOV [DEF_COLOR], R3                         ; select the color (blue) to paint the pixel

    next_horizontal_limit:                      ; start the cycle to draw the horizontal boundaries
        MOV [DEF_8_PIXELS], R4                  ; paint the next 8 pixels with the selected color
        ADD R1, R5                              ; move to the lower boundary
        MOV [DEF_LINE], R1                      ; select the lower row (lower boundary)
        MOV [DEF_8_PIXELS], R4                  ; paint the next 8 pixels with the selected color
        SUB R1, R5                              ; return to the upper boundary
        MOV [DEF_LINE], R1                      ; select the upper row again (upper boundary)
        SUB R7, 1                               ; decrement the counter
        JZ draw_vertical_limit                  ; check if we have done the necessary times, if so jump to the function that draws the vertical boundaries
        ADD R2, R6                              ; if not, select the column after the 8 painted pixels
        MOV [DEF_COLUMN], R2                    ; define that column 
        JMP next_horizontal_limit               ; return to the beginning of the cycle

    draw_vertical_limit:                        ; start the cycle to draw the vertical boundaries
        MOV R1, 1                               ; store in R1 the row to start drawing
        MOV R2, 0                               ; store in R2 the column to start drawing (leftmost boundary of the game)
        MOV R4, 003FH                           ; store in R4 the rightmost column to draw (rightmost boundary)
        MOV R5, 9                               ; store in R5 the times we need to paint in each cycle
        MOV R6, 003DH                           ; store in R6 the column value to draw the ghost spawns on the right
        MOV R7, 0020H                           ; store in R7 the last row to draw + 1

        next_vertical_limit:
            CALL write_pixel                    ; call the function to paint the pixel
            ADD R2, R4                          ; select the rightmost column
            CALL write_pixel                    ; call the function to paint the pixel
            SUB R2, R4                          ; select the leftmost column
            ADD R1, 1                           ; move down one row
            CMP R1, R7                          ; check if we have painted the last row
            JZ exit_draw_limit_box              ; if so, exit the function
            CMP R1, R5                          ; check if we have reached the row to draw the ghost spawns
            JNZ next_vertical_limit             ; if not, continue drawing
            CALL draw_ghost_spawns              ; draw the first part of the ghost spawn (top left)
            ADD R2, R6                          ; select the column to start the second part of the spawn
            SUB R1, 2                           ; select the row to start the second part of the spawn
            CALL draw_ghost_spawns              ; draw the second part of the ghost spawn (top right)
            SUB R2, R6                          ; select the column to start the second part of the spawn
            ADD R1, 7H                          ; select the row to start the second part of the spawn
            CALL draw_ghost_spawns              ; draw the third part of the ghost spawn (bottom right)
            ADD R2, R6                          ; select the column to start the second part of the spawn
            SUB R1, 2                           ; select the row to start the second part of the spawn
            CALL draw_ghost_spawns              ; draw the last part of the ghost spawn (bottom left)
            SUB R2, R6                          ; return to the first column to continue drawing the vertical boundaries
            JMP next_vertical_limit             ; return to draw the rest of the vertical boundary pixels
        
exit_draw_limit_box:
    POP R7                                      ; restore the previous values of the modified registers
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; DRAW_GHOST_SPAWNS - Draws the ghost spawns
; *****************************************************************************************************************************
draw_ghost_spawns:
    PUSH R2                                     ; save the previous values of the registers that are altered in this function
    PUSH R3
    PUSH R4
    
    MOV R4, R2                                  ; copy the value of R2 to R4 to be used
    CALL write_pixel                            ; call the function to write pixel
    ADD R2, 1                                   ; move to the next column
    CALL write_pixel                            ; call the function to write pixel
    ADD R2, 1                                   ; move to the next column
    CALL write_pixel                            ; call the function to write pixel
    ADD R1, 1                                   ; move to the next row
    CMP R4, 0                                   ; check if the value of R4 is 0
    JZ left_ghost_spawns                        ; if 0, jump to left_ghost_spawns
    SUB R2, 2                                   ; move two columns back
    CALL write_pixel                            ; call the function to write pixel
    ADD R1, 1                                   ; move to the next row
    JMP jump_left_spawns                        ; jump to jump_left_spawns
    
    left_ghost_spawns:
        CALL write_pixel                        ; call the function to write pixel
        ADD R1, 1                               ; move to the next row
        SUB R2, 2                               ; move two columns back

    jump_left_spawns:
        CALL write_pixel                        ; call the function to draw the pixel
        ADD R2, 1                               ; move one column back
        CALL write_pixel                        ; call the function to draw the pixel
        ADD R2, 1                               ; move another column back
        CALL write_pixel                        ; call the function to draw the pixel
        
        POP R4                                  ; restore the previous values of the modified registers
        POP R3
        POP R2
        RET

; *****************************************************************************************************************************
; DRAW_CANDY - Draws the candies at the positions defined in the DEF_CANDY_POSITIONS table
; *****************************************************************************************************************************
draw_candy:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    MOV R0, DEF_CANDY_POSITIONS                 ; store in R0 the address of the table that contains the positions (row, column) of the 4 candies
    MOV R4, DEF_CANDY                           ; store in R4 the table that defines each candy
    MOV R3, 4                                   ; R3 indicates the number of candies left to draw, initially all 4
    draw_each_candy:
        MOV R1, [R0]                            ; get the row of the candy to be drawn
        ADD R0, 2                               ; advance to the address of the column of the candy
        MOV R2, [R0]                            ; get the column of the candy to be drawn
        ADD R0, 2                               ; advance to the address of the row of the candy
        CALL draw_object                        ; call the function to draw the object (in this case the candy)
        SUB R3, 1                               ; decrement the number of candies left to draw
        JNZ draw_each_candy                     ; if there are still candies left to draw, repeat the draw_each_candy cycle
    
    POP R4                                      ; restore the previous values of the modified registers
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; *****************************************************************************************************************************
; CHOOSE_OBJECT_ACTION - Checks what action the object will take
; Arguments:   R1 - row where the object is located
;               R2 - column where the object is located
;               R4 - table that defines the object
;               R7 - direction of the object's movement vertically (value to add to the row in each movement: +1 for down, -1 for up)
;               R8 - direction of the object's movement horizontally (value to add to the column in each movement: +1 for right, -1 for left)
;
; Returns: R0 - Returns the value of the action the object will take:
;               0 - movement prohibited
;               1 - can move
;               2 - can move and finds a candy
;               3 - can move and finds a ghost
; *****************************************************************************************************************************
choose_object_action:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10

    MOV R5, [R4]                                ; get the height of the object
    SUB R5, 1                                   ; subtract 1 from the height of the object
    MOV R6, [R4+2]                              ; get the width of the object     
    SUB R6, 1                                   ; subtract 1 from the width of the object
    ADD R1, R7                                  ; add the value of the potential movement to the row
    ADD R2, R8                                  ; add the value of the potential movement to the column
    MOV R0, 1                                   ; store the value 1 in R0 (by default we assume it can move)
    MOV R10, BLUE                               ; store the color BLUE (color of the boundaries) in R10

check_horizontal_pixels:
    MOV R9, [R4+2]                              ; store the height of the object in R9
    next_horizontal_pixels:
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ over_limit                           ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CALL identify_action                    ; if not, call the function that assigns action type codes according to the color of the pixels that pacman wants to occupy (finds out if it will collide with a candy or a ghost)
        ADD R1, R5                              ; add the height - 1 to the current row
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ over_limit                           ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CALL identify_action                    ; if not, call the function that assigns action type codes according to the color of the pixels that pacman wants to occupy (finds out if it will collide with a candy or a ghost)
        SUB R1, R5                              ; recover the initial row
        SUB R9, 1                               ; decrement R9
        JZ check_vertical_pixels                ; if it has reached 0 jump to check_vertical_pixels
        ADD R2, 1                               ; if not, move to the next row
        JMP next_horizontal_pixels              ; repeat the cycle

check_vertical_pixels:
    MOV R9, [R4]                                ; store the width of the object in R9
    next_vertical_pixels:
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ over_limit                           ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CALL identify_action                    ; if not, call the function that assigns action type codes according to the color of the pixels that pacman wants to occupy (finds out if it will collide with a candy or a ghost)
        SUB R2, R6                              ; subtract the width of the object - 1 from the column
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ over_limit                           ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CALL identify_action                    ; if not, call the function that assigns action type codes according to the color of the pixels that pacman wants to occupy (finds out if it will collide with a candy or a ghost)
        ADD R2, R6                              ; recover the old value of R6 
        SUB R9, 1                               ; decrement the width counter
        JZ not_over_limit                       ; if it has reached 0 jump to not_over_limit
        ADD R1, 1                               ; if not, move to the next column
        JMP next_vertical_pixels                ; repeat the cycle

over_limit:
    MOV R0, 0                                   ; since the object is trying to move beyond a boundary we store 0 in R0 to indicate that the movement is prohibited
    JMP exit_choose_object_action               ; jump to the end of the routine

not_over_limit:
    CMP R0, 1                                   ; compare the code with 1
    JGT exit_choose_object_action               ; if the code is greater than 1 jump to the end of the routine
    MOV R0, 1                                   ; store the value 1 in R0 (code that indicates that pacman can move and will not collide with anything)
    JMP exit_choose_object_action               ; jump to the end of the routine

exit_choose_object_action:
    POP R10                                     ; recover the previous values of the modified registers
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
; CHOOSE_GHOST_ACTION - Checks what action the object will take
; Arguments:    R1 - row where the object is located
;               R2 - column where the object is located
;               R4 - table that defines the object
;               R7 - direction of the object's movement vertically (value to add to the row in each movement: +1 for down, -1 for up)
;               R8 - direction of the object's movement horizontally (value to add to the column in each movement: +1 for right, -1 for left)
;
; Returns: R0 - Stores the value of the action the object will take:
;               0 - movement prohibited
;               1 - can move
;               2 - can move and finds pacman
; *****************************************************************************************************************************
choose_ghost_action:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
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

    MOV R5, [R4]                                ; get the height of the object
    SUB R5, 1                                   ; subtract 1 from the height of the object
    MOV R6, [R4+2]                              ; get the width of the object     
    SUB R6, 1                                   ; subtract 1 from the width of the object
    ADD R1, R7                                  ; add the value of the potential movement to the row
    ADD R2, R8                                  ; add the value of the potential movement to the column
    MOV R0, 1                                   ; store the value 1 in R0
    MOV R10, BLUE                               ; store the color BLUE (color of the boundaries) in R10
    MOV R11, YLW                                ; store the color YLW (color of pacman) in R11

check_horizontal_ghost:
    MOV R9, [R4+2]                              ; store the width of the object in R9
    next_horizontal_ghost:
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ ghost_over_limit                     ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CMP R3, R11
        JZ caught_pacman

        ADD R1, R5                              ; add the height - 1 to the current row
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ ghost_over_limit                     ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CMP R3, R11
        JZ caught_pacman

        SUB R1, R5                              ; recover the initial row
        SUB R9, 1                               ; decrement the width counter
        JZ check_vertical_ghost                 ; if it has reached 0 jump to check_vertical_pixels
        ADD R2, 1                               ; if not, move to the next row
        JMP next_horizontal_ghost               ; repeat the cycle

check_vertical_ghost:
    MOV R9, [R4]                                ; store the height of the object in R9
    next_vertical_ghost:
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ ghost_over_limit                     ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CMP R3, R11                             ; check if the pixel is yellow
        JZ caught_pacman                        ; if so, jump to caught_pacman

        SUB R2, R6                              ; leftmost column of the object
        CALL get_pixel_color                    ; call the function that identifies the color of the selected pixel
        CMP R3, R10                             ; check if the pixel is blue
        JZ ghost_over_limit                     ; if so, the object is trying to move beyond a boundary then jump to over_limit
        CMP R3, R11                             ; check if the pixel is yellow
        JZ caught_pacman                        ; if so, jump to caught_pacman

        ADD R2, R6                              ; rightmost column of the object
        SUB R9, 1                               ; decrement the height counter
        JZ ghost_not_over_limit                 ; if it has reached 0 jump to not_over_limit
        ADD R1, 1                               ; if not, move to the next column
        JMP next_vertical_ghost                 ; repeat the cycle

caught_pacman:
    MOV R0, 2                                   ; store the value 1 in R0 (code that indicates the ghost found pacman)
    JMP exit_choose_ghost_action                ; jump to the end of the routine

ghost_over_limit:
    MOV R0, 0                                   ; since the object is trying to move beyond a boundary we store 0 in R0 to indicate that the movement is prohibited
    JMP exit_choose_ghost_action                ; jump to the end of the routine

ghost_not_over_limit:
    MOV R0, 1                                   ; store the value 1 in R0 (code that indicates the ghost can move and will not collide with anything)
    JMP exit_choose_ghost_action                ; jump to the end of the routine

exit_choose_ghost_action:
    POP R11                                     ; recover the previous values of the modified registers
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
; IDENTIFY_ACTION - Identifies the action of pacman
; Assigns action identifier codes according to the color of the pixels that pacman wants to occupy (finds out if it will collide with a candy or a ghost)
; Arguments:   R3 - pixel color
;
; Returns:      R0 - action identifier code
;               0 - movement prohibited
;               1 - can move
;               2 - can move and finds a candy
;               3 - can move and finds a ghost
; *****************************************************************************************************************************
identify_action:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R1, L_BLUE                              ; store in R1 the hex value that defines the color used for blue pixels
    MOV R2, L_RED                               ; store in R2 the hex value that defines the color used for red pixels
    MOV R4, ORNG                                ; store in R4 the hex value that defines the color used for orange pixels
    MOV R5, PINK                                ; store in R5 the hex value that defines the color used for pink pixels
    MOV R6, RED                                 ; store in R6 the hex value that defines the color used for red candy pixels
    CMP R0, 3                                   ; check if it already caught a ghost
    JZ exit_identify_action                     ; if so, jump to the end of the routine
    CMP R3, R1                                  ; if not, check if the selected pixel is l_blue
    JZ caught_ghost                             ; if so, caught a ghost and jump to caught_ghost
    CMP R3, R2                                  ; if not, check if the selected pixel is l_red
    JZ caught_ghost                             ; if so, caught a ghost and jump to caught_ghost
    CMP R3, R4                                  ; if not, check if the selected pixel is orange
    JZ caught_ghost                             ; if so, caught a ghost and jump to caught_ghost
    CMP R3, R5                                  ; if not, check if the selected pixel is pink
    JZ caught_ghost                             ; if so, caught a ghost and jump to caught_ghost
    CMP R3, R6                                  ; if not, check if the selected pixel is red candy
    JZ caught_candy                             ; if so, caught a candy and jump to caught_candy
    JMP exit_identify_action                    ; repeat the cycle

caught_ghost:
    MOV R0, 3                                   ; store in R0 the value 3, code that represents catching a ghost
    JMP exit_identify_action                    ; jump to the end of the routine

caught_candy:
    MOV R0, 2                                   ; store in R0 the value 2, code that represents catching a candy
    JMP exit_identify_action                    ; jump to the end of the routine

exit_identify_action:
    POP R6                                      ; restore the previous values of the modified registers
    POP R5
    POP R4
    POP R3
    POP R2                          
    POP R1
    RET

; *****************************************************************************************************************************
; DELETE_CANDY - Checks which candy pacman has caught and deletes it.
; Arguments:    R1 - row
;               R2 - column
;               R7 - direction of the object's movement vertically (value to add to the row in each movement: +1 for down, -1 for up)
;               R8 - direction of the object's movement horizontally (value to add to the column in each movement: +1 for right, -1 for left)
; *****************************************************************************************************************************
delete_candy:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R5, MIDDLE_LIN                          ; store in R5 the row number that represents the middle of the screen
    MOV R6, MIDDLE_COL                          ; store in R6 the column number that represents the middle of the screen
    MOV R0, DEF_CANDY_POSITIONS                 ; store in R0 the address of the table that contains the positions (row, column) of the 4 candies
    MOV R4, DEF_CANDY                           ; store in R4 the table that defines each candy
    ADD R1, R7                                  ; get the new row where pacman found the candy
    ADD R2, R8                                  ; get the new column where pacman found the candy
    CMP R2, R6                                  ; compare the column where pacman found the candy with the middle column of the screen
    JLT left_candies                            ; if the candy column is greater, then it is one of the candies on the left
    JGT right_candies                           ; if the candy column is smaller, then it is one of the candies on the right

    left_candies:
        CMP R1, R5                              ; compare the row where pacman found the candy with the middle row of the screen
        JLT left_up_candy                       ; if smaller, we know it is the candy in the upper left corner
        JGT left_down_candy                     ; if greater, we know it is the candy in the lower left corner

    right_candies:
        CMP R1, R5                              ; compare the row where pacman found the candy with the middle row of the screen
        JLT right_up_candy                      ; if smaller, we know it is the candy in the upper right corner
        JGT right_down_candy                    ; if greater, we know it is the candy in the lower right corner

    left_up_candy:
        MOV R1, [R0]                            ; row of the candy
        MOV R2, [R0+2]                          ; column of the candy
        JMP exit_delete_candy                   ; jump to the end of the routine

    right_up_candy:
        MOV R1, [R0+4]                          ; row of the candy
        MOV R2, [R0+6]                          ; column of the candy
        JMP exit_delete_candy                   ; jump to the end of the routine

    left_down_candy:
        MOV R1, [R0+8]                          ; row of the candy
        MOV R2, [R0+10]                         ; column of the candy
        JMP exit_delete_candy                   ; jump to the end of the routine

    right_down_candy:
        MOV R1, [R0+12]                         ; row of the candy
        MOV R2, [R0+14]                         ; column of the candy
        JMP exit_delete_candy                   ; jump to the end of the routine

    exit_delete_candy:
        CALL delete_object                      ; delete the identified candy

        POP R6                                  ; restore the previous values of the modified registers
        POP R5
        POP R4
        POP R3
        POP R2 
        POP R1
        POP R0
        RET

; *****************************************************************************************************************************
; EXPLOSION - Deletes pacman, shows an explosion, and changes EXPLOSION_EVENT to reflect that the explosion has occurred.
; Arguments: R1 - pacman's row
;             R2 - pacman's column
;             R4 - table that defines pacman
; *****************************************************************************************************************************
explosion:
    PUSH R4                                     ; save the previous value of the register that will be altered in this function
    
    CALL delete_object                          ; delete pacman
    MOV R4, DEF_EXPLOSION                       ; store the table that defines the explosion in R4
    CALL draw_object                            ; draw the explosion
    MOV R4, TRUE                                ; store the value TRUE in R4
    MOV [EXPLOSION_EVENT], R4                   ; store in RAM at the address EXPLOSION_EVENT the value TRUE (indicating that the explosion has occurred)
    
    POP R4                                      ; restore the previous value of the modified register
    RET

; *****************************************************************************************************************************
; KEYBOARD - Checks if a key was pressed
; *****************************************************************************************************************************
keyboard:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R0, 0                                   ; initialize R0 to 0 to store the pressed key
    MOV R2, 0                                   ; initialize R2 to 0 to store the pressed column
    MOV R1, KEY_START_LIN                       ; define the line to read (initially 1)
    MOV R3, KEY_LIN                             ; address of the keyboard lines peripheral
    MOV R4, KEY_COL                             ; address of the keyboard columns peripheral
    MOV R5, MASK_LSD                            ; mask to isolate the 4 least significant bits
    MOV R6, 0                                   ; initialize the line counter to 0

    check_key:
        MOVB [R3], R1                           ; activate the line for keyboard reading
        MOVB R2, [R4]                           ; read the keyboard column
        AND R2, R5                              ; apply the mask
        CMP R2, 0                               ; check if any key was pressed
        JZ next_line                            ; if no key was pressed, move to the next line
        JMP is_key_pressed                      ; otherwise, wait for the key to be released

    next_line:
        SHL R1, 1                               ; move to the next keyboard line
        INC R6                                  ; increment the line counter
        CMP R6, 4                               ; check if all lines have been read
        JNZ check_key                           ; if not all lines have been read, check the next one
        JMP exit_keyboard                       ; if all lines have been read, jump to the end of the routine

    is_key_pressed:
        MOV R0, R1                              ; store the line of the pressed key in R0
        SHL R0, 4                               ; place the line in the high nibble
        OR R0, R2                               ; combine with the column (low nibble), now R0 has the pressed key

    exit_keyboard:
        POP R8                                  ; restore the previous values of the modified registers      
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        RET

; *****************************************************************************************************************************
; MOVEMENT_KEY - Checks if the pressed key is a movement key and executes the associated action if the game is in progress.
; Arguments: R0 - pressed key
;            R11 - previously pressed key
; *****************************************************************************************************************************
movement_key:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R4
    PUSH R5
    PUSH R7
    PUSH R8

    MOV R1, [GAME_STATE]                        ; move the current game state to R1
    CMP R1, PLAYING                             ; compare the current game state with the PLAYING state
    JNZ end_move                                ; if the game is not PLAYING, jump to end_move
    ; Key mappings for movement
    MOV R2, UP_LEFT_KEY                         ; move the hexadecimal value that represents the UP/LEFT movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_up_left                             ; if the pressed key is UP/LEFT, jump to move_up_left
    MOV R2, UP_KEY                              ; move the hexadecimal value that represents the UP movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_up                                  ; if the pressed key is UP, jump to move_up
    MOV R2, UP_RIGHT_KEY                        ; move the hexadecimal value that represents the UP/RIGHT movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_up_right                            ; if the pressed key is UP/RIGHT, jump to move_up_right
    MOV R2, LEFT_KEY                            ; move the hexadecimal value that represents the LEFT movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_left                                ; if the pressed key is LEFT, jump to move_left
    MOV R2, RIGHT_KEY                           ; move the hexadecimal value that represents the RIGHT movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_right                               ; if the pressed key is RIGHT, jump to move_right
    MOV R2, DOWN_LEFT_KEY                       ; move the hexadecimal value that represents the DOWN/LEFT movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_down_left                           ; if the pressed key is DOWN/LEFT, jump to move_down_left
    MOV R2, DOWN__KEY                           ; move the hexadecimal value that represents the DOWN movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_down                                ; if the pressed key is DOWN, jump to move_down
    MOV R2, DOWN_RIGHT_KEY                      ; move the hexadecimal value that represents the DOWN_RIGHT movement to R2
    CMP R0, R2                                  ; compare the pressed key with the value in R2
    JZ move_down_right                          ; if the pressed key is DOWN, jump to move_down_right
    JMP end_move                                ; if the pressed key is none of the keys tested above, jump to end_move

move_up_left:
    MOV R3, DEF_OPEN_PAC_UP_LEFT                ; store in R3 the value of the table that defines pacman with its mouth open upwards and to the left
    MOV R7, -1                                  ; store in R7 the value -1, R7 represents the vertical movement by moving the object up it subtracts 1 from its current row
    MOV R8, -1                                  ; store in R8 the value -1, R8 represents the horizontal movement by moving the object to the left it subtracts 1 from its current column
    JMP move                                    ; jump to move to not alter the values of R3, R7, and R8

move_up:
    MOV R3, DEF_OPEN_PAC_UP                     ; store in R3 the value of the table that defines pacman with its mouth open upwards
    MOV R7, -1                                  ; store in R7 the value -1
    MOV R8, 0                                   ; store in R8 the value 0. The UP movement does not require horizontal translations
    JMP move                                    ; jump to move

move_up_right:
    MOV R3, DEF_OPEN_PAC_UP_RIGHT               ; store in R3 the value of the table that defines pacman with its mouth open upwards and to the right
    MOV R7, -1                                  ; store in R7 the value -1
    MOV R8, 1                                   ; store in R8 the value 1
    JMP move                                    ; jump to move

move_left:
    MOV R3, DEF_OPEN_PAC_LEFT                   ; store in R3 the value of the table that defines pacman with its mouth open to the left
    MOV R7, 0                                   ; store in R7 the value 0. The LEFT movement does not require vertical translations
    MOV R8, -1                                  ; store in R8 the value -1
    JMP move                                    ; jump to move

move_right:
    MOV R3, DEF_OPEN_PAC_RIGHT                  ; store in R3 the value of the table that defines pacman with its mouth open to the right
    MOV R7, 0                                   ; store in R7 the value 0
    MOV R8, 1                                   ; store in R8 the value 1
    JMP move                                    ; jump to move

move_down_left:
    MOV R3, DEF_OPEN_PAC_DOWN_LEFT              ; store in R3 the value of the table that defines pacman with its mouth open downwards and to the left
    MOV R7, 1                                   ; store in R7 the value 1
    MOV R8, -1                                  ; store in R8 the value -1
    JMP move                                    ; jump to move

move_down:
    MOV R3, DEF_OPEN_PAC_DOWN                   ; store in R3 the value of the table that defines pacman with its mouth open downwards
    MOV R7, 1                                   ; store in R7 the value 1
    MOV R8, 0                                   ; store in R8 the value 0
    JMP move                                    ; jump to move

move_down_right:
    MOV R3, DEF_OPEN_PAC_DOWN_RIGHT             ; store in R3 the value of the table that defines pacman with its mouth open downwards and to the right
    MOV R7, 1                                   ; store in R7 the value 1 
    MOV R8, 1                                   ; store in R8 the value 1 

move:
    CMP R0, R11                                 ; check if the pressed key is the same as the previous one
    JZ no_sound                                 ; if so, the movement is continuous, so jump to no_sound to not play the sound again
    MOV R1, PACMAN_CHOMP                        ; if not, store the number of the pacman chomp sound in R1
    MOV [PLAY_MEDIA], R1                        ; play the PACMAN_CHOMP sound
    no_sound:
        MOV R1, [PAC_LIN]                       ; store the current row of pacman in R1
        MOV R2, [PAC_COL]                       ; store the current column of pacman in R2
        MOV R5, NUM_COL                         ; store the number of columns on the screen in R4
        CMP R2, R5                              ; check if pacman has crossed the screen on the right side
        JZ tunnel_right                         ; if so, place pacman on the left side
        MOV R5, -5                          
        CMP R2, R5                              ; check if pacman has crossed the screen on the left side
        JZ tunnel_left                          ; if so, place pacman on the right side
        JMP end_tunnel

        tunnel_right: 
            MOV R2, -4                          ; place pacman on the left
            JMP end_tunnel                      ; jump to the end of the tunnel    
        
        tunnel_left:
            MOV R2, 63                          ; place pacman on the right

        end_tunnel:
        MOV R4, DEF_PACMAN                      ; move the table that defines pacman with its mouth closed to R4
        CALL move_pacman                        ; call the move_pacman function
        MOV [PAC_LIN], R1                       ; update the current row of pacman
        MOV [PAC_COL], R2                       ; update the current column of pacman

end_move:
    POP R8                                      ; restore the previous values of the modified registers
    POP R7
    POP R5
    POP R4
    POP R2
    POP R1
    RET

; *****************************************************************************************************************************
; GAME_STATE_KEY - Determines if the pressed key is one that changes the game state and executes the associated action.
; Arguments:   R0 - pressed key
;              R11 - previously pressed key
; *****************************************************************************************************************************
game_state_key:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2

    CMP R0, R11                                 ; check if the pressed key and the previously pressed key are the same
    JZ exit_state_key                           ; if so, jump to exit_state_key (the player must release the key and press it again)
    
    ; Key mappings
    MOV R2, [GAME_STATE]                        ; store the current game state value in R2
    MOV R1, START_KEY                           ; move the hexadecimal value that represents the start key (key C) to R1
    CMP R0, R1                                  ; check if the pressed key is the start key
    JZ start_key_pressed                        ; if so, jump to start_key_pressed
    MOV R1, PAUSE_KEY                           ; if not, move the hexadecimal value that represents the pause key (key D) to R1
    CMP R0, R1                                  ; check if the pressed key is the pause key
    JZ pause_key_pressed                        ; if so, jump to pause_key_pressed
    MOV R1, END_GAME_KEY                        ; if not, move the hexadecimal value that represents the end game key (key E) to R1
    CMP R0, R1                                  ; check if the pressed key is the end game key
    JZ end_game_key_pressed                     ; if so, jump to end_game_key_pressed
    JMP exit_state_key                          ; if not, jump to the end of the routine

    start_key_pressed:
        CMP R3, INITIAL                         ; check if the current game state is the initial state
        JNZ exit_state_key                      ; if not, jump to the end of the routine
        MOV R1, PLAYING                         ; if so, store the PLAYING state value in R1
        MOV [GAME_STATE], R1                    ; update the current game state to PLAYING
        MOV R1, GAME_BACKGROUND                 ; move the game background image number to R1
        MOV [SELECT_BACKGROUND_IMG], R1         ; select the value in R1 as the background image number
        MOV R1, PACMAN_THEME                    ; move the PACMAN THEME sound number to R1
        MOV [STOP_MEDIA], R1                    ; stop playing the PACMAN THEME sound
        JMP exit_state_key                      ; jump to the end of the routine
    
    pause_key_pressed:
        CMP R2, PLAYING                         ; check if the current game state is the PLAYING state
        JZ pausing_game                         ; if so, jump to pausing_game
        CMP R2, PAUSED                          ; if not, check if the current game state is the PAUSED state
        JZ resuming_game                        ; if so, jump to resuming_game
        JMP exit_state_key                      ; if not, jump to the end of the routine

    pausing_game:
        CALL pause_game                         ; call the function to pause the game
        JMP exit_state_key                      ; jump to the end of the routine

    resuming_game:
        CALL resume_game                        ; call the function to resume the game
        JMP exit_state_key                      ; jump to the end of the routine

    end_game_key_pressed:
        CMP R2, PLAYING                         ; check if the current game state is the PLAYING state
        JZ ending_game                          ; if so, jump to ending_game
        CMP R2, PAUSED                          ; if not, check if the current game state is the PAUSED state
        JZ ending_game                          ; if so, jump to ending_game
        JMP exit_state_key                      ; if not, jump to the end of the routine

    ending_game:
        CALL end_game                           ; call the function to end the game

    exit_state_key:
        POP R2                                  ; restore the previous values of the modified registers
        POP R1
        RET


; *****************************************************************************************************************************
; PAUSE_GAME - Pauses the game.
; Updates the game state to PAUSED and selects a different front scenario to visually indicate that the game is paused.
; Additionally, pauses all sounds.
; *****************************************************************************************************************************
pause_game:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    DI                                          ; disable interrupts
    MOV [PAUSE_ALL_SOUND], R1                   ; pause the playback of all sounds (the value of R1 is irrelevant)          
    MOV R1, PAUSED_IMG                          ; store the number of the pause image in R1
    MOV [SELECT_FRONT_IMG], R1                  ; select the pause image as the front scenario
    MOV R1, PAUSED                              ; store the value of the PAUSED game state in R1
    MOV [GAME_STATE], R1                        ; update the current game state to PAUSED
    
    POP R1                                      ; restore the previous value of the modified register
    RET

; *****************************************************************************************************************************
; RESUME_GAME - Resumes the game.
; Updates the game state to PLAYING and deletes the front scenario that says PAUSED to visually indicate that the game is no
; longer paused. Additionally, resumes the playback of the background music PACMAN THEME.
; *****************************************************************************************************************************
resume_game:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    EI                                          ; enable interrupts
    MOV R1, PACMAN_THEME                        ; store the number of the PACMAN THEME sound in R1
    MOV [RESUME_SOUND], R1                      ; resume the playback of the PACMAN THEME sound
    MOV R1, PAUSED_IMG                          ; store the number of the pause image in R1
    MOV [DELETE_FRONT_IMG], R1                  ; delete the pause image as the front scenario
    MOV R1, PLAYING                             ; store the value of the PLAYING game state in R1
    MOV [GAME_STATE], R1                        ; update the current game state to PLAYING
    
    POP R1                                      ; restore the previous value of the modified register
    RET

; *****************************************************************************************************************************
; END_GAME - Ends the game.
; Updates the game state to GAME_OVER and changes the background to visually indicate that the game has ended. Plays the GAME
; OVER sound. Stops accepting interrupts.
; *****************************************************************************************************************************
end_game:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    DI                                          ; disable interrupts
    DI0                                         ; disable interrupt 0
    DI1                                         ; disable interrupt 1
    DI2                                         ; disable interrupt 2
    DI3                                         ; disable interrupt 3
    MOV [DELETE_SCREEN], R1                     ; delete all pixels on the screen (the value of R1 is irrelevant)
    MOV R1, GAME_OVER_SOUND                     ; store the number of the GAME_OVER_SOUND in R1
    MOV [PLAY_MEDIA], R1                        ; play the game over sound
    MOV R1, GHOSTS_GIF                          ; store the number of the GHOSTS_GIF video in R1
    MOV [LOOP_MEDIA], R1                        ; loop the GHOSTS_GIF video
    MOV R1, GAME_OVER_IMG                       ; store the number of the GAME_OVER_IMG front image in R1
    MOV [SELECT_FRONT_IMG], R1                  ; select GAME_OVER_IMG as the front image
    MOV R1, GAME_OVER                           ; store the value of the GAME_OVER state in R1
    MOV [GAME_STATE], R1                        ; update the current game state to GAME_OVER

    POP R1                                      ; restore the previous value of the modified register
    RET

; *****************************************************************************************************************************
; VICTORY - Ends the game with a victory screen.
; UPDATES the game state to WON and shows the victory screen.
; *****************************************************************************************************************************
victory:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    DI                                          ; disable interrupts
    DI0                                         ; disable interrupt 0
    DI1                                         ; disable interrupt 1
    DI2                                         ; disable interrupt 2
    DI3                                         ; disable interrupt 3
    MOV R1, WIN_SOUND                           ; store the number of the WIN_SOUND in R1
    MOV [PLAY_MEDIA], R1                        ; play the win sound
    MOV R1, VICTORY_IMG                         ; store the number of the VICTORY_IMG video in R1
    MOV [SELECT_BACKGROUND_IMG], R1             ; select VICTORY_IMG as the background
    MOV [DELETE_SCREEN], R1                     ; delete all pixels on the screen (the value of R1 is irrelevant)
    MOV R1, WON                                 ; store the value of the WON state in R1
    MOV [GAME_STATE], R1                        ; update the current game state to WON

    POP R1                                      ; restore the previous value of the modified register
    RET

; *****************************************************************************************************************************
; DELAY - Introduces a delay
; *****************************************************************************************************************************
delay:
    PUSH R0                                     ; save the value of R0
    MOV R0, DELAY                               ; move the value of DELAY (large number) to R0

delay_loop:
    DEC R0                                      ; decrement the value of R0
    JNZ delay_loop                              ; repeat the loop until R0 reaches 0
    POP R0                                      ; restore the value of R0
    RET

; *****************************************************************************************************************************
; INT_ROT_0 - Interrupt service routine for interrupt 0.
;             Used to signal that the ghosts should be moved.
; *****************************************************************************************************************************
int_rot_0:
    PUSH R1                                     ; save the previous value of the register that is altered in this function
    PUSH R0
    
    MOV R1, 1                                   ; store the value 1 in R1
    MOV [int_0], R1                             ; signal that the interrupt occurred
    MOV R1, 10                                  ; store the value 10 in R1
    MOV R0, [COUNT_INT_0]                       ; store the value of COUNT_INT_0 in R0
    INC R0                                      ; increment the value of COUNT_INT_0
    CMP R0, R1                                  ; compare the value of COUNT_INT_0 with 10
    JNZ int_rot_0_end                           ; if not equal to 10, do nothing
    MOV R0, 0                                   ; if equal to 10, reset the interrupt counter
    int_rot_0_end:
        MOV [COUNT_INT_0], R0                   ; update the value of COUNT_INT_0
    POP R0
    POP R1                                      ; restore the previous value of the modified register
    RFE                                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_1 - Interrupt service routine for interrupt 1.
;             Used to signal that the counter needs to be updated.
; *****************************************************************************************************************************
int_rot_1:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    MOV R1, 1                                   ; store the value 1 in R1
    MOV [int_1], R1                             ; signal that the interrupt occurred

    POP R1                                      ; restore the previous value of the modified register
    RFE                                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_2 - Rotina de atendimento da interrupção 2
;             Usada sinalizar contar o tempo que a explosão fica vísivel.
; *****************************************************************************************************************************
int_rot_2:
    PUSH R1                                     ; guarda o valor anterior do registo que é alterado nesta função

    MOV R1, 1                                   ; guarda em R1 o valor 1
    MOV [int_2], R1                             ; sinaliza que a interrupção ocorreu
    
    POP R1                                      ; recupera o valor anterior do registo modificado
    RFE                                         ; Return From Exception

; *****************************************************************************************************************************
; INT_ROT_3 - Interrupt service routine for interrupt 3.
;
; *****************************************************************************************************************************
int_rot_3:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    MOV R1, 1                                   ; store the value 1 in R1
    MOV [int_3], R1                             ; signal that the interrupt occurred

    POP R1                                      ; restore the previous value of the modified register
    RFE                                         ; Return From Exception


;*****************************************************************************************************************************
; PSEUDO_RANDOM - Generates a pseudo-random number between 0 and 15.
; Returns: R6 - the pseudo-random number
;               
; *****************************************************************************************************************************
pseudo_random:
    PUSH R1                                     ; save the previous value of the register that is altered in this function

    MOV  R1, KEY_COL                            ; PIN peripheral
    MOVB R6, [R1]                               ; read the peripheral
    SHR R6, 4                                   ; shift the bits in the air to the lower weight positions
    
    POP R1                                      ; restore the previous value of the modified register
    RET

; *****************************************************************************************************************************
; SPAWN_GHOSTS - Draws the ghosts according to the maximum number of allowed ghosts.
; *****************************************************************************************************************************
spawn_ghosts:
    PUSH R1                                     ; save the previous values of the registers that are altered in this function
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9

    MOV R3, [NUM_GHOSTS]                        ; store the number of ghosts in the game
    MOV R5, MAX_GHOSTS                          ; store the maximum number of ghosts
    CMP R3, R5                                  ; check if we have reached the maximum number
    JZ spawn_ghosts_end                         ; if so, jump to the end of the routine
    CALL pseudo_random                          ; if not, call the function to generate a random number between 0 and 15 stored in R0
    CMP R6, 3                                   ; check if the random number is 3
    JNZ spawn_ghosts_end                        ; if not 3, jump to the end of the routine
    MOV R0, [COUNT_INT_0]                       ; store in R0 the number of times we handled interrupt 0
    MOV R2, 9                                   ; store in R2 the value 10
    CMP R0, R2                                  ; check if the number of times we handled interrupt 0 is equal to 10
    JNZ spawn_ghosts_end                        ; if not equal to 10, jump to the end of the routine
    MOV R2, 0                                   ; if equal to 10, reset the interrupt counter
    MOV [COUNT_INT_0], R2                       ; reset the interrupt counter
    MOV R8, 0                                   ; start by checking ghost 0
    for_max_ghosts:
        CMP R5, 0                               ; check if we have seen all the ghosts
        JZ spawn_ghosts_end                     ; if so, jump to the end of the routine
        check_aliveness:
            MOV R9, R8                          ; create a copy of R8 that will be edited
            MOV R1, ALIVE_GHOSTS                ; address of the alive_ghosts table
            SHL R9, 1                           ; multiply the value of R9 by two (2 because WORD)
            ADD R9, R1                          ; address of the value indicating the "aliveness" of the ghost in question
            MOV R7, [R9]                        ; R7 stores the value indicating if the ghost is alive
            CMP R7, 1                           ; check if the ghost is alive
            JZ next_ghost                       ; if alive, check the next ghost
    continue:
            MOV R7, R8                          ; create a copy of R8 that will be altered
            MOV R4, 6                           ; store in R4 the number 3 which we want to multiply
            MUL R7, R4                          ; if 3, get the relative position at the top of the GHOST_POS table of the ghost's row in question
            MOV R4, GHOST_POS                   ; address of the ghost_pos table
            ADD R7, R4                          ; address of the ghost's row in question
            MOV R1, [R7]                        ; row of the ghost in question
            ADD R7, 2                           ; address of the column
            MOV R2, [R7]                        ; column of the ghost in question
            ADD R7, 2                           ; address of the table that defines the ghost in question
            MOV R4, [R7]                        ; store the table that defines the ghost in question in R4
            CALL draw_object                    ; function that draws an object, in this case, the ghost
            MOV R1, ALIVE_GHOSTS                ; address of the alive_ghosts table
            MOV R9, R8                          ; copy of R8
            SHL R9, 1                           ; multiply the value of 98 by two (2 because WORD)
            ADD R9, R1                          ; address of the value indicating the "aliveness" of the ghost in question
            MOV R2, 1                           ; store in R2 the value 1 indicating the ghost is alive
            MOV [R9], R2                        ; update the ghost's state to alive
            INC R3                              ; increment the number of alive ghosts
            JMP spawn_ghosts_end                ; jump to the end of the routine
        next_ghost:
            INC R8                              ; next ghost
            DEC R5                              ; decrement the value of R3 to advance the for loop
            JMP for_max_ghosts                  ; jump to the beginning of the "for" loop
    
spawn_ghosts_end:
    MOV [NUM_GHOSTS], R3                        ; store in memory the new number of alive ghosts
    POP R9                                      ; restore the previous values of the modified registers
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
; GHOST_CYCLE - Chooses which ghosts will move after an interrupt and calls the function to move them. They will evolve every
;               3.2 seconds.
; *****************************************************************************************************************************
ghost_cycle:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
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

    MOV R0, [int_0]                             ; store in R0 the value that indicates the occurrence of interrupt 0
    CMP R0, TRUE                                ; if the value is equal to TRUE (1), then the interrupt occurred
    JNZ exit_ghost_cycle                        ; if it did not occur, jump to the end of the routine
    MOV R0, [COUNT_INT_0]                       ; store in R0 the number of times we handled interrupt 0 in this function
    MOV R2, GHOST_RYTHM                         ; store in R2 the value 8 (every X times we want to move the ghost)
    MOD R0, R2                                  ; store in R0 the remainder of the integer division by 10
    JNZ exit_ghost_cycle                        ; if the remainder is not 0, jump to the end of the routine
    MOV R3, MAX_GHOSTS                          ; store the maximum number of ghosts
    MOV R0, 0                                   ; we will start with ghost 0
    check_all_ghosts:
        CMP R3, 0                               ; check if we have seen all the ghosts
        JZ exit_ghost_cycle                     ; if so, jump to the end of the routine
        MOV R9, R0                              ; create a copy of R0 that will be edited
        MOV R1, ALIVE_GHOSTS                    ; address of the alive_ghosts table
        SHL R9, 1                               ; multiply the value of R9 by two (2 because WORD)
        ADD R9, R1                              ; address of the value that indicates if the ghost in question is alive or not
        MOV R7, [R9]                            ; R7 stores the value indicating if the ghost is alive
        CMP R7, 1                               ; check if the ghost is alive
        JNZ check_next_ghost                    ; if not, check the next ghost
        MOV R7, R0                              ; if alive, create a copy of R0 that will be altered
        MOV R4, 6                               ; store in R4 the number 3 which we want to multiply
        MUL R7, R4                              ; get the relative position at the top of the GHOST_POS table of the ghost's row in question
        MOV R4, GHOST_POS                       ; address of the ghost_pos table
        ADD R7, R4                              ; address of the ghost's row in question 
        MOV R10, R7                             ; store a copy of the row address
        MOV R1, [R7]                            ; row of the ghost in question
        ADD R7, 2                               ; address of the column
        MOV R11, R7                             ; store a copy of the column address
        MOV R2, [R7]                            ; column of the ghost in question
        ADD R7, 2                               ; address of the table that defines the ghost 
        MOV R4, [R7]                            ; store the address of the table that defines the ghost in R4
        CALL animate_ghost                      ; call the function that animates the ghost
        MOV [R10], R1                           ; update the memory with the new current row of the ghost (post-movement)
        MOV [R11], R2                           ; update the memory with the new current column of the ghost (post-movement)
        INC R3                                  ; increment the number of alive ghosts
    
    check_next_ghost:
        INC R0                                  ; next ghost
        DEC R3                                  ; decrement the value of R3 to advance the loop
        JMP check_all_ghosts                    ; jump to the beginning of the loop
    
    exit_ghost_cycle:
        MOV R0, FALSE                           ; store in R0 the value FALSE (0)
        MOV [int_0], R0                         ; reset the interrupt occurrence indicator to 0 since we have handled it
        POP R11                                 ; restore the previous values of the modified registers
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
; ANIMATE_GHOST - Animates the ghost.
; Arguments:   R1 - row where the ghost is located
;               R2 - column where the ghost is located
;               R4 - address of the table that defines the ghost
; *****************************************************************************************************************************
animate_ghost:
    PUSH R3                                     ; save the previous values of the registers that are altered in this function
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R5, [PAC_LIN]                           ; row of pacman
    MOV R6, [PAC_COL]                           ; column of pacman
    CALL choose_ghost_direction                 ; call the function that chooses the direction the ghost moves to approach pacman
    MOV R3, R4                                  ; copy of R4 for argument in the move_object function
    CALL move_object		                    ; call the function that moves the ghost
    
    POP R8                                      ; restore the previous values of the modified registers
    POP R7
    POP R6
    POP R5
    POP R3
    RET

; *****************************************************************************************************************************
; CHOOSE_GHOST_DIRECTION - Routine to determine in which direction the ghost should move to approach pacman.
;
; Arguments:   R1 - row where the ghost is located
;               R2 - column where the ghost is located
;               R5 - row where pacman is located
;               R6 - column where pacman is located
;
; Returns:      R7 - direction of the object's movement vertically (value to add to the row in each movement: +1 for down, -1 for up)
;               R8 - direction of the object's movement horizontally (value to add to the column in each movement: +1 for right, -1 for left)
; *****************************************************************************************************************************
choose_ghost_direction:
    CMP R5, R1                                  ; compare the row where pacman is with the row of the ghost
    JLT up                                      ; if pacman's row is smaller, jump to up as the ghost needs to move up
    JGT down                                    ; if pacman's row is larger, jump to down as the ghost needs to move down
    MOV R7, 0                                   ; if neither, they are in the same row, so the ghost doesn't need to move vertically
    JMP check_horizontal                        ; jump to check_horizontal
        
    up:
    MOV R7, -1                                  ; store -1 in R7 (indicates up)
    JMP check_horizontal                        ; jump to check_horizontal
    
    down:
    MOV R7, 1                                   ; store 1 in R7 (indicates down)

    check_horizontal:
        CMP R6, R2                              ; compare the column where pacman is with the column of the ghost
        JLT left                                ; if pacman's column is smaller, jump to left as the ghost needs to move left
        JGT right                               ; if pacman's column is larger, jump to right as the ghost needs to move right
        MOV R8, 0                               ; if neither, they are in the same column, so the ghost doesn't need to move horizontally
        JMP leave_ghost_direction               ; jump to the end of the routine

        left:
        MOV R8, -1                              ; store -1 in R8 (indicates left)
        JMP leave_ghost_direction               ; jump to the end of the routine

        right:
        MOV R8, 1                               ; store 1 in R8 (indicates right)

    leave_ghost_direction:
        RET

; *****************************************************************************************************************************
; MOVE_PACMAN - Moves Pacman with animation.
; Arguments:   R1 - row
;              R2 - column
;              R3 - table that defines pacman
;              R4 - table that defines pacman's animation
;              R7 - direction of the object's movement vertically (value to add to the row in each movement: +1 for down, -1 for up)
;              R8 - direction of the object's movement horizontally (value to add to the column in each movement: +1 for right, -1 for left)
;
; Returns:     R1 - new row value, after the movement
;              R2 - new column value, after the movement
; *****************************************************************************************************************************
move_pacman:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
    PUSH R6
    PUSH R9
    PUSH R10

    CALL choose_object_action                   ; calls the function that checks if pacman is trying to cross any limits with this movement
    CMP R0, 0                                   ; compares the return value of the function (R0) with 0
    JZ end_pacman_movement                      ; if the function returns 0, jumps to end_movement as the movement is prohibited
    CMP R0, 3                                   ; compares the return value of the function (R0) with 3
    JLT check_pacman_candy                      ; if the function returns 3, does not jump and calls the explosion function
    CALL explosion                              ; calls the explosion function
    JMP end_pacman_movement                     ; jumps to the end of the routine

check_pacman_candy:
    CMP R0, 2                                   ; compares the return value of the function (R0) with 2
    JNZ new_position_pacman                     ; if the return value of the function is not 2, jumps to new_position_pacman
    MOV R0, EAT_CANDY                           ; gets the address of the candy eating sound
    MOV [PLAY_MEDIA], R0                        ; plays the sound
    CALL delete_candy                           ; deletes the candy
    MOV R10, [REMAINING_CANDIES]                ; stores in register R10 how many candies are left to eat
    SUB R10, 1                                  ; subtracts the eaten candy
    CMP R10, 0                                  ; checks if there are any candies left
    JNZ skip_victory                            ; if there are still candies left, skips the victory
    CALL victory                                ; if no candies are left, calls the victory function
    skip_victory:
        MOV [REMAINING_CANDIES], R10            ; stores the number of candies that are still left to eat
        JMP end_pacman_movement                 ; jumps to the end of the routine

new_position_pacman:
    CALL delete_object                          ; deletes pacman
    ADD R1, R7                                  ; gets the new row
    ADD R2, R8                                  ; gets the new column
    CALL draw_object                            ; draws the animated version of pacman
    CALL delay                                  ; calls a function to delay/slow down the movement
    CALL delete_object                          ; deletes the animated version of pacman
    MOV R4, R3                                  ; moves the value of R3 to R4 to be used as an argument in the next function
    CALL draw_object                            ; draws the final version of pacman
    CALL delay                                  ; calls a function to delay/slow down the movement 

end_pacman_movement:
    POP R10                                     ; restores the previous values of the modified registers
    POP R9                                  
    POP R6
    POP R0
    RET

; *****************************************************************************************************************************
; SCORE_CYCLE - Increments the score counter every 5 interrupts 1 to count in seconds (200ms * 5 = 1 second).
; *****************************************************************************************************************************
score_cycle:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    
    MOV R0, [int_1]                             ; store in R0 the value that indicates the occurrence of interrupt 1
    CMP R0, TRUE                                ; if the value is equal to TRUE (1), then the interrupt occurred
    JNZ exit_score_cycle                        ; if it did not occur, jump to the end of the routine
    MOV R0, [COUNT_INT_1]                       ; store in R0 the number of times we handled interrupt 1 in this function
    INC R0                                      ; increment R0
    MOV R2, 5                                   ; store in R2 the value 5 (every 5 times we want to increment the counter)
    MOD R0, R2                                  ; store in R0 the remainder of the integer division by 5
    MOV [COUNT_INT_1], R0                       ; update the memory with the value of R0
    JNZ exit_score_cycle                        ; if the remainder is not 0, jump to the end of the routine
    MOV R0, SCORE                               ; get the address of the current score
    MOV R1, [R0]                                ; get the value of the current score
    MOV R2, UPPER_LIMIT                         ; get the value of the upper limit
    CMP R1, R2                                  ; determine if the current value is the upper limit
    JZ time_exceeded                            ; if so, jump to time_exceeded to end the game
    ADD R1, 1                                   ; otherwise, increment the score by 1
    MOV R3, MASK_LSD                            ; copy the mask of the units to R3
    MOV R4, R1                                  ; copy the score value to R4
    AND R4, R3                                  ; mask to get the least significant digit of R4
    MOV R2, 0AH                                 ; copy the hexadecimal value A to R2
    CMP R4, R2                                  ; check if the least significant digit is 10 (hex 'A')
    JZ skip_hex                                 ; if so, jump to skip_hex to skip the values A-F
    MOV [DISPLAYS], R1                          ; if not, update the display
    MOV [R0], R1                                ; store the new value in memory
    JMP exit_score_cycle                        ; jump to the end of the routine
    
    skip_hex:
        ADD R1, INC_TENS                        ; add 6 to the counter to skip the values A - F
        MOV R3, MASK_TENS                       ; copy the mask of the tens to R3
        MOV R4, R1                              ; copy the counter value to R4
        AND R4, R3                              ; apply the tens mask
        MOV R2, 0A0H                            ; copy the hexadecimal value 0A0H to R2
        CMP R4, R2                              ; check if the tens are at A
        JZ jump_hundreds                        ; if so, jump to jump_hundreds to increment to 256H which shows 100 on the displays
        MOV [DISPLAYS], R1                      ; update the display
        MOV [R0], R1                            ; store the new value in memory
        JMP exit_score_cycle                    ; jump to the end of the routine

    jump_hundreds:
        MOV R3, INC_HUNDREDS                    ; copy 96 to R3 to skip to simulate the hundreds in hexadecimal
        ADD R1, R3                              ; add the value of R3(96) to R1
        MOV [DISPLAYS], R1                      ; update the display
        MOV [R0], R1                            ; store the new value in memory
        JMP exit_score_cycle                    ; jump to the end of the routine

    time_exceeded:
        CALL end_game                           ; call the function to end the game
        MOV R1, TIME_LIMIT_IMG                  ; store in R1 the number of the front scenario TIME_LIMIT_IMG
        MOV [SELECT_FRONT_IMG], R1              ; select TIME_LIMIT_IMG as the front scenario

    exit_score_cycle:
        MOV R0, FALSE                           ; store in R0 the value FALSE (0)
        MOV [int_1], R0                         ; reset the interrupt occurrence indicator to 0 since we have handled it
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

; *****************************************************************************************************************************
; CHECK_EXPLOSION - Checks if the explosion has occurred and deletes it after 1.5 seconds.
; *****************************************************************************************************************************
check_explosion:
    PUSH R0                                     ; save the previous values of the registers that are altered in this function
    PUSH R1
    PUSH R2
    PUSH R4

    MOV R0, TRUE                                ; store the value of TRUE (1) in R0
    MOV R4, [EXPLOSION_EVENT]                   ; store in R4 the value that indicates if the explosion has occurred
    CMP R4, R0                                  ; check if the explosion has occurred
    JNZ exit_check_explosion                    ; if not, jump to the end of the routine
    MOV R0, [int_2]                             ; if so, store in R0 the value that indicates the occurrence of interrupt 2
    CMP R0, TRUE                                ; if the value is equal to TRUE (1), then the interrupt occurred
    JNZ exit_check_explosion                    ; if it did not occur, jump to the end of the routine
    MOV R0, [COUNT_INT_2]                       ; store in R0 the number of times we handled interrupt 2 in this function
    INC R0                                      ; increment R0
    MOV R2, 500                                 ; store in R2 the value 500 (every 500 times we want to increment the counter)
    MOD R0, R2                                  ; store in R0 the remainder of the integer division by 500
    MOV [COUNT_INT_2], R0                       ; update the memory with the value of R0
    JNZ exit_check_explosion                    ; if the remainder is not 0, jump to the end of the routine
    MOV R1, FALSE                               ; store the value of FALSE (0) in R1
    MOV [EXPLOSION_EVENT], R1                   ; update the memory with the value FALSE (0)
    MOV R1, [PAC_LIN]                           ; store in R1 the row where the explosion occurred
    MOV R2, [PAC_COL]                           ; store in R2 the column where the explosion occurred
    MOV R4, DEF_EXPLOSION                       ; store in R4 the table that defines the explosion
    CALL delete_object                          ; call the function to delete the explosion
    CALL end_game                               ; call the function to end the game

exit_check_explosion:
    POP R4                                      ; restore the previous values of the modified registers
    POP R2
    POP R1
    POP R0
    RET
