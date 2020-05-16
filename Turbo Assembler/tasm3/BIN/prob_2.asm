masm
model small
.data
normalMas db ?,?,?,?,?,?
reverseMas db ?,?,?,?,?,?
.code
main:
	mov AX, @data
	mov DS, AX

	mov cx,6
	mov ah, 01
	xor si, si
input:
	int 21h
	mov normalMas[si], al
	push ax
	inc si
loop input
	
	mov cx,6



	mov cx,6
	xor si, si

compareLoop:
	pop dx
	cmp normalMas[si], dl
	jne ifFalse 
	inc si

loop compareLoop	
	je isTrue
	

isTrue:
	mov dl, 'T'
	jmp exit
	
ifFalse:
	mov dl, 'F'
	jmp exit
		

exit:
	mov ah, 2h
	int 21h	
	mov AX, 4c00h
	int 21h
end main
