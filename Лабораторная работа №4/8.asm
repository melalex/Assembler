.386
data segment use16
    scale_x	dq ?	 ; масштаб по осі х
	scale_y dq ?
    min_x dq -10.0	 ; мінімальне значення по осі х
    max_x dq 10.0	 ; максимальне значення по осі х
    max_crt_x dw 160 ; максимальна кількість точок по осі х
    crt_x dw ?	     ; екранна координата по осі х
    min_y dq -10.0
    max_y dq 10.0
	ten dq 10
	rl_x dq ?
	rl_y dq ?
    max_crt_y dw 100
    crt_y dw ?
	curcolor db 0
	sc_modx dw 80 ; (320 - max_crt_x)/2
	sc_mody dw 50 ; (200 - max_crt_y)/2
   offset_y dw 20
data ends

code segment use16
assume cs:code,ds:data
scale 		macro 	p1
; (max_x - min_x) / max_crt_x
fld max_&p1		; st0=max_&p1; top=7
fsub min_&p1		; st0=max_&p1 - min_&p1;
fild max_crt_&p1	; st0=max_crt_&p1
fdivp st (1), st (0)		; 1-й крок st1=st1/st0
fstp 		scale_&p1          
endm

xtoreal macro
fld 		scale_x		; st0 - масштаб
fild 		crt_x			; st0=crt_x, st1-масштаб
 ;top=6
fmulp 	st (1), st (0)		; top=7
fadd 		min_x		; st0 - реальне зн. Х; top=7
fstp rl_x
endm

ytocrt macro
fld rl_y
fcom 		min_y;  порівняння ST (0) та min_y
fstsw 		ax; результат порівняння в ax
sahf 				; результат порівняння 
;ST (0) та min_y в регістр Flags
jc 		@minus		; st0 < min_y
; поза видимим діапазоном
; по @minus забезпечити top=0 і
; crt_y=max_crt_y

fcom 		max_y		; порівняння ST (0) та max_y
fstsw		ax
sahf
ja 		@plus		; st0 > max_y (zf=cf=0)
; поза видимим діапазоном
; по @plus - забезпечити top=0
; і встановити crt_y=0
;-----------------------------------------------------------------
	nop
	;mov ax, rl_y
	;add ax, offset_y
	;mov rl_y, ax
	;sub ax, 1
	;mov offset_y, ax
;fsub		rl_x
;==================================================================
fsub		min_y;
fdiv 		scale_y
frndint				; округлення до цілого
fistp		 crt_y			; TOP=0!!!
mov 		ax,max_crt_y
sub 		ax,crt_y
mov 		crt_y,ax		; дзеркальне відображення

mov curcolor,01h; цвет графика
jmp @endytocrt
@minus:
@plus:
fistp crt_y
mov crt_y,0
mov curcolor,0	
@endytocrt:
endm
;//***************************************************************
ytocrt2 macro
fld rl_y
fcom 		min_y;  порівняння ST (0) та min_y
fstsw 		ax; результат порівняння в ax
sahf 				; результат порівняння 
;ST (0) та min_y в регістр Flags
jc 		@minus2		; st0 < min_y
; поза видимим діапазоном
; по @minus2 забезпечити top=0 і
; crt_y=max_crt_y

fcom 		max_y		; порівняння ST (0) та max_y
fstsw		ax
sahf
ja 		@plus2		; st0 > max_y (zf=cf=0)
; поза видимим діапазоном
; по @plus - забезпечити top=0
; і встановити crt_y=0
;-----------------------------------------------------------------
	nop
	;mov ax, rl_y
	;add ax, offset_y
	;mov rl_y, ax
	;sub ax, 1
	;mov offset_y, ax
;fsub		rl_x
;==================================================================
fsub		min_y;
fdiv 		scale_y
frndint				; округлення до цілого
fistp		 crt_y			; TOP=0!!!
mov 		ax,max_crt_y
sub 		ax,crt_y
mov 		crt_y,ax		; дзеркальне відображення

mov curcolor,02h; цвет графика
jmp @endytocrt2
@minus2:
@plus2:
fistp crt_y
mov crt_y,0
mov curcolor,12	
@endytocrt2:
endm
;-++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
func macro 

fld rl_x; st(0)=x
fld rl_x; st(1)=x
fsincos 
fmulp st(1), st
fstp rl_y
	
endm

func2 macro 

fldpi
fidiv ten
fld rl_x
faddp st(1), st
fsin
fld rl_x; st(1)=x
fcos 
fmulp st(1), st
fstp rl_y
	
endm

putpixel macro px,py
mov ax,py
add ax,sc_mody
mov bx,320
imul bx,ax
add bx,px
add bx,sc_modx

mov dl,curcolor
mov es:[bx],dl
endm



begin:

	mov ax,data
	mov ds,ax

	mov 	ax, 13h
	int 	10h
	
	mov ax,0a000h
	mov es,ax
	
	scale x
	scale y
	
	mov cx,99
	mov ax, 320
	mul cx
	add	ax,10
	mov bx,ax
	mov cx, 300
	mov dl,14;30
@dx: ;x axis
	mov es:[bx],dl
	inc bx
	loop @dx

	mov ax, 10
	add ax,cx
	mov bx,320
	mul bx
	add ax,159
	mov bx,ax
	mov cx, 180
	mov dl,14
@dy: ; y axis
	mov es:[bx],dl
	add bx,320
	loop @dy

	;code goes here
	mov ax,40
	sub ax,sc_modx
	mov crt_x,ax
	mov cx,240

@draw:
	xtoreal
	func ax
	ytocrt
	putpixel crt_x,crt_y

;mov ah, 0
;int 16h
	inc crt_x
	dec cx
	cmp cx,0
	jbe @nextdraw
	jmp @draw

;**********************************************
@nextdraw:
	;code goes here
	mov ax,40
	sub ax,sc_modx
	mov crt_x,ax
	mov cx,240
	mov dl, 6
@draw2:
	xtoreal
	func2 ax
	ytocrt2
	putpixel crt_x,crt_y

	inc crt_x
	dec cx
	cmp cx,0
	jbe @enddraw
	jmp @draw2
;**********************************************
@enddraw:
	mov ah, 1
	int 21h
	mov ax,4c00h
	int 21h

code ends
end  begin
