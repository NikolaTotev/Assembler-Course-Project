.model small
.stack 100h
.data   
  XCords1 dw 160        ;COORDS OF PIXEL AT
  YCords1 dw 100        ;SCREEN CENTER.
  score   dw 0
  x       dw ?          ;MOUSE CLICK X.
  y       dw ?          ;MOUSE CLICK Y.
  msj     db 'score!$'
  hyphen  db '-$'
  clear   db '       $' ;CLEAR LINE.
  numstr  db '$$$$$'    ;STRING FOR 4 DIGITS.
.code
mov  ax, @data
mov  ds, ax

;DotGame:
;enter graphics mode
mov  ax, 13h
int  10h
call SetCursor ; mouse input
call DotOne

DotGame:
mov  bx, 1          ;CHECK RIGHT BUTTON (USE 0 TO CHECK LEFT BUTTON).
call GetMouseState
and  bx, 00000010b  ;CHECK SECOND BIT (BIT 1).
jz   DotGame        ;NO RIGHT CLICK. REPEAT.

mov  x, cx          ;PRESERVE X AND Y BECAUSE
mov  y, dx          ;CX DX WILL BE DESTROYED.                  
call display_coords

;cmp  bx, 01 ; check if left mouse was clicked
;je   Check_X_Cords
 ;check if the player clicked the dot cords

Check_X_Cords:
mov  cx, x
cmp  cx, XCords1
je   Check_Y_Cords

jmp  DotGame       ;WRONG COLUMN. REPEAT.

Check_Y_Cords:
mov  dx, y
cmp  dx, YCords1
je   ScoreLabel

jmp  DotGame       ;WRONG ROW. REPEAT.

ScoreLabel:
inc  [score]               
;DISPLAY "SCORE!".
  mov  ah, 9
  mov  dx, offset msj
  int  21h
jmp  DotGame       ;REPEAT.

mov  ax, 4c00h
int   21h

;---------------------------------------              

   proc SetCursor

;initialize the mouse

 mov ax, 0h

 int 33h

 ;show mouse

 mov ax, 1h

 int 33h

; get mouse place and status

;mov ax, 3h

;int 33h

ret

   endp SetCursor

;---------------------------------------              
;DRAW ONE PIXEL AT XCORDS1,YCORDS1.
proc DotOne
  mov  ah, 0ch       ;SERVICE TO DRAW PIXEL.
  mov  al, 14        ;YELLOW.
  mov  bh, 0         ;VIDEO PAGE.
  mov  cx, XCords1
  mov  dx, YCords1
  int  10h           ;BIOS SCREEN SERVICES.
  ret
endp DotOne
;---------------------------------------              
;GET MOUSE CURSOR STATE.   
;RETURN : BX : BIT 0 = 0 : LEFT BUTTON PRESSED.
;                    = 1 : LEFT BUTTON RELEASED.
;            : BIT 1 = 0 : RIGHT BUTTON PRESSED.
;                    = 1 : RIGHT BUTTON RELEASED.
;         CX = SCREEN COLUMN.
;         DX = SCREEN ROW.

proc GetMouseState
  mov  ax, 3       ;SERVICE TO GET MOUSE STATE.
  int  33h
  ret
endp GetMouseState

;------------------------------------------
;CONVERT A NUMBER IN STRING.
;ALGORITHM : EXTRACT DIGITS ONE BY ONE, STORE
;THEM IN STACK, THEN EXTRACT THEM IN REVERSE
;ORDER TO CONSTRUCT STRING (STR).
;PARAMETERS : AX = NUMBER TO CONVERT.
;             SI = POINTING WHERE TO STORE STRING.
;DESTROYED : AX, BX, CX, DX, SI.

number2string proc 
  call dollars ;FILL STRING WITH $.
  mov  bx, 10  ;DIGITS ARE EXTRACTED DIVIDING BY 10.
  mov  cx, 0   ;COUNTER FOR EXTRACTED DIGITS.
cycle1:       
  mov  dx, 0   ;NECESSARY TO DIVIDE BY BX.
  div  bx      ;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
  push dx      ;PRESERVE DIGIT EXTRACTED FOR LATER.
  inc  cx      ;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
  cmp  ax, 0   ;IF NUMBER IS
  jne  cycle1  ;NOT ZERO, LOOP. 
;NOW RETRIEVE PUSHED DIGITS.
cycle2:  
  pop  dx        
  add  dl, 48  ;CONVERT DIGIT TO CHARACTER.
  mov  [ si ], dl
  inc  si
  loop cycle2  

  ret
number2string endp       

;------------------------------------------
;FILLS VARIABLE "NUMSTR" WITH '$'.
;USED BEFORE CONVERT NUMBERS TO STRING, BECAUSE
;THE STRING WILL BE DISPLAYED.
;PARAMETER : SI = POINTING TO STRING TO FILL.
;DESTROYED : BL, CX, DI.

proc dollars                 
  mov  cx, 5
  mov  di, offset numstr
dollars_loop:      
  mov  bl, '$'
  mov  [ di ], bl
  inc  di
  loop dollars_loop

  ret
endp               

;------------------------------------------

proc display_coords
;SEND CURSOR TO START OF UPPER LEFT.
  mov  ah, 2   ;SERVICE TO SET CURSOR POSITION.
  mov  bh, 0   ;VIDE PAGE.
  mov  dl, 0   ;X.
  mov  dh, 0   ;Y.
  int  10h
;CLEAR LINE.
  mov  ah, 9
  mov  dx, offset clear
  int  21h
;SEND CURSOR TO START OF UPPER LEFT.
  mov  ah, 2   ;SERVICE TO SET CURSOR POSITION.
  mov  bh, 0   ;VIDE PAGE.
  mov  dl, 0   ;X.
  mov  dh, 0   ;Y.
  int  10h
;CONVERT X TO STRING.
  mov  ax, x ;AX = PARAMETER FOR NUMBER2STRING.                                              
  mov  si, offset numstr
  call number2string                                              
;DISPLAY X.
  mov  ah, 9
  mov  dx, offset numstr
  int  21h
;"-".
  mov  ah, 9
  mov  dx, offset hyphen
  int  21h 
;CONVERT Y TO STRING.
  mov  ax, y ;AX = PARAMETER FOR NUMBER2STRING.                                              
  mov  si, offset numstr
  call number2string                                              
;DISPLAY Y.  
  mov  ah, 9
  mov  dx, offset numstr
  int  21h         
  ret
endp display_coords