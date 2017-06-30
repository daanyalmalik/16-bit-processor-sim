.model small
.stack 100h
.data
var_name_off dw 0 ;va 
var_off dw 0
ram_index dw 16 
ram_index_chk dw 0  ;ram array value set after entry


address_index dw 17 
address_index_chk dw 0 
address_jmp db 0
array_num db 0
temp dw 0 
indx_src dw 0
indx_cmp dw 0 
indx_var dw 0

src_selec dw 0 ;sourse selection
calc_address db -2 ;address for varible 

file1 db "file.txt",0 
buffer db 1000 dup("$") 
var_name db 2000 dup("$") 
var_value db 2000 dup(0) 
ram_array db 8000 dup(0)   ;binary numbers
ram_address db 8000 dup(0) ;address 
inst_bin db 2000 dup(0) ;instruction binary
src_array db 10 dup("$");temp array to check for sourse reg or variable
temp_cmp_arr db 10 dup("$") ;checking for strings
         
.code  
mov ax,@data
mov ds,ax

;-----reading from file---- 
mov dx,offset file1
mov al,0
mov ah,3dh
int 21h

mov bx,ax ;handler

mov dx,offset buffer
mov ah,3fh
int 21h
        
              
;mov dx,offset buffer
;mov ah,09h
;int 21h
;-----------


;----seaprating variables and shit----- 
;mov si,offset buffer 

;mov di,offset var
;mov var_off,di 

;mov di,offset ram_array
;add di,16
;mov ram_index,di

;mov di,offset var_name
;mov var_name_off,di

mov si,0  ;si controls buffer
mov di,0
while_main:

cmp buffer[si],"."
je seg_chk

seg_chk:
    inc si
    cmp  buffer[si],"d"
    add si,3
    je data_seg
    
data_seg:
    
    inc si 
    cmp buffer[si],0DH
    jne next
    add si,2
        
    next:
        mov di,var_name_off
        mov al,buffer[si]
        mov var_name[di],al ;storing variable name to array
        inc di 
        mov var_name_off,di
        cmp buffer[si],032
        je  number
        jmp continue
        
        
     number:
        mov di, var_off ;moving variable values to the other array
        add si,4
        mov al,buffer[si] 
        cmp buffer[si+1],47
        ja dd_chk   ;checking for double digit here
        sub al,48
        jmp num_cont
        
        dd_chk:
            sub al,48
            mov bl,10
            mul bl
            inc si
            add al,buffer[si]
            sub al,48
        
        num_cont:
        mov var_value[di],al
        inc di
        mov var_off,di ;var value array save
        mov array_num,al
         
        
        mov di,ram_index 
        mov ram_index_chk,di ;storing original ram index value
        
        mov ram_array[di],032 ;adding space after every binary number
        dec ram_index
        mov cx,16   ;converting to binary
        cvt_binary: 
            mov ah,0
            mov di,ram_index 
            mov al,array_num
            mov bl,2
            div bl  
            
            mov array_num,al
            mov ram_array[di],ah
            dec ram_index 
            loop cvt_binary
            
            add ram_index_chk,17 
            mov ax, ram_index_chk
            mov ram_index,ax
            
           jmp address_calcu
         
         
        address_calcu:
        
        mov di,address_index 
        mov address_index_chk,di ;storing original ram index value
        
        mov ram_address[di],032 ;adding space after every binary number
        dec address_index
        mov cx,17   ;converting to binary
        cvt_binary2: 
            mov ah,0
            mov di,address_index 
            mov al,address_jmp
            mov bl,2
            div bl  
            
            mov address_jmp,al
            mov ram_address[di],ah
            dec address_index 
            loop cvt_binary2
            
            add address_index_chk,18 
            mov ax, address_index_chk
            mov address_index,ax
            add address_jmp,2       
        jmp continue
        
        
        
        
            
    
   
    
continue:
       cmp buffer[si],"."
       je seg_chk2
       jmp data_seg 
    
    
    
seg_chk2:
    inc si
    mov ram_index,0
    cmp  buffer[si],"c"
    add si,3
    je code_seg
     
    code_seg:
        inc si 
        cmp buffer[si],0DH
        jne next2
        add si,2 
        
        next2:
            cmp buffer[si],"m"
            je op_chk1
            
            cmp buffer[si],"a"
            je op_chk2 
            
            cmp buffer[si],"s"
            je op_chk3
             
            cmp buffer[si],"o"
            je op_or
            
            cmp buffer[si],"x"
            je op_xor
            
            cmp buffer[si],"n"
            je op_not
            
            
            cmp buffer[si],"l"
            je op_l1
            
            cmp buffer[si],"j"
            je op_jmp
            
            
        op_chk1:    
            inc si
            cmp buffer[si],"o"
            je op_mov
            cmp buffer[si],"u"
            je op_mul
            jmp continue2 
            
        op_chk2:    
            inc si
            cmp buffer[si],"d"
            je op_add
            cmp buffer[si],"n"
            je op_and
            jmp continue2  
            
        op_chk3:    
            inc si
            cmp buffer[si],"u"
            je op_sub
            cmp buffer[si+1],"l"
            je op_shl 
            cmp buffer[si+1],"r"
            je op_shr
            jmp continue2    
         
        op_add: 
            mov di,ram_index
           
            mov inst_bin[di],0   ;msb is 1 to indicate its from code seg
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di   
            mov inst_bin[di],0
            inc di 
            mov ram_index,di
            jmp des_chk
 
        op_sub:
            mov di,ram_index  ;opcode 0001
           
            
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di   
            mov inst_bin[di],1
            inc di 
            mov ram_index,di
            jmp des_chk
        
        op_and:
            mov di,ram_index
                                   ;opcode 0010
            
            
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di   
            mov inst_bin[di],0
            inc di 
            mov ram_index,di
            jmp des_chk
        op_or:
            mov di,ram_index
                               ;opcode 0011
            
            
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di   
            mov inst_bin[di],1
            inc di 
            mov ram_index,di
            jmp des_chk
        op_xor:
            mov di,ram_index
                                   ;opcode 0100
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],0
            inc di   
            mov inst_bin[di],0
            inc di 
            mov ram_index,di
            jmp des_chk
        op_not:
            mov di,ram_index
                           ;opcode 0101
            
            
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],0
            inc di   
            mov inst_bin[di],1
            inc di 
            mov ram_index,di
            jmp des_chk    
                  
        op_shl:
            mov di,ram_index
                                  ;opcode 0110
            
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],1
            inc di   
            mov inst_bin[di],0
            inc di 
            mov ram_index,di
            jmp des_chk
        op_shr:
            mov di,ram_index
                               ;opcode 0111
         
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],1
            inc di   
            mov inst_bin[di],1
            inc di 
            mov ram_index,di
            jmp des_chk        
        op_l1:  
            mov di,ram_index
                                   ;opcode 1000
            
            
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di   
            mov inst_bin[di],0
            inc di 
            mov ram_index,di
            jmp des_chk
        op_jmp:
            mov di,ram_index
                                   ;opcode 1001
            
            
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],0
            inc di   
            mov inst_bin[di],1
            inc di 
            mov ram_index,di
            jmp des_chk 
                      
        op_mul:
            mov di,ram_index
                               ;opcode 1010
            
            
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di   
            mov inst_bin[di],0
            inc di 
            mov ram_index,di
            jmp des_chk 
            
        op_mov:
            mov di,ram_index
                                   ;opcode 1011
            inc di
            
            mov inst_bin[di],1
            inc di
            mov inst_bin[di],0
            inc di
            mov inst_bin[di],1
            inc di   
            mov inst_bin[di],1
            inc di 
            mov ram_index,di
            jmp des_chk
        
        
        des_chk:
            add si,5  ;checking for comma
            cmp buffer[si],","
            je reg_chk
            jmp its_variable 
           
            
            reg_chk:
                dec si ;dec once to check for reg
                cmp buffer[si],"x"
                je reg_
                jmp its_variable
                
            reg_: 
                 dec si   ;dec again to confirm reg
                 cmp buffer[si],"a"
                 je reg_ax
                 cmp buffer[si],"b"
                 je reg_bx
                 cmp buffer[si],"c"
                 je reg_cx
                 cmp buffer[si],"d"
                 je reg_dx
                 jmp its_variable
                 
                 
                 reg_ax: 
                    mov di,ram_index
                    mov inst_bin[di],0 
                    inc  di
                    mov src_selec,di ;destination code location
                    
                    add ram_index,2
                    mov di, ram_index
                    mov inst_bin[di],0  ;AX IS 00
                    inc di
                    mov inst_bin[di],0
                    inc di
                    mov ram_index,di
                    
                    add si,3
                    jmp src_chk   ;going to sourse
                    
                    ;jmp exit
                    
                 reg_bx:
                    mov di,ram_index
                    mov inst_bin[di],0 
                    inc  di
                    mov src_selec,di ;destination code location
                    
                    add ram_index,2
                    mov di, ram_index
                    mov inst_bin[di],0  ;BX IS 01
                    inc di
                    mov inst_bin[di],1
                    inc di
                    mov ram_index,di
                    
                    add si,3
                    jmp src_chk   ;going to sourse
                    
                 reg_cx:
                    mov di,ram_index
                    mov inst_bin[di],0 
                    inc  di
                    mov src_selec,di ;destination code location
                    
                    add ram_index,2
                    mov di, ram_index
                    mov inst_bin[di],1  ;CX IS 10
                    inc di
                    mov inst_bin[di],0
                    inc di
                    mov ram_index,di
                    
                    add si,3
                    jmp src_chk   ;going to sourse 
                    
                 reg_dx: 
                    mov di,ram_index
                    mov inst_bin[di],0 
                    inc  di
                    mov src_selec,di ;destination code location
                    
                    add ram_index,2
                    mov di, ram_index
                    mov inst_bin[di],1  ;DX IS 11
                    inc di
                    mov inst_bin[di],1
                    inc di
                    mov ram_index,di
                    
                    add si,3
                    jmp src_chk   ;going to sourse 
                    
                 its_variable: 
                 
                 
                 
                 src_chk:
                    
                    mov di,0                   
                    while_src:                  ;copy value after comma to temp 
                                                ;array to check if its reg or variable   
                        mov al,buffer[si]
                        mov src_array[di],al
                        inc si
                        inc di
                        
                        cmp buffer[si],0DH ;***----check for next line or end of file----***
                        jne while_src
                        
                        cmp src_array[2],"$"
                        je its_a_reg
                        jmp its_a_var
                        
                        its_a_var:
                            mov di,src_selec
                            mov inst_bin[di],1 ;mov source selection code into array
                                                ;comes before so using it 
                            
                            ;mov di,ram_index
                            ;mov inst_bin[di],2  ;adding var address
                            ;int 21h 
                            
                            mov di,0
                            
                            ;indx_src
                            ;indx_cmp
                            ;temp_cmp_arr
                            ;mov bp,
                             while_var:
                                    
                                 while_chk: 
                                    mov di,indx_var
                                    mov al,var_name[di] 
                                    inc indx_var  
                                    
                                    mov di,indx_cmp
                                    mov temp_cmp_arr[di],al  ;copy variable 
                                    inc indx_cmp             ;from var_array to temp array   
                                    
                                    mov di,indx_var
                                    cmp var_name[di],032
                                    je contx: 
                                    jmp while_chk
                                    contx: 
                                        inc indx_var      ;moving to next var from space 
                                        mov  indx_cmp,0
                                        add calc_address,2
                                        
                                    
                                 mov di,0
                                 while_str_cmp:
                                    
                                    mov al,temp_cmp_arr[di]  ;comparing the two strings vars
                                    cmp al,src_array[di]
                                    je n1
                                    jmp while_chk
                                    
                                        
                                    n1:
                                        inc di
                                       cmp src_array[di],"$"
                                       jne while_str_cmp
                                       jmp var_address
                                       
                                    var_address:
                                         
                                        mov cx,8   ;converting to binary
                                        cvt_binary3: 
                                            mov ah,0
                                            mov di,ram_index 
                                            mov al,calc_address
                                            mov bl,2
                                            div bl  
                                            
                                            mov array_num,al
                                            mov inst_bin[di],ah
                                            inc ram_index 
                                            loop cvt_binary3 
                                            inc di
                                            mov inst_bin[di],032
                                            int 21h                              
                                    
                            
                        
                        its_a_reg:
                            cmp src_array[1],"x"
                            je reg_1
                            jmp var_
                            
                            reg_1:
                                cmp src_array[0],"b"
                                je regb
                                cmp src_array[0],"c"
                                je regc
                                cmp src_array[0],"d"
                                je regd
                                jmp  var_
                                
                                regb:
                                    mov di,src_selec
                                    mov inst_bin[di],0 ;mov source selection code into array
                                    mov di,ram_index
                                    mov cx,8
                                    l1:
                                        mov inst_bin[di],3
                                        inc di
                                        loop l1
                                        ;inc di
                                        mov inst_bin[di],032 
                                        inc di
                                        mov ram_index,di
                                    int 21h
                                regc: 
                                    mov di,src_selec
                                    mov inst_bin[di],0 ;mov source selection code into array
                                    mov di,ram_index
                                    mov cx,8
                                    l1c:
                                        mov inst_bin[di],3
                                        inc di
                                        loop l1c
                                        ;inc di
                                        mov inst_bin[di],032 
                                        inc di
                                        mov ram_index,di
                                regd: 
                                    mov di,src_selec
                                    mov inst_bin[di],0 ;mov source selection code into array
                                    mov di,ram_index
                                    mov cx,8
                                    l1d:
                                        mov inst_bin[di],3
                                        inc di
                                        loop l1d
                                        ;inc di
                                        mov inst_bin[di],032 
                                        inc di
                                        mov ram_index,di
                                 
                               
                            var_:
                                jmp its_a_var

continue2:
       cmp buffer[si],"$"
       je e
       jmp code_seg 


invalid_ins:
    ;wrong instruction
exit:
mov dx,offset buffer
mov ah,09h
int 21h

mov dl,10
mov ah,02h
int 21h

mov dl,13
mov ah,02h
int 21h

;mov dx,offset var
;mov ah,09h
;int 21h
e:
mov ah,4ch
int 21h
end