masm
model small
.data
handle	dw	0 
filename	db	'my_file.txt',0
point_fname	dd	filename ;dd becase it holds full address, because a pointer can point to a diff segment.
.stack	256
.code
main:
	mov	ax,@data 
	mov	ds,ax
	xor	cx,cx ;put cx to zero, that way we say we want to create a standard file.
	lds	dx,point_fname ;loads the pointer to the ds register/point_fname is effective address to filename.
	mov	ah,3ch ; 
	int	21h	
	jc	exit
	mov	handle,ax 
exit:
	mov	ax,4c00h 
	int	21h
end	main
