;------------------------------------------------------------
; CPE 233 FINAL PROJECT v0.01
;
; This program does the following:
;   1) draws a ring on the outer border in black. 
;   2) sets the background to white.
;   3) draws a gold block in the center
;   4) spawns the player and allows movement.
;
;-------------------------------------------------------------
.EQU BUTTONS_PORT = 0xFF
.EQU KEYBOARD_ID = 0x44
.EQU GOLD_COLOR = 0xE0
.EQU WALL_COLOR = 0xFF

.EQU VGA_HADD  = 0x90
.EQU VGA_LADD  = 0x91
.EQU VGA_COLOR = 0x92
.EQU VGA_READ  = 0x93
.EQU RAND_PORT = 0x0F
.EQU BUTTON_PORT = 0xFF
.EQU SWITCHES_PORT = 0x20

.EQU BG_COLOR       = 0xFF             ; Background        :  White
.EQU BACKTRACK_HALL = 0x00             ; Backtracked Halls :  Black
.EQU GEN_HALL       = 0xE0             ; Initialized Halls :  Red
.EQU GOAL_COLOR     = 0xF8             ; Goal: Golden Yellow
.EQU BOUND_COLOR    = 0x04             ; Bounds: TINTED GREEN
.EQU ERROR_NEIGHBOR_COLOR    = 0xE0    ;red
.EQU ERROR_BACKTRACK_COLOR   = 0x03    ;blue
.EQU ERROR_N_INCR_COLOR      = 0x1F    ;green

;r6 is used for color output
;r7 is used for Y
;r8 is used for X
;r9 is used for ending value of lines (x or y)

;r11 is for reading in color data

;r10 is for neighbor incrementing

;r31 is for random values or neighbor checking
;r30 is for unvisited neighbor index
;r28 keeps count of visited neighbors
;r29 is for origin checking

;r22 is adjacent indicator

;r20, r21 used for saving initial address for neighbor checking

;r0 is ORIGIN X
;r1 is ORIGIN Y
;--------------------------------------------------
.CSEG
.ORG 0x01
;CHECK Neighbor and backtrack fns.
INIT:  CLI
       IN   R0, SWITCHES_PORT
       CMP  R0, 0x00
       BREQ INIT
INIT_WIN:MOV  r6, BOUND_COLOR	
       CALL draw_outer_ring
       CALL draw_wallgrid
     
       MOV  r7, 0x01
       MOV  r8, 0x01
       MOV  r6, 0x1E                   ;player color: BLUE
       CALL draw_dot

GEN_MAZE:
       CALL PICK_RAND_GOAL            ;start from random goal block,
                                      ;ensures solvability
       MOV  r0, r7                    ;SAVE ORIGIN ADDRESS
       MOV  r1, r8
  SEARCH:
       MOV  r6, GEN_HALL
       CALL draw_dot
       CALL CHECK_NEIGHBORS           ;return unvisited neighbor indicator in r30, keeps main address
                                      ;address of unvisited neighbor is in r2, r3
       CMP  R28, 0x04                 ;4 means all neighbors visited
       BREQ BACKTRACK
       CMP  R22, 0x01                 ;Check if we ran into a bounded cell 
       BREQ SEARCH                    

  INCR:
       MOV  r6, GEN_HALL

    SOUTH: CMP  R30, 0x01                 ;South neighbor
           BRNE EAST
           ADD  r7,  0x01
           CALL draw_dot                  ;removes wall btw. main addr. and neighbor
           ADD  r7,  0x01
           BRN  SEARCH
         
    EAST : CMP  R30, 0x02                 ;East Neighbor
           BRNE WEST
           ADD  r8,  0x01
           CALL draw_dot
           ADD  r8,  0x01
           BRN  SEARCH

    WEST : CMP  R30, 0x03                 ;West Neighbor
           BRNE NORTH
           SUB  r8,  0x01
           CALL draw_dot
           SUB  r8,  0x01
           BRN  SEARCH

    NORTH: CMP  R30, 0x04                ;North Neighbor
           BRNE ERR_N_INCR ;ERROR OCURRING!!! (R30 should ONLY ever be these four!)
           SUB  r7,  0x01
           CALL draw_dot
           SUB  r7,  0x01
           BRN  SEARCH
                
  BACKTRACK:  
	   MOV  r6, BACKTRACK_HALL       ;black hall for visited + backtracked
       CALL draw_dot

       CALL CHECK_ORIGIN              ;checks against value of initial goal cell. R29 --> 1 if done
       CMP  R29, 0x01
       BREQ END
       
       B_NORTH: 
          SUB r7, 0x01
          CALL read_dot
          CMP R11, GEN_HALL
          BREQ SEARCH
          ADD r7, 0x01
       B_WEST:
          SUB r8, 0x01
          CALL read_dot
          CMP R11, GEN_HALL
          BREQ SEARCH
          ADD r8, 0x01
          
       B_EAST :
          ADD r8, 0x01
          CALL read_dot
          CMP R11, GEN_HALL
          BREQ SEARCH
          SUB r8, 0x01
       B_SOUTH:
          ADD r7, 0x01
          CALL read_dot
          CMP R11, GEN_HALL
          BREQ SEARCH
          SUB r7, 0x01
               
       BRN  END ;ONLY TEMPORARY TO CHECK ERRORS IN CODE, WILL EVENTUALLY LEAD TO AN ERROR

;ERROR-CHECKING FUNCTIONS FOR DEAD-END CODE :)
RAND_ERR  : 
ERR_N     :   MOV r6, ERROR_NEIGHBOR_COLOR
              BRN END_ERROR

ERR_B     :   MOV r6, ERROR_BACKTRACK_COLOR
              BRN END_ERROR
ERR_N_INCR:   MOV r6, ERROR_N_INCR_COLOR
              BRN END_ERROR       

END_ERROR :   CALL draw_error
END       :   MOV R6, GOAL_COLOR
              MOV R7, R0
              MOV R8, R1
              CALL draw_dot
SPAWN_PLAYER: MOV  r7, 0x01
              MOV  r8, 0x01
              MOV  r6, 0x1E                   ;player color: BLUE
              CALL draw_dot

              MOV  R23, 0x00
              MOV  R27, 0x00
              SEI
MAIN      :   
MAIN_CHECK:   CMP  R23, 0x01 ;check if goal has been reached
              BREQ INIT_WIN
              CMP  R23, 0x02
              BREQ SPAWN_PLAYER
              CALL MOVE_PLAYER
              SEI
              BRN  MAIN

;------------------------------------------------------------------------------------------ 
;- Subroutine: MOVE_PLAYER
;-
;- This subroutine moves the player to a new position based on the button pressed:
;-
;- Move_Right: add one to x-coordinate
;- Move_Left: sub one to x-coordinate
;- Move_Up: add one to y-coordinate
;- Move_Down: sub one to y-coordinate
;------------------------------------------------------------------------------------------
ISR:
    IN r27,KEYBOARD_ID         ; Get button input from player
    RETIE

MOVE_PLAYER:
        CMP r27,0x1B                ; Check to see if player wants to go down
        BREQ MOVE_DOWN
        CMP r27,0x23                ; Check to see if player wants to go right
        BREQ MOVE_RIGHT
        CMP r27,0x1C                ; Check to see if player wants to go left
        BREQ MOVE_LEFT
        CMP r27,0x1D                ; Check to see if player wants to go up
        BREQ MOVE_UP
        RETIE

MOVE_RIGHT: 
        MOV r6, 0x00               ; Set old position as a background
        CALL draw_dot
        ADD r8,0x01                
        CALL read_dot_move
        CMP  R23, 0x01
        BREQ WINNER
        CMP  R23, 0x02
        BREQ WALL_FAIL
        MOV r6, 0x1E
        CMP r8,0x50                ; Check to see if player goes off screeN
        BREQ MOVE_LEFT             ; If player does, move player back to old position               ; put the player in the new position
        CALL draw_dot
        MOV  R23, 0x00
        MOV  R27, 0x00
        RETIE

MOVE_LEFT: 
        MOV r6, 0x00               ; Set old position as a background
        CALL draw_dot
        SUB r8,0x01
        CALL read_dot_move
        CMP  R23, 0x01
        BREQ WINNER
        CMP  R23, 0x02
        BREQ WALL_FAIL
        MOV r6, 0x1E
        CMP r8,0xFF                ; Check to see if player goes off screen
        BREQ MOVE_RIGHT            ; If player does, move player back to old position
        CALL draw_dot
        MOV  R23, 0x00
        MOV  R27, 0x00
        RETIE

MOVE_UP: 
        MOV r6, 0x00               ; Set old position as a background
        CALL draw_dot
        SUB r7, 0x01
        CALL read_dot_move
        CMP  R23, 0x01
        BREQ WINNER
        CMP  R23, 0x02
        BREQ WALL_FAIL
        MOV r6, 0x1E
        CMP r7,0xFF                ; Check to see if player goes off screen
        BREQ MOVE_DOWN             ; If player does, move player back to old position
        CALL draw_dot
        MOV  R23, 0x00
        MOV  R27, 0x00
        RETIE

MOVE_DOWN: 
        MOV r6, 0x00               ; Set old position as a background
        CALL draw_dot
        MOV r6, 0x1E
        ADD r7,0x01
        CALL read_dot_move
        CMP  R23, 0x01
        BREQ WINNER
        CMP  R23, 0x02
        BREQ WALL_FAIL
        CMP r7,0x3C                ; Check to see if player goes off screen
        BREQ MOVE_UP               ; If player does, move player back to old position
        CALL draw_dot
        MOV  R23, 0x00
        MOV  R27, 0x00
        RETIE

; -----------------------------------------------------------------------------------------

WINNER: 
        MOV R23, 0x01
        RETID

WALL_FAIL:
        MOV R23, 0x02
        RETID
        ;MOV r6, 0x1E
        ;CMP r1,0x01                ; Check to see if player went down
        ;BREQ RETURN_UP
        ;CMP r1,0x02                ; Check to see if player went right
        ;BREQ RETURN_LEFT
        ;CMP r1,0x04                ; Check to see if player went left
        ;BREQ RETURN_RIGHT
        ;CMP r1,0x08                ; Check to see if player went up
        ;BREQ RETURN_DOWN

RETURN_UP:
        SUB r7, 0x01
        CALL draw_dot
        RETID
RETURN_LEFT: 
        SUB r8, 0x01
        CALL draw_dot
        RETID
RETURN_RIGHT:
        ADD r8, 0x01
        CALL draw_dot
        RETID
RETURN_DOWN:
        ADD r7, 0x01
        CALL draw_dot
        RETID


;----------------------------------------------------------------
; Subroutine: CHECK_NEIGHBORS
;
; This subroutine is designed to check each neighbor at 
; a central address. A "neighbor" is defined as 2 blocks
; away in each direction in the following configuration:
;                          3
;                          
;                     2    x    1
;
;                          0
; 
;Tweaked registers:  R28     --> counter
;                    R20,R21 --> Save central address
;                    R2, R3  --> Unvisited neighbor address 
;                    R31     --> start at random neighbor
;                    R11     --> VGA_READ_DATA
;
; R7,R8 will hold initial address, R6 will hold GEN_HALL
;----------------------------------------------------------------
CHECK_NEIGHBORS:
       MOV  R28, 0x00 ;initialize a counter
       MOV  R10, 0x00 ;initialize neighbor incrementer
       MOV  R22, 0x00 ;initialize bounded indicator
       MOV  R30, 0x00 ;reset neighbor indicator
       MOV  R20, r7   ;copy initial address
       MOV  R21, r8   

       CALL RAND_0to3 ;pick a random neighbor index
       MOV  R10, R31  ;copy initial random neighbor for incrementing

       CMP  R31, 0x00 ;Check which neighbor to go to first
       BREQ N_SOUTH
       CMP  R31, 0x01
       BREQ N_EAST
       CMP  R31, 0x02
       BREQ N_WEST
       CMP  R31, 0x03
       BREQ N_NORTH
       BRN  ERR_N       

  N_SOUTH:ADD  r7, 0x02 ;south neighbor
          CALL read_dot
          CMP  R11, BACKTRACK_HALL
          BREQ INCR_NEIGHBOR
          CMP  R11, GEN_HALL
          BREQ INCR_NEIGHBOR

          CMP  R11, BOUND_COLOR
          BREQ INCR_NEIGHBOR
          
          CMP  R11, BG_COLOR
          BRN S_UNVISITED

     S_UNVISITED:
          CALL check_adjacent
          CMP  R22, 0x01
          BREQ INCR_NEIGHBOR
          MOV  R30, 0x01     ;indicate south neighbor
          MOV  r7, R20
          MOV  r8, R21
          RET

  N_EAST: ADD  r8, 0x02 ;east neighbor
          CALL read_dot
          CMP  R11, BACKTRACK_HALL
          BREQ INCR_NEIGHBOR
          CMP  R11, GEN_HALL
          BREQ INCR_NEIGHBOR

          CMP  R11, BOUND_COLOR
          BREQ INCR_NEIGHBOR

          CMP  R11, BG_COLOR
          BRN E_UNVISITED

     E_UNVISITED:
          CALL check_adjacent
          CMP  R22, 0x01
          BREQ INCR_NEIGHBOR          
          MOV  R30, 0x02     ;indicate east neighbor
          MOV  r7, R20
          MOV  r8, R21
          RET

   N_WEST:SUB  r8, 0x02 ;west neighbor
          CALL read_dot
          CMP  R11, BACKTRACK_HALL
          BREQ INCR_NEIGHBOR
          CMP  R11, GEN_HALL
          BREQ INCR_NEIGHBOR

          CMP  R11, BOUND_COLOR
          BREQ INCR_NEIGHBOR

          CMP  R11, BG_COLOR
          BRN W_UNVISITED

      W_UNVISITED:
          CALL check_adjacent
          CMP  R22, 0x01
          BREQ INCR_NEIGHBOR
          MOV  R30, 0x03     ;indicate west neighbor
          MOV  r7, R20
          MOV  r8, R21
          RET

   N_NORTH:SUB  r7, 0x02 ;north neighbor
          CALL read_dot
          CMP  R11, BACKTRACK_HALL
          BREQ INCR_NEIGHBOR
          CMP  R11, GEN_HALL
          BREQ INCR_NEIGHBOR

          CMP  R11, BOUND_COLOR
          BREQ INCR_NEIGHBOR

          CMP  R11, BG_COLOR
          BRN N_UNVISITED

      N_UNVISITED:
          CALL check_adjacent
          CMP  R22, 0x01
          BREQ INCR_NEIGHBOR
          MOV  R30, 0x04     ;indicate north neighbor
          MOV  r7, R20
          MOV  r8, R21
          RET

   INCR_NEIGHBOR: ADD  R28, 0x01
                  MOV  r7, R20
                  MOV  r8, R21
                  CMP  R28, 0x04
                  BREQ TO_BACKTRACK
                  
                  ADD  R10, 0x01
                  CMP  R10, 0x04
                  BRNE NEXT_NEIGHBOR
                  MOV  R10, 0x00

       NEXT_NEIGHBOR:CMP  R10, 0x00
                     BREQ N_SOUTH
                     CMP  R10, 0x01
                     BREQ N_EAST
                     CMP  R10, 0x02
                     BREQ N_WEST
                     CMP  R10, 0x03
                     BREQ N_NORTH
                     BRN  ERR_N_INCR;shouldn't happen

       TO_BACKTRACK: MOV  R7, R20
                     MOV  R8, R21
                     RET
                  
;------------------------------------------------------------------------
; Subroutine: CHECK_ORIGIN
;
; This subroutine checks the current cell against the initial goal
; cell the maze began from. If it is, it returns a 1 in R29.
;
; Reads registers: r7, r8, r0, r1
;
; Tweaks register: r29
;------------------------------------------------------------------------       
CHECK_ORIGIN:
       MOV  R29, 0x00
       CMP  r7, r0
       BRNE NOPE
       CMP  r8, r1
       BRNE NOPE
       MOV  R29, 0x01
  NOPE:RET   
;-------------------------------------------------------------------------
; The following subroutine PICK_RAND_GOAL
; is designed to start the maze gen algorithm from
; a random goal block. 

; It uses the RAND_0to3 subroutine 
; and the configuration of goal blocks is as follows:
;
;                    0 1
;                    2 3
;
; Tweaked registers:  r31 (rand value)
;                     r7 (y val)
;                     r8 (x val)    
;-------------------------------------------------------------------------
PICK_RAND_GOAL: CALL RAND_0to3
                MOV  r6,  BG_COLOR
Northwest:      CMP  R31, 0x00
                BRNE Northeast
                ;Add bottom row, right column
                MOV  r7, 0x39
                MOV  r8, 0x04
                MOV  r9, 0x4B
                CALL draw_horizontal_line
                MOV  r7, 0x03
                MOV  r8, 0x3C
                MOV  r9, 0x38
                CALL draw_vertical_line

                MOV  r8,  0x28
                MOV  r7,  0x1E ;top left
                RET
                
Northeast:      CMP  R31, 0x01
                BRNE Southwest
                ;Add bot row, left column
                MOV  r7, 0x39
                MOV  r8, 0x04
                MOV  r9, 0x4B
                CALL draw_horizontal_line
                MOV  r7, 0x03
                MOV  r8, 0x03
                MOV  r9, 0x37
                CALL draw_vertical_line
                MOV  r8,  0x29
                MOV  r7,  0x1E ;top right
                RET

Southwest:      CMP  R31, 0x02
                BRNE Southeast
                ;Add top row, right column
                MOV  r7, 0x03
                MOV  r8, 0x04
                MOV  r9, 0x4B
                CALL draw_horizontal_line
                MOV  r7, 0x03
                MOV  r8, 0x3C
                MOV  r9, 0x37
                CALL draw_vertical_line
                MOV  r8,  0x28
                MOV  r7,  0x1F ;bottom left
                RET

Southeast:      CMP  R31, 0x03
                BRNE RAND_ERR
                ;Add top row, left column
                MOV  r7, 0x03
                MOV  r8, 0x04
                MOV  r9, 0x4B
                CALL draw_horizontal_line
                MOV  r7, 0x03
                MOV  r8, 0x03
                MOV  r9, 0x37
                CALL draw_vertical_line
                MOV  r8,  0x29
                MOV  r7,  0x1F ;bottom right
                RET

RAND_0to3:      IN   R31, RAND_PORT
                CMP  R31, 0x40
                BRCS RAND_0
                BREQ RAND_0
                CMP  R31, 0x80
                BRCS RAND_1
                BREQ RAND_1
                CMP  R31, 0xC0
                BRCS RAND_2
                BREQ RAND_2
                CMP  R31, 0xFF
                BRCS RAND_3
                BREQ RAND_3
                BRN  RAND_ERR

         
         RAND_0:MOV R31, 0x00
                RET
         RAND_1:MOV R31, 0x01
                RET
         RAND_2:MOV R31, 0x02
                RET
         RAND_3:MOV R31, 0x03
                RET

                ;CALL MOD_4
                ;CMP  R31, 0x04
                ;BRCC RAND_ERR
                ;RET
              
;----------------------------------------------------------------------
; Subroutines: draw_goal and draw_outer ring (Tested and verified)
;
; These subroutines use supplied VGA functions to draw a 2x2 goal in 
; the center of the screen and a 4x4 outer ring on the edges of the
; screen.
;----------------------------------------------------------------------
draw_goal:
       MOV r8,0x28 
       MOV r7,0x1E
       MOV r6,0xF8                            ;golden yellow
       CALL draw_dot
       ADD r8, 0x01
       CALL draw_dot
       ADD r7, 0x01
       CALL draw_dot
       SUB r8, 0x01
       CALL draw_dot
       RET

draw_outer_ring:
        MOV   r7,0x00                     ;y-value for horiz. line
  top:  MOV   r8,0x00                     ;starting x for top
        MOV   r9,0x4F                     ;ending x for top
        CALL  draw_horizontal_line
        ADD   r7, 0x01
        CMP   r7, 0x04
        BRNE  top
        
        MOV   r7,0x38                     ;y-value for horiz. line
  bott: MOV   r8,0x00                     ;starting x for bottom
        MOV   r9,0x4F                     ;ending x for bottom
        CALL  draw_horizontal_line
        ADD   r7, 0x01
        CMP   r7, 0x3C
        BRNE  bott

        MOV   r8,0x00                     ;x-value for vert. line
  left: MOV   r7,0x00                     ;starting y-val for left
        MOV   r9,0x3B                     ;ending y-val for left 
        CALL  draw_vertical_line
        ADD   r8, 0x01
        CMP   r8, 0x04
        BRNE  left

        MOV   r8,0x4C                     ;x-value for vert. line
 right: MOV   r7,0x00                     ;starting y-val for left
        MOV   r9,0x3B                     ;ending y-val for left 
        CALL  draw_vertical_line
        ADD   r8, 0x01
        CMP   r8, 0x50
        BRNE  right
        RET
;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 30x40 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r13,r7,r8,r9
;----------------------------------------------------------------------
draw_background: 
         MOV   r6,BG_COLOR              ; use default color
         MOV   r13,0x00                 ; r13 keeps track of rows
start:   MOV   r7,r13                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x4F 					; set to total number of columns
 
         CALL  draw_horizontal_line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x3B                 ; see if more rows to draw
         BRNE  start                    ; branch to draw more rows
         RET

draw_error: 
         MOV   r13,0x00                 ; r13 keeps track of rows
startt:  MOV   r7,r13                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x4F 					; set to total number of columns
 
         CALL  draw_horizontal_line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x3B                 ; see if more rows to draw
         BRNE  startt                    ; branch to draw more rows
         RET

draw_wallgrid: 
         MOV   r6,BG_COLOR              ; use default color
         MOV   r13,0x04                 ; r13 keeps track of rows
strt:    MOV   r7,r13                   ; load current row count 
         MOV   r8,0x04                  ; restart x coordinates
         MOV   r9,0x4B 					; set to total number of columns
 
         CALL  draw_horizontal_line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x38                 ; see if more rows to draw
         BRNE  strt                    ; branch to draw more rows
         RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4,r5
;
;  Added subroutine: place_dot
;
;  Readies a pixel to read VGA color data.
;---------------------------------------------------------------------
draw_dot: 
           MOV   r4,r7         ; copy Y coordinate
           MOV   r5,r8         ; copy X coordinate

           AND   r5,0x7F       ; make sure top 1 bits cleared
           AND   r4,0x3F       ; make sure top 2 bits cleared
           LSR   r4             ; need to get the bottom bit of r4 into sA
           BRCS  dd_add80

dd_out:    OUT   r5,VGA_LADD   ; write bot 8 address bits to register
           OUT   r4,VGA_HADD   ; write top 5 address bits to register
           OUT   r6,VGA_COLOR  ; write color data to frame buffer
           RET           

dd_add80:  OR    r5,0x80       ; set bit if needed
           BRN   dd_out

read_dot: 
           MOV   r4,r7         ; copy Y coordinate
           MOV   r5,r8         ; copy X coordinate

           AND   r5,0x7F       ; make sure top 1 bits cleared
           AND   r4,0x3F       ; make sure top 2 bits cleared
           LSR   r4             ; need to get the bottom bit of r4 into sA
           BRCS  rd_add80

rd_outin:  OUT   r5,VGA_LADD   ; write bot 8 address bits to register
           OUT   r4,VGA_HADD   ; write top 5 address bits to register
           IN    r11,VGA_READ
           RET           

rd_add80:  OR    r5,0x80       ; set bit if needed
           BRN   rd_outin
; --------------------------------------------------------------------


;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r7,r9
;--------------------------------------------------------------------
draw_vertical_line:
         ADD    r9,0x01

draw_vert1:          
         CALL   draw_dot
         ADD    r7,0x01
         CMP    r7,R9
         BRNE   draw_vert1
         RET
;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  Parameters:
;-   r8  = starting x-coordinate
;-   r7  = y-coordinate
;-   r9  = ending x-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r8,r9
;--------------------------------------------------------------------
draw_horizontal_line:
        ADD    r9,0x01          ; go from r8 to r9 inclusive

draw_horiz1:
        CALL   draw_dot         ; 
        ADD    r8,0x01
        CMP    r8,r9
        BRNE   draw_horiz1
        RET


;--------------------------------------------------------------------
;  Subroutine: check_adjacent
; 
;  The following subroutines checks an unvisited cell for any adjacent
;  hallways. This ensures only 1x1 halls are created in the program.
;--------------------------------------------------------------------
CHECK_ADJACENT: 
   MOV R22, 0x00
       A_NORTH:
          SUB  R7, 0x01
          CALL read_dot
          CMP  R11, GEN_HALL
          BREQ ADJ_TRUE
          CMP  R11, BACKTRACK_HALL
          BREQ ADJ_TRUE
          ADD  R7, 0x01
       A_WEST :
          SUB  R8, 0x01
          CALL read_dot
          CMP  R11, GEN_HALL
          BREQ ADJ_TRUE
          CMP  R11, BACKTRACK_HALL
          BREQ ADJ_TRUE
          ADD  R8, 0x01
       A_EAST :
          ADD  R8, 0x01
          CALL read_dot
          CMP  R11, GEN_HALL
          BREQ ADJ_TRUE
          CMP  R11, BACKTRACK_HALL
          BREQ ADJ_TRUE
          SUB  R8, 0x01
       A_SOUTH:
          ADD  R7, 0x01
          CALL read_dot
          CMP  R11, GEN_HALL
          BREQ ADJ_TRUE
          CMP  R11, BACKTRACK_HALL
          BREQ ADJ_TRUE
          SUB  R7, 0x01
          BRN ADJ_FALSE
   ADJ_TRUE:
          MOV R22, 0x01
          RET
   ADJ_FALSE:
       RET

;----------------------------------------------------------------------------------------
;- Subrountine: read_dot
;- 
;- This subroutine reads a dot from the display of the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4,r5
;-----------------------------------------------------------------------------------------
read_dot_move: 
           MOV r4,r7         ; copy Y coordinate
           MOV r5,r8         ; copy X coordinate

           AND r5,0x7F       ; make sure top 1 bits cleared
           AND r4,0x3F       ; make sure top 2 bits cleared
           LSR r4             ; need to get the bottom bit of r4 into sA
           BRCS rdm_add80

rdm_inout: OUT r5,VGA_LADD   ; write bot 8 address bits to register
           OUT r4,VGA_HADD   ; write top 5 address bits to register
           IN r11,VGA_READ  ; write color data to frame buffer
           CALL CHECK_ORIGIN
           CMP R29, 0x01
           BREQ WINNER
           CMP r11, WALL_COLOR ; Compare to the color of white, to see if a player hits a wall
           BREQ WALL_FAIL
           RET           

rdm_add80:  OR r5,0x80       ; set bit if needed
           BRN rdm_inout


.ORG 0x3FF
BRN ISR
