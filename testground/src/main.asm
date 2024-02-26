org 0x7c00
bits 16

;setup stack
entry:
  mov ax, 0
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 7c00h


.halt
  jmp .halt
  
times 510-($-$$) db 0
dw 0AA55h