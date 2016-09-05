	.386p
data segment para public 'data' use16
	min_x 		dq 	-6.0         ; мінімальне значення по осі х
	max_x 		dq 	6.0          ; максимальне значення по осі х
	max_crt_x 	dw 	320    	     ; максимальна кількість точок                                   
                                             ; на екрані по осі х
	crt_x 		dw 	?
	scale_x 	dq 	?
	min_y 		dq 	-6.0
	max_y 		dq 	6.0
	max_crt_y 	dw 	200 
	crt_y 		dw 	?
	scale_y 	dq 	?
	buff 		dq 	?
	control_reg	dw	?
	data ends 
	code segment para public 'code' use16
    assume ds: data, cs: code
; обчислення масштабного коефіцієнта по осі p1:
	scale macro p1 
	fld 	max_&p1
	fsub 	min_&p1
	fild 	max_crt_&p1
	fdivp 	st(1),st(0)
	fstp 	scale_&p1
	endm
	begin:
	finit
	fldz
	fld1
	fsub
	fsqrt
	mov ax,10000101b
	mov control_reg,ax
	fldcw control_reg    
	mov ax,data
	mov ds,ax	
	scale x
	scale y	
;режим 320*200 точок із числом кольорів кожної точки рівним 256:
	mov ax,13h 	
	int 10h	
	mov ax,0a000h
	mov es,ax
@x:
    mov cx,320
    mov di,32000 
    mov al,2
    rep stosb
@y:
    mov di,160 
    mov cx,200
    mov al,2
@vertical:
  	add di,319
    stosb
    loop @vertical	
	mov crt_x,0
	mov cx,320
@start:
; перетворення екранної координати в дійсну:
	fld 		scale_x		
	fild 		crt_x		
	fmulp 		st (1), st (0)		
	fadd 		min_x	
;Обчислення значення функції
	fld st	;st(0) = x	
	fmul st,st(1)	
	fsin		
;Перерахунок дійсного значення функції в екранну координату у.
	fcom min_y
	fstsw ax
	sahf
	jc @minus	
	fcom max_y
	fstsw ax
	sahf
	ja @plus	
	fsub min_y
	fdiv scale_y
	frndint
	fistp crt_y
	mov ax,max_crt_y
	sub ax,crt_y
	mov crt_y,ax	
	jmp @graphic
;@minus & @plus:
@minus:
	mov ax,max_crt_y
    mov crt_y,ax
    fstp buff
	jmp @graphic
@plus:
	mov crt_y,0
    fstp buff
	jmp @graphic
@graphic:
	mov si,crt_y
    mov ax,320
    mul si
    add ax,crt_x
    mov di,ax
    mov al,4
    dec di
    stosb
    inc crt_x
	sub cx,1
	cmp cx,0
	jne  @start
	
	;mov ah,1h 
    ;int 21h	
    
    

@x1:
    mov cx,320
    mov di,32000 
    mov al,2
    rep stosb
@y1:
    mov di,160 
    mov cx,200
    mov al,2
@vertical1:
  	add di,319
    stosb
    loop @vertical1	
	mov crt_x,0
	mov cx,320
    
    @start1:
; перетворення екранної координати в дійсну:
	fld 		scale_x		
	fild 		crt_x		
	fmulp 		st (1), st (0)		
	fadd 		min_x	
;Обчислення значення функції
	fld st	;st(0) = x	
	fmul st,st(1)
	fmul st,st(1)		
	fsin		
;Перерахунок дійсного значення функції в екранну координату у.
	fcom min_y
	fstsw ax
	sahf
	jc @minus1	
	fcom max_y
	fstsw ax
	sahf
	ja @plus1	
	fsub min_y
	fdiv scale_y
	frndint
	fistp crt_y
	mov ax,max_crt_y
	sub ax,crt_y
	mov crt_y,ax	
	jmp @graphic1
;@minus & @plus:
@minus1:
	mov ax,max_crt_y
    mov crt_y,ax
    fstp buff
	jmp @graphic1
@plus1:
	mov crt_y,0
    fstp buff
	jmp @graphic
@graphic1:
	mov si,crt_y
    mov ax,320
    mul si
    add ax,crt_x
    mov di,ax
    mov al,3
    dec di
    stosb
    inc crt_x
	sub cx,1
	cmp cx,0
	jne  @start1
	
	mov ah,1h 
    int 21h	

@exit:
    mov ax,3 
    int 10h
    mov ax,4c00h
    int 21h
code ends
end begin
