masm
model small
.data

.code
main:
	mov AX, @data
	mov DS, AX

	mov ah, 01
	int 21h
	push ax
	int 21h
	push ax
	int 21h
	push ax

	;push DS:num1 ;Gets the value of num1 and pushes into the stack.
	;lea SI,s2 ;put the value of s2 in SI
  ;push SI
	;lea DX,s1
	;mov ah,9h
	;int 21h

  mov ah,2h
	pop DX
	int 21h ;When this is  called it calls what is in the AH register.
	pop DX
	int 21h
	pop DX
	int 21h

	;xchg DH, DL ;Exchange value from DHigh DLow. Value in DL is read first
;	mov AH, 2h
	;int 21h
	;xchg DH, DL ;Same as on line 23.
	;int 21h

	mov AX, 4c00h
	int 21h
end main
