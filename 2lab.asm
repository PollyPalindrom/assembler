.model small
.data
    buf db 200 dup (?)
    firstmessage db "please, enter the string", 0Dh,0Ah,'$'
    secondmessage db 0Dh,0Ah,"please, enter the word you would like to delete:", 0Dh,0Ah,'$'
    resultmessage db 0Dh,0Ah,"Result:", 0Dh,0Ah,'$'
    strlength equ 203
    maxlength equ 200
    string db strlength dup('$')
    word db strlength dup('$')
.code  

input macro
    mov ah, 0Ah
    int 21h
endm    

print macro 
    mov ah, 09h
    int 21h    
endm   

stringtoword:
    mov si, offset word[1] 
    inc si
    mov di,si
    add si,-1
    cmp [si+1],' '
    je skipspace   
    cmp [si+1],09h
    je skipspace
    jmp deletetail
deletetail:
    mov si, offset word[1]
    jmp stwloop
stwloop:
    strend
    cmp [si],0Dh
    je stwend
    cmp [si],' '
    je eeend 
    cmp [si], 09h
    je eeend
    jmp stwloop
eeend:
    mov [si],0Dh
    mov [si+1],'$'
    jmp stwend
 
stwend:
    mov dx, offset resultmessage
    print
    mov dx, offset word[2]
    print
    jmp emptystr 
     
skipspace:
    strend
    cmp [si],' '
    je skipspace
    cmp [si],09h
    je skipspace
    jmp nextstep2
        
emptystr:
    mov ah,[string[1]]
    cmp ah,0
    je Result
    mov al, [word[1]]
    cmp al,0
    je Result
    jmp matchsize 
    
matchsize:
    cmp ah,al
    jge findword
    jmp Result     
    
findword:
    mov si,offset string[1]
    mov di, offset word[2]   
    
findsymb:
    strend
    cmp [si], ' '
    je findsymb 
    cmp [si], 09h
    je findsymb
    mov bx, [si]
    mov dl,[si]
    cmp dl, [di]
    je compare    
    jmp skip   
    
compare: 
    inc di 
    cmp [di], 0Dh
    je comp
    jmp next
    
next:
    strend
    mov dl,[si]
    cmp dl, [di]
    je compare 
    mov di, offset word[2]
    jmp skip
    
comp:
    cmp [si+1], ' '
    je delete 
    cmp [si+1], 0Dh
    je delete
    cmp [si+1], 09h
    je delete
    jmp next
    
delete:
    strend      
    jmp return
    cmp [si], ' '
    je nextstep
    cmp [si], 09h
    je nextstep 
    
nextstep:   
    mov dl, [si]
    mov [di], dl
    cmp [di], '$'
    je emptystr
    inc di
    inc si
    jmp nextstep
      
nextstep2:   
    mov dl, [si]
    mov [di], dl
    cmp [di], '$'
    je deletetail
    inc di
    inc si
    jmp nextstep2      
return:
    mov di, si
secondstep:
    sub di,1
    cmp [di], ' '
    jne thirdstep
    jmp nextstep  
    
thirdstep:
    cmp [di], 09h
    jne fourthstep
    jmp nextstep 
         
fourthstep:
    cmp [di-2], 200
    jne secondstep
    jmp nextstep      
skip:
    strend
    cmp [si], ' '
    je findsymb
    cmp [si], 09h
    je findsymb
    jmp skip  
    
strend macro
  inc si
  cmp [si],'$'
  je Result
endm 

space:
    inc si
    cmp [si],'$'
    jne space 
    jmp setspace 
    
setspace:
    mov dl, 0Dh
    mov [si], dl 
    jmp a1
        
start:    
   mov ax,@data
   mov ds,ax   
   mov [string], 200
   mov [word], 200
   mov dx,offset firstmessage
   print
   mov dx,offset string
   input 
   mov si, offset string[1] 
   jmp space
a1: 
   mov dx,offset secondmessage
   print 
   mov dx,offset word
   input 
   jmp stringtoword
Result:
    mov dx, offset resultmessage
    print
    mov dx, offset string[2]
    print 
    mov ax,4c00h
    int 21h
end start 
