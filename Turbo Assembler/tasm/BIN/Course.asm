%Title "Course Project Exercise 1"
	IDEAL
	MODEL small
	STACK 256

	DATASEG

exCode 		db 0
inFile 		dw 0 				;Input file handle.
outFile 	dw 0 				;Output file handle.
oneByte 	db 0 				;Byte I/O variable.

fileIn 		db 'IN.txt',0		;Input file path.
fileOut 	db 'outputFile.txt',0	;Output file path.

	CODESEG
	
Start:

	mov ax, @data
	mov ds, ax
	
;-- Attempt to open file.

	mov dx, offset fileIn 	;Address file name with dx.
	xor al,al 				;Specify read only access.
	mov ah,03Dh				;DOS open file instruction.
	int 21h					;Open the input file.
	
	;Add check for errors.
	;Jump to code that handles errors.
	
	mov [inFile], ax 		;Save the input file handle.
	
;-- Attempt to create file.

	mov dx, offset fileOut	;Addres file out name with dx.
	xor cx,cx				;Specify normal attributes.
	mov ah,03Ch				;DOS Create-file instruction.
	int 21h					;Create the output file.
	
	;Add check for errors.
	;Jump to code that handles errors.	
	
	mov [outFile],ax 
	
;-- At this point the input and output filesa are open and their 
;	handles are stored at inFile & outFile. 
;	The next step is to read from the input and write each byte 
;	into the output

@@readByte:
	mov ah, 03Fh 			;DOS Read-file instruction.
	mov bx, [inFile]		;Set bx to input file handle.
	mov cx, 1				;Specify one byte to read.
	mov dx, offset oneByte  ;Address the variable with ds:dx. (this is the buffer that the value is written to)
	int 21h					;Call DOS to read from file.
	
	;Add check for errors.
	;Jump to code that handles errors.
	
	or ax,ax				;Check for end of input file.
	jz @@endOfFileReached	;ax = 0 = end; Jump.
	mov ah, 40h				;DOS Write-file instruction.
	mov bx, [outFile]		;Set bx to output file handle.
	mov cx, 1				;Specify one byte to write.
	mov dx, offset oneByte	;Address the variable with ds:dx. (this is the buffer that the value is read from)
	int 21h					;Call DOS write to file.

	;Add check for errors.
	;Jump to code that handles errors.

	or ax,ax				;Check for disk full condition.
	jnz @@readByte			;Repeat for next byte.
	
;-- Close the input and output files, which is not strictly required as ending the program 
;	via function 04Ch also closes all open files. 
;	Note errors	are handled only when closing the output file because no changes are made to the input.

@@endOfFileReached:

;-- Close input file
	mov bx, [inFile] 		;Get the input file handle.
	mov ah, 03Eh			;DOS Close-file function.
	int 21h					;Close input file.

;-- Close output file	
	mov bx,[outFile]		;Get the output file handle.
	mov ah, 3Eh				;Does Close-file function.
	int 21h					;Close output file.
	
	;Add check for errors.
	;Jump to code that handles errors.

	mov ah, 04Ch			;DOS function: Exit program.
	mov al,[exCode] 		;Return exit code value.
	int 21h					;Call DOS. Terminate program.
	
END Start					;End of program / entry point.
	
	
	
	
	
	
	

















;	
	
	
	
	
	
	
	
	
	
	
	