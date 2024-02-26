bits 16

section _TEXT class=CODE
; ------------------------------------------------------------
; Function: __U4D
; Description: Unsigned 4 byte divide
; Inputs:      DX;AX   Dividend
;              CX;BX   Divisor
; Outputs:     DX;AX   Quotient
;              CX;BX   Remainder
; Volatile:    none
; ------------------------------------------------------------
global __U4D
__U4D:
    shl edx, 16         
    mov dx, ax          
    mov eax, edx        
    xor edx, edx

    shl ecx, 16         
    mov cx, bx          

    div ecx             
    mov ebx, edx
    mov ecx, edx
    shr ecx, 16

    mov edx, eax
    shr edx, 16

    ret

; ------------------------------------------------------------
; Function: __U4M
; Description: Integer four byte multiply
; Inputs:      DX;AX   Integer M1
;              CX;BX   Integer M2
; Outputs:     DX;AX   Product
; Volatile:    CX, BX destroyed
; ------------------------------------------------------------
global __U4M
__U4M:
    shl edx, 16         
    mov dx, ax          
    mov eax, edx        

    shl ecx, 16         
    mov cx, bx          

    mul ecx             
    mov edx, eax        
    shr edx, 16

    ret

; ------------------------------------------------------------
; Function: _x86_div64_32
; Description: Divides a 64-bit unsigned integer by a 32-bit unsigned integer.
; Parameters:  [bp + 4]  - lower 32 bits of dividend
;              [bp + 8]  - upper 32 bits of dividend
;              [bp + 12] - divisor
;              [bp + 16] - pointer to store upper 32 bits of quotient
;              [bp + 18] - pointer to store remainder
; ------------------------------------------------------------
global _x86_div64_32
_x86_div64_32:
    push bp             
    mov bp, sp          

    push bx

    mov eax, [bp + 8]   
    mov ecx, [bp + 12]  
    xor edx, edx
    div ecx             

    mov bx, [bp + 16]
    mov [bx + 4], eax

    mov eax, [bp + 4]   
    
    div ecx

    mov [bx], eax
    mov bx, [bp + 18]
    mov [bx], edx

    pop bx

    mov sp, bp
    pop bp
    ret

; ------------------------------------------------------------
; Function: _x86_Video_WriteCharTeletype
; Description: Writes a character to the screen using BIOS interrupt 10h, ah=0Eh.
; Parameters:  [bp + 4] - character to be written
;              [bp + 6] - page
; ------------------------------------------------------------
global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    push bp             
    mov bp, sp          

    push bx

    mov ah, 0Eh
    mov al, [bp + 4]
    mov bh, [bp + 6]

    int 10h

    pop bx

    mov sp, bp
    pop bp
    ret

; ------------------------------------------------------------
; Function: _x86_Disk_Reset
; Description: Resets the disk controller for a specified drive.
; Parameters:  [bp + 4] - drive number
; ------------------------------------------------------------
global _x86_Disk_Reset
_x86_Disk_Reset:
    push bp             
    mov bp, sp          

    mov ah, 0
    mov dl, [bp + 4]    
    stc
    int 13h

    mov ax, 1
    sbb ax, 0           

    mov sp, bp
    pop bp
    ret

; ------------------------------------------------------------
; Function: _x86_Disk_Read
; Description: Reads sectors from a disk.
; Parameters:  [bp + 4]  - drive number
;              [bp + 6]  - cylinder (lower 8 bits)
;              [bp + 7]  - cylinder (bits 6-7)
;              [bp + 8]  - sector (bits 0-5)
;              [bp + 10] - head
;              [bp + 12] - count
;              [bp + 14] - buffer segment
;              [bp + 16] - buffer offset
; ------------------------------------------------------------
global _x86_Disk_Read
_x86_Disk_Read:
    push bp             
    mov bp, sp          

    push bx
    push es

    mov dl, [bp + 4]    

    mov ch, [bp + 6]    
    mov cl, [bp + 7]    
    shl cl, 6
    
    mov al, [bp + 8]    
    and al, 3Fh
    or cl, al

    mov dh, [bp + 10]   

    mov al, [bp + 12]   

    mov bx, [bp + 16]   
    mov es, bx
    mov bx, [bp + 14]

    mov ah, 02h
    stc
    int 13h

    mov ax, 1
    sbb ax, 0           

    pop es
    pop bx

    mov sp, bp
    pop bp
    ret

; ------------------------------------------------------------
; Function: _x86_Disk_GetDriveParams
; Description: Gets disk drive parameters.
; Parameters:  [bp + 4]  - disk drive
;              [bp + 6]  - pointer to store drive type
;              [bp + 8]  - pointer to store cylinders
;              [bp + 10] - pointer to store sectors
;              [bp + 12] - pointer to store heads
; ------------------------------------------------------------
global _x86_Disk_GetDriveParams
_x86_Disk_GetDriveParams:
    push bp             
    mov bp, sp          

    push es
    push bx
    push si
    push di

    mov dl, [bp + 4]    
    mov ah, 08h
    mov di, 0           
    mov es, di
    stc
    int 13h

    mov ax, 1
    sbb ax, 0

    mov si, [bp + 6]    
    mov [si], bl

    mov bl, ch          
    mov bh, cl          
    shr bh, 6
    mov si, [bp + 8]
    mov [si], bx

    xor ch, ch          
    and cl, 3Fh
    mov si, [bp + 10]
    mov [si], cx

    mov cl, dh          
    mov si, [bp + 12]
    mov [si], cx

    pop di
    pop si
    pop bx
    pop es

    mov sp, bp
    pop bp
    ret
