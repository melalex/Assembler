.386

Code SEGMENT PARA PUBLIC 'Code' USE16 
    ASSUME cs:Code
    
start:  mov 	ax, 3              
        int 	10h 
        
        xor 	di, di       
        mov 	cx, 2048              
 
loop1:  push 	0h              
		pop 	es
		mov 	al, es:[di]
		
		push 	0b800h              
		pop 	es
		mov 	es:[di], al
		
		inc		di 
        loop 	loop1
        
   
        mov		ax, 0Ch             
        push 	cs                 
        pop		es                 
        mov 	cx, 100b           
        mov 	dx, offset mouse   
        int 	33h             
 
 
        mov 	ah, 0            
        int 	16h
 
        mov 	ax, 0Ch
        mov 	cx, 0            
        int 	33h
 
		mov 	ax, 4C00h       
        int 	21h;
 
 
mouse proc FAR
		push 	ax
		push 	ds
 
		push 	0B800h              
		pop 	es
 
		mov     cx, 800h     
    	mov     di, 0
    	mov     si, 800h
 
loop2:  mov     al, es:[si]
		mov     ah, es:[di]
		mov     es:[si], ah
		mov     es:[di], al
 
		inc     si
		inc     di
		
		loop    loop2
    
		pop 	ds
		pop 	ax
    
		retf                     
mouse endp

code ENDS
end start