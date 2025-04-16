;mocadas.asm
;nasm -f bin -o mocadas.sys mocadas.asm
;
;

org 0
bits 16

section .text

dd -1                ; Next driver (-1=end of chain)
dw 0xC800            ; Attributes (CHARACTER + OPEN/CLOSE)
dw strategy          ; Strategy
dw interrupt         ; Interrupt
db "MOCADAS$"        ; Device name (8 bytes)

strategy:
    mov [cs:req_seg], es
    mov [cs:req_off], bx
    retf

interrupt:
    pusha
    push ds
    push es

    ; ---- Verifica se o DOS está pronto ----
    mov ah, 30h
    int 21h
    cmp al, 3
    jb .no_dos

    ; ---- Mensagem via DOS (quando disponível) ----
    push cs
    pop ds
    mov dx, msg_dos
    mov ah, 09h
    int 21h
    jmp .process_request

.no_dos:
    ; ---- Fallback para BIOS ----
    mov si, msg_bios
    mov ah, 0Eh
    mov bx, 0007h
.print_loop:
    lodsb
    test al, al
    jz .process_request
    int 10h
    jmp .print_loop

.process_request:
    les bx, [cs:req_off]
    mov word [es:bx+3], 0x0100  ; Status=sucesso
    mov byte [es:bx+14], 1      ; 1 unidade

    pop es
    pop ds
    popa
    retf

req_seg dw 0
req_off dw 0
msg_dos db '[MOCADAS] Carregado via DEVICEHIGH',0Dh,0Ah,'$'
msg_bios db 'MOCADAS [BIOS]',0Dh,0Ah,0

section .bss
resb 1024-($-$$)  ; Preenche para 1KB

;check_8088:
;    pushf
;;    xor ax, ax
;    push ax
;    popf
;    pushf
;    pop ax
;    and ax, 0xF000
;    cmp ax, 0xF000  ; 8088/8086 sempre tem bits 12-15=1 nos FLAGS
;    jne .not_8088
;    ; Código específico para 8088
;.not_8088:


