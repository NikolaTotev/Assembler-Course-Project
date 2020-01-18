%Title "Course Project Exercise 1 - KEEP ASM FILE NAMES BELOW 8 SYMBOLS"
	IDEAL
	MODEL small
	STACK 256

	DATASEG
	
;=======================================
;	Encryption structure
;=======================================
STRUC EncryptorBox
originalValue db ?
encLevel1 	  db ?
encLevel2	  db ?
encLevel3	  db ?
balance  	  dw ?	
bal		 	  dw ?	
ENDS 
	
;=======================================
;	General program constants
;=======================================
c_MaxFileLen  					EQU 200
c_ExitCode 						db 0

;=======================================
;	File operation variables
;=======================================
fv_InFile 						dw 0 					
fv_OutFile 						dw 0 					
fv_InFileLen   					dw 0					
fv_WriteBuffer 					db 0		
fv_InputBuffer 					db ?

;=======================================
;	Encryption operation variables
;=======================================
ev_CurrentEncrLvl 				db 0					;Current encryption level variable.
ev_EncryptionState EncryptorBox 200 DUP (?,?,?,?)		;String storing the current encryption state.

;=======================================
;	Array operation variables
;=======================================
av_ArrayElementAddress 			dw 0
av_ArrayElementPositionIndex 	dw 0
av_InputCounter					dw 0
av_WriteCounter 				dw 0 

;=======================================
;	Available command constants
;=======================================
c_CmdEncrypt 					db '1'
c_CmdDecrypt 					db '2'
c_CmdExit						db '3'
c_CmdSave 						db 's'
inputResult 					db 0

;=======================================
;	File name fariables
;=======================================
nc_FileIn 						db 'inputF.txt',0		;Input file path. Keep file names below 8 symbols!
nc_FileOut 						db 'outputF.txt',0		;Output file path. Keep file names below 8 symbols!

;=======================================
;	Error messages
;=======================================
errMsg_FileTooBig 				db 'ERROR: Input file size exeeded maximum allowed.',13,10,'Please limit file size to 200 characters.',13,10,'Terminating program.$'
errMsg_EmptyFile 				db 'ERROR: Input file was empty.',13,10, 'Nothing to encrypt/decrypt.',13,10,'Terminating program. $'
errMsg_UndefinedCommand 		db 'ERROR: An invalid command was entered.', 13,10,'Valid commands are:', 13,10,'1: For entrypting once',13,10,'2: For decrypting once.',13,10,'3: For exiting the program$'
errMsg_MaxEncrLvlReached 		db 'ERROR: You have reached the maximum encryption level allowed!',13,10, 'Current available options are: ',13,10,'2: Decrypt by 1 level',13,10,'3: Exit program.',13,10,'s: Save current encryption state to file.' ,13,10, '$'
errMsg_MinEncLvlReached 		db 'ERROR: You have reached the minimum encryption level allowed!',13,10, 'Current available options are: ',13,10,'1: Encrypt by 1 level',13,10,'3: Exit program.',13,10,'s: Save current encryption state to file.' ,13,10, '$'
errMsg_FailedToReadFile 		db 'ERROR: Failed to read file.',13,10,'Terminating program.$'
errMsg_FileNotFound 			db 'ERROR: File not found.',13,10,'Terminating program.$'
errMsg_TooManyOpenFiles			db 'ERROR: Too many open files.' ,13,10, 'To continue please close some files and start the program again',13,10,'Terminating program.$'
errMsg_AccessDenied				db 'ERROR: Access to input file denied.',13,10,'Terminating program.$'
errMsg_FileReadError			db 'ERROR: An error occured while reading the input file.',13,10,'Please try with another file',13,10,'Terminating program.$'

;=======================================
;	Encryption info messages
;=======================================
encrMsg_EncLvl0 				db 'Encryption level 0: $'
encrMsg_EncLvl1 				db 'Encrytion level 1: $'
encrMsg_EncLvl2 				db 'Encryption level 2: $'
encrMsg_EncLvl3					db 'Encryption level 3: $'

;=======================================
;	Other utility messages
;=======================================
utilMsg_InputPrefix  			db 'Your command: $' ;Input console message
utilMsg_NewLine					db 13,10,'$'			
utilMsg_Exiting 				db 'Exiting program.$'
utilMsg_SavingInProgress  		db 'Saving...$'
utilMsg_SavingComplete   		db 'Saved!$'
utilMsg_UsageInstructions		db 'Welcome to Encriptify!',13,10,'Here are some instructions on how to use the program!',13,10,'Available commands are: ',13,10,'Press "1" to encrypt.',13,10,'Press "2" to decrypt.',13,10,'Press "s" to save the current encryption level.',13,10,'Press "3" to exit the program.',13,10, 'IMPORTANT: The input file may have a maximum length of 200 characters',13,10,'and may only contain ASCII symbols.' ,13,10,'$'																																
utilMsg_FileOpenedSuccessfully 	db 'Input file opened successfully!$'

;=======================================
;	Encryption constants
;=======================================
encrConst_LevelOneConstant 		db 'N'
encrConst_LevelTwoConstant 		db 'R'
encrConst_LevelThreeConstant 	db 'T'
								
	CODESEG
	
Start:

	mov 	ax, @data
	mov 	ds, ax	

;==================================================================
;
; Program setup 
;	- opening file.
;	- reading file contents into string variable.
;	- creating file.
;
;==================================================================

;-- Print instruction text
	mov 	ah, 09h
	mov 	dx, offset utilMsg_UsageInstructions
	int 	21h
	
;-- Print new line
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h

;-- Open file	
	mov 	dx, offset nc_FileIn 			;Address file name with dx.
	xor 	al,al 						;Specify read only access.
	mov 	ah,03Dh						;DOS open file instruction.
	int 	21h				;Open the input file.
	
;-- Check if file exists
	cmp ax, 2
	je FileNotFound	

	jmp FileOpenOk
	
;-- Error handling for opening file operation.	
FileNotFound:
	mov 	ah, 09h
	mov 	dx, offset errMsg_FileNotFound
	int 	21h
	jmp Exit	

FileOpenOk:

	mov 	[fv_InFile], ax 				;Save the input file handle.
			
;-- Print file open message
	mov 	ah, 09h
	mov 	dx, offset utilMsg_FileOpenedSuccessfully
	int 	21h
	
;-- Print new line
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h

;-- Print new line
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h

;-- Get input file length
	mov		bx, [fv_InFile]				;Set bx to the input file handle.
	mov		ax, 4202h					;command for setting the DOS internal "file pointer" to the end of opened file: ah = 42h, al = 2 
	xor 	cx,cx						;cx = 0
	xor 	dx,dx						
	int 	21h							;Sets the file pointer to the end of the file. Returns dx:ax
	mov 	[fv_InFileLen], ax				;The value we want is in ax becuse it is a small number.
	cmp 	[fv_InFileLen], c_MaxFileLen
	jbe 	BelowMax
	jmp 	LengthOutOfRange
BelowMax:
	cmp 	[fv_InFileLen], 0
	ja		LengthInRange
	je  	CallZeroLengthFile
		
CallZeroLengthFile:
	jmp 	EmptyFileWarning
	
LengthInRange:
	
;-- Return file pointer to start of file
	mov 	bx, [fv_InFile]				;Set bx to the input file handle.
	mov 	ax, 4200h					;Command for setting the DOS file pointer to the start of an opne file: ah = 42h, al = 0
	int 	21h							;Sets the file pointer to the start of the tile. 
	
;-- Create file for saving data.	
	;Add check for errors.
	;Jump to code that handles errors.	
	
	mov 	[fv_OutFile],ax 				;Save out file handle for later use.


;-- Reading file into string.
ReadNext:
	mov 	ah, 03Fh 					;DOS Read-file instruction.
	mov 	bx, [fv_InFile]				;Set bx to input file handle.
	mov 	cx, 1				;Specify one byte to read.
	mov 	dx, offset fv_InputBuffer		;Address the variable with ds:dx. (this is the buffer that the value is written to)
	int 	21h							;Call DOS to read from file.
	
	jnc FileReadOk
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_InputPrefix
	int 	21h
	jmp Exit

FileReadOk:
	or 		ax,ax
	jz 		ContinueOperation
	mov 	dl,[fv_InputBuffer]
	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [fv_InputBuffer]
	mov 	[bx+ev_EncryptionState.originalValue],dl
	inc 	[av_ArrayElementPositionIndex]
	call 	CalcNextIndex
		
	jmp 	ReadNext
	
;==================================================================
; Setup End
;==================================================================
ContinueOperation:
	call 	ReadInput
	jmp 	ContinueOperation

;==================================================================
; Input handling. 
; Reads one symbol from keyboard and checks what command it is.
; If the keypress is an invalid command,
; the appropriate error is called.
;==================================================================
PROC ReadInput
;-- Write input prefix.
	mov 	ah, 09h
	mov 	dx, offset utilMsg_InputPrefix
	int 	21h
	
;-- Get input.
	xor 	ax,ax
	mov	 	ah, 1
	int 	21h
	
;--	Set cursor to beginning of next line.
	mov		ah,09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	
;-- Compare commands
	cmp 	al, [c_CmdEncrypt]
	je 		EqualToOne
	
	cmp 	al, [c_CmdDecrypt]
	je 		EqualToTwo
	
	cmp 	al, [c_CmdExit]	
	je 		EqualToThree
	
	cmp 	al, [c_CmdSave]
	je 		CallSave
	
	call 	UndefinedFunction
	
EqualToOne:
	call	 Encrypt
	ret	
	
EqualToTwo:
	call 	Decrypt
	ret
	
EqualToThree:	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_Exiting
	int 	21h
	jmp 	Exit
	ret
	
CallSave:
	call 	Save
	ret
	
ENDP ReadInput
;==================================================================
;	Encryption routines
;==================================================================

;----------------------------------------
; 	Encryption routine. 
;	Handles encrypting to proper level
;----------------------------------------
PROC Encrypt
	cmp 	[ev_CurrentEncrLvl], 3
	jb 		@@InEncrRange
	call 	MaxEncrLvlReached
	ret 
	
@@InEncrRange:
	cmp 	[ev_CurrentEncrLvl], 0
	je 		@@CallEnc1
	
	cmp 	[ev_CurrentEncrLvl], 1
	je 		@@CallEnc2
	
	cmp		[ev_CurrentEncrLvl], 2
	je 		@@CallEnc3
	
@@CallEnc1:
	call 	LevelOneEncryption
	inc 	[ev_CurrentEncrLvl]
	call 	PrintCurrentState
	ret
	
@@CallEnc2:
	call 	LevelTwoEncryption
	inc 	[ev_CurrentEncrLvl]
	call 	PrintCurrentState
	ret

@@CallEnc3:
	call 	LevelThreeEncryption
	inc 	[ev_CurrentEncrLvl]
	call	PrintCurrentState
	ret
	
ENDP Encrypt
	
;----------------------------------------
; 	Decryption routine. 
;	Handles decrypting to proper level
;----------------------------------------
PROC Decrypt
	cmp 	[ev_CurrentEncrLvl], 0
	ja 		@@InEncrRange
	call 	MinEncLvlReached
	ret 
	
@@InEncrRange:
	cmp 	[ev_CurrentEncrLvl], 1
	je 		@@CallDec0
	
	cmp 	[ev_CurrentEncrLvl], 2
	je 		@@CallDec1
	
	cmp 	[ev_CurrentEncrLvl], 3
	je 		@@CallDec2
	
@@CallDec0:
	dec 	[ev_CurrentEncrLvl]
	call 	PrintCurrentState
	ret
		
@@CallDec1:
	dec 	[ev_CurrentEncrLvl]
	call 	PrintCurrentState
	ret
	
@@CallDec2:
	dec 	[ev_CurrentEncrLvl]
	call 	PrintCurrentState
	ret

ENDP Decrypt

;===============================
;	Encryption level routines
;===============================

;-------------
;	Level 1
;-------------
PROC LevelOneEncryption
	push	bx
	mov 	[av_ArrayElementPositionIndex], 0
	call	CalcNextIndex
	mov 	cx, [fv_InFileLen]
	mov 	[av_InputCounter], cx

@@InputAgain:

	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.originalValue]		
	sub 	dl, [encrConst_LevelOneConstant]
	add 	dl, 30h
	mov 	[bx+ev_EncryptionState.encLevel1],dl	
	inc 	[av_ArrayElementPositionIndex]
	call	CalcNextIndex
	dec 	[av_InputCounter]
	cmp 	[av_InputCounter], 0
	jne 	@@InputAgain	
	pop 	bx
	ret
	
ENDP LevelOneEncryption

;-------------
;	Level 2
;-------------
PROC LevelTwoEncryption
	push 	bx
	
	mov 	[av_ArrayElementPositionIndex], 0
	
	
	call 	CalcNextIndex
	
	mov 	cx, [fv_InFileLen]
	mov 	[av_InputCounter], cx

@@InputAgain:

	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.encLevel1]
	
	sub 	dl, [encrConst_LevelTwoConstant]
	add 	dl, 6
 	shr 	dl, 1
	add 	dl, 30h
	
	mov 	[bx+ev_EncryptionState.encLevel2],dl
	
	inc 	[av_ArrayElementPositionIndex]
	call 	CalcNextIndex
	dec 	[av_InputCounter]
	cmp 	[av_InputCounter], 0
	jne 	@@InputAgain	
	
	pop 	bx
	ret
ENDP LevelTwoEncryption

;-------------
;	Level 3
;-------------
PROC LevelThreeEncryption
	push 	bx
	
	mov 	[av_ArrayElementPositionIndex], 0
	
	call 	CalcNextIndex
	
	mov 	cx, [fv_InFileLen]
	mov 	[av_InputCounter], cx

@@InputAgain:

	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.encLevel2]
	
	sub 	dl, [encrConst_LevelThreeConstant]
	add 	dl, 3
 	shr 	dl, 1
	add 	dl, 30h
	
	mov 	[bx+ev_EncryptionState.encLevel3],dl	
	
	inc 	[av_ArrayElementPositionIndex]
	call	 CalcNextIndex
	dec 	[av_InputCounter]
	cmp 	[av_InputCounter], 0
	jne 	@@InputAgain	
	
	pop 	bx
	ret
ENDP LevelThreeEncryption

;==================================================================
;	Index calculation
;==================================================================
PROC CalcNextIndex
	push 	bx
	mov 	bx, [av_ArrayElementPositionIndex]
	shl 	bx, 3
	mov 	[av_ArrayElementAddress], bx
	pop 	bx
	ret
ENDP CalcNextIndex

;==================================================================
;	Prints current encryption state to screen.
;==================================================================
PROC PrintCurrentState
	push 	bx
	push 	dx
	mov 	[av_ArrayElementPositionIndex], 0
	xor 	dx,dx
	call 	CalcNextIndex
	mov 	cx, [fv_InFileLen]
	mov 	[av_InputCounter], cx
	
	cmp 	[ev_CurrentEncrLvl], 0
	je 		@@PrintMsg0

	cmp 	[ev_CurrentEncrLvl], 1
	je		@@PrintMsg1
	
	cmp 	[ev_CurrentEncrLvl], 2
	je		@@PrintMsg2
	
	cmp 	[ev_CurrentEncrLvl], 3
	je		@@PrintMsg3
	
@@PrintMsg0:
	mov 	ah, 09h
	mov 	dx, offset encrMsg_EncLvl0
	int 	21h
	jmp 	@@InputAgain
	
@@PrintMsg1:
	mov 	ah, 09h
	mov	 	dx, offset encrMsg_EncLvl1
	int 	21h
	jmp 	@@InputAgain

@@PrintMsg2:
	mov 	ah, 09h
	mov 	dx, offset encrMsg_EncLvl2
	int 	21h
	jmp 	@@InputAgain

@@PrintMsg3:
	mov 	ah, 09h
	mov 	dx, offset encrMsg_EncLvl3
	int 	21h
	jmp 	@@InputAgain

@@InputAgain:
	mov 	bx, [av_ArrayElementAddress]
	
	cmp 	[ev_CurrentEncrLvl], 0
	je 		@@Lvl0

	cmp 	[ev_CurrentEncrLvl], 1
	je		@@Lvl1
	
	cmp 	[ev_CurrentEncrLvl], 2
	je		@@Lvl2
	
	cmp 	[ev_CurrentEncrLvl], 3
	je		@@Lvl3

@@Lvl0:
	mov 	dl, [bx+ev_EncryptionState.originalValue]
	jmp 	@@Continue
	
@@Lvl1:	
	mov 	dl, [bx+ev_EncryptionState.encLevel1]
	jmp 	@@Continue
	
@@Lvl2:
	mov 	dl, [bx+ev_EncryptionState.encLevel2]
	jmp 	@@Continue
	
@@Lvl3:
	mov 	dl, [bx+ev_EncryptionState.encLevel3]
	jmp 	@@Continue

@@Continue:
	mov 	ah, 2				;DOS Write-file instruction.
	mov 	cx, 1
	int 	21h	
	
	inc 	[av_ArrayElementPositionIndex]
	call 	CalcNextIndex
	dec 	[av_InputCounter]
	cmp 	[av_InputCounter], 0
	jne 	@@InputAgain	
	
	mov 	ah,09h
	mov 	dx, offset utilMsg_NewLine
	int		21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	
	pop 	dx
	pop 	bx

	ret
ENDP PrintCurrentState


PROC Save
	
	push	 bx
	push 	 dx
	push	 ax
	
	;-- Create file for saving data.

	mov 	dx, offset nc_FileOut			;Addres file out name with dx.
	xor 	cx,cx						;Specify normal attributes.
	mov 	ah,03Ch						;DOS Create-file instruction.
	int 	21h							;Create the output file.
	
	;Add check for errors.
	;Jump to code that handles errors.	
	
	mov 	[fv_OutFile],ax 				;Save out file handle for later use.
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_SavingInProgress
	int 	21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
		
	mov 	[av_ArrayElementPositionIndex], 0
	xor 	dx,dx
	call 	CalcNextIndex
	mov 	cx, [fv_InFileLen]
	mov [	av_InputCounter], cx

@@InputAgain:
	
	cmp 	[ev_CurrentEncrLvl], 0
	je 		@@Lvl0Save

	cmp 	[ev_CurrentEncrLvl], 1
	je		@@Lvl1Save
	
	cmp 	[ev_CurrentEncrLvl], 2
	je		@@Lvl2Save
	
	cmp 	[ev_CurrentEncrLvl], 3
	je		@@Lvl3Save

@@Lvl0Save:
	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.originalValue]
	mov 	[fv_WriteBuffer], dl
	mov 	dx, offset fv_WriteBuffer
	jmp 	@@ContinueWrite
	
@@Lvl1Save:
	mov		bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.encLevel1]
	mov 	[fv_WriteBuffer], dl
	mov 	dx, offset fv_WriteBuffer
	jmp 	@@ContinueWrite
	
@@Lvl2Save:

	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.encLevel2]
	mov 	[fv_WriteBuffer], dl
	mov 	dx, offset fv_WriteBuffer
	jmp 	@@ContinueWrite
	
@@Lvl3Save:

	mov 	bx, [av_ArrayElementAddress]
	mov 	dl, [bx+ev_EncryptionState.encLevel3]
	mov 	[fv_WriteBuffer], dl
	mov 	dx, offset fv_WriteBuffer
	jmp 	@@ContinueWrite

@@ContinueWrite:
	mov 	ah, 40h				;DOS Write-file instruction.
	mov	 	cx, 1
	mov	 	bx, [fv_OutFile]		;Set bx to output file handle.				
	int	 	21h
	
	inc 	[av_ArrayElementPositionIndex]
	call 	CalcNextIndex
	dec 	[av_InputCounter]
	cmp 	[av_InputCounter], 0
	je 		@@WritingFinished
	jmp 	@@InputAgain
	
@@WritingFinished:
	mov 	ah, 09h
	mov 	dx, offset utilMsg_SavingComplete
	int 	21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	
	;-- Close output file	
	mov	 	bx,[fv_OutFile]				;Get the output file handle.
	mov 	ah, 3Eh						;Does Close-file function.
	int 	21h							;Close output file.
	
	pop 	ax
	pop 	dx
	pop 	bx
	ret
ENDP Save

;==================================================================
;	Error handling routines
;==================================================================
PROC UndefinedFunction
	mov 	ah, 09h
	mov 	dx, offset errMsg_UndefinedCommand
	int		21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	
	jmp 	ContinueOperation
	ret
ENDP
;------------------------------------------------
;	Error routine - maximum encryption reached
;------------------------------------------------
PROC MaxEncrLvlReached
	mov 	ah, 09h
	mov 	dx, offset errMsg_MaxEncrLvlReached
	int 	21h
	
	mov 	ah, 09h
	mov 	dx, offset utilMsg_NewLine
	int 	21h
	jmp 	ContinueOperation
	ret
ENDP MaxEncrLvlReached

;------------------------------------------------
;	Error routine - minimum encryption reached
;------------------------------------------------
PROC MinEncLvlReached
	mov 	ah, 09h
	mov 	dx, offset errMsg_MinEncLvlReached
	int 	21h
	jmp 	ContinueOperation
	ret
ENDP MinEncLvlReached


EmptyFileWarning:
	mov 	ah, 09h
	mov 	dx, offset errMsg_EmptyFile
	int 	21h
	jmp 	Exit

LengthOutOfRange:
	mov 	ah, 09h
	mov 	dx, offset errMsg_FileTooBig
	int 	21h
	jmp 	Exit
	
;-- Close the input and output files, which is not strictly required as ending the program 
;	via function 04Ch also closes all open files. 
;	Note errors	are handled only when closing the output file because no changes are made to the input.

Exit:
;-- Close input file
	mov 	bx, [fv_InFile] 				;Get the input file handle.
	mov 	ah, 03Eh					;DOS Close-file function.
	int		21h							;Close input file.

;-- Close output file	
	mov 	bx,[fv_OutFile]				;Get the output file handle.
	mov 	ah, 3Eh						;Does Close-file function.
	int 	21h							;Close output file.
	
	;Add check for errors.
	;Jump to code that handles errors.

	mov 	ah, 04Ch					;DOS function: Exit program.
	mov 	al,[c_ExitCode] 				;Return exit code value.
	int 	21h							;Call DOS. Terminate program.
	
END Start							;End of program / entry point.
	
	
	
	
	
	
	

















	
	
	
	
	
	
	
	
	
	
	