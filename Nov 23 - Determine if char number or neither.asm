masm
model small
.data
input db '0'
.code
main:
	mov ax, @data
	mov ds, ax

	mov ah, 01
	int 21h
	
	mov input, al
	cmp input, '0'
	
	jg canBeLetterOrNumber
	jl neither
	
canBeLetterOrNumber:
	cmp input,'9'
	jle isNumber
	
	cmp input, 'A'
	jl neither
	
	cmp input, 'Z'
	jle isLetter
	
	cmp input, 'a'
	jl neither
	
	cmp input, 'z'
	jle isLetter
	jg neither
	
isLetter:
	mov dl, 1
	add dl,30h
	jmp exit
	
isNumber:
	mov dl, 2
	add dl,30h
	jmp exit

neither:
	mov dl, 3
	add dl,30h
	jmp exit
	
exit:
    mov ah, 2h
	int 21h	
	mov ax, 4c00h
	int 21h
end main
