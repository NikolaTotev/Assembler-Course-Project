masm
model small
.data
handle	dw	0 
filename	db	'sum.txt',0
len_string=$-filename
numberOne db ?
numberTwo db ?
sum db 0,0 
point_fname	dd	filename
.stack	256
.code
main:
	mov	ax,@data 
	mov	ds,ax 
	
	mov ah,01
	int 21h
	mov numberOne, al
	
	mov ah,01
	int 21h
	mov numberTwo, al

	xor	bx,bx
	
	mov bx,1
	mov	al,numberOne
	adc	al,numberTwo
	aaa
	mov	sum[bx],al

	dec	bx
	
	adc	sum[bx],0
	
	mov bx,1
	mov dl, sum[bx]
	add dl,30h
	mov sum[bx],dl

	dec bx
	mov dl, sum[bx]
	add dl,30h
	mov sum[bx],dl
	
	xor	cx,cx ;put cx to zero, that way we say we want to create a standard file.
	lds	dx,point_fname ;loads the pointer to the ds register/point_fname is effective address to filename.
	mov	ah,3ch ; 
	int	21h	
	jc	exit
	mov	handle,ax

	mov	al,01h 
	lds	dx,point_fname
	mov	ah,3dh 
	int	21h
	jc	exit 
	mov	handle,ax
		
	mov bx,handle
	mov cx,2 
	lea	dx,sum
	mov ah,40h
	int 21h
	jc	exit 
	nop

exit: 
	mov	ax,4c00h 
	int	21h
end	main
