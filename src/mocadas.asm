; MOCADAS.ASM - Driver que MONTA A UNIDADE
org 0
bits 16

; --- Cabeçalho   ---
dd -1                ; Next driver
dw 0xC800            ; Attributes: BLOCK + NON_IBM + OPEN/CLOSE
dw strategy
dw interrupt
db "MOCADRV1"        ; Device name (8 bytes, diferente do anterior)

; --- Dados     ---
drive_number db 0
bpb_ptr dd 0
disk_size equ 720    ; 360KB (720 setores de 512 bytes)

; --- Estrutura BPB   ---
bpb:
    dw 512           ; Bytes por setor
    db 2             ; Setores por cluster
    dw 1             ; Setores reservados
    db 2             ; Número de FATs
    dw 112           ; Entradas no root dir
    dw 720           ; Setores totais
    db 0F8h          ; Media descriptor
    dw 1             ; Setores por FAT
    dw 8             ; Setores por trilha
    dw 2             ; Número de cabeçotes
    dd 0             ; Setores escondidos
    dd 0             ; Setores grandes
    db 0             ; Número do disco
    db 0             ; Assinatura
    dd 0             ; Volume ID
    db "NO NAME    " ; Volume label
    db "FAT12   "    ; System ID

; --- Variáveis   ---
reg_es dw 0
reg_bx dw 0

; --- Estratégia     ---
strategy:
    mov [cs:reg_es], es
    mov [cs:reg_bx], bx
    retf

; --- Interrupt  ---
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

.no_dos:
    push cs
    pop ds
    ; Descobre qu  comando é esse
    lds bx, [cs:reg_bx]
    mov al, [bx+2]

    xor al,al
    ; DEBUG: Imprime o valor de AL
    push ax
    push bx
    push cx
    push dx
    push ds
    push cs
    pop ds
    push ax
    mov dx, msg_debug
    mov ah, 09h
    int 21h
    pop ax
    mov dl, al
    call print_hex
    mov dx, msg_crlf
    mov ah, 09h
    int 21h
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax

    cmp al, 0        ; INIT?
    je .init
    cmp al, 2        ; BUILD BPB?
    je .build_bpb
    cmp al, 4        ; READ?
    je .read
    cmp al, 8        ; WRITE?
    je .write

    ; Se não for nenhum dos acima
    mov word [bx+3], 0x8003
    push cs
    pop ds
    mov dx, msg_dos1
    mov ah, 09h
    int 21h

    jmp .done

.init:
    ; Aqui a mágica acontece,  !
    mov byte [cs:drive_number], 3  ; Geralmente C: = 0, D: = 1, etc.

    ; Configura a  coisa toda
    mov word [bx+3], 0x0100        ; Status = OK
    mov byte [bx+14], 1            ; 1 unidade
    mov word [bx+15], driver_end    ; Endereço final
    mov word [bx+17], cs
    mov word [bx+19], bpb           ; Pointer to BPB
    mov word [bx+21], cs
    mov byte al, [cs:drive_number] ; Número da unidade
    mov byte [bx+13], al ; Número da unidade

    ; Manda mensagem pra confirmar que tá vivo
    ; ---- Mensagem via DOS (quando disponível) ----
    push cs
    pop  ds

    mov si, msg
    mov ah, 0Eh
.print:
    lodsb
    test al, al
    jz .init_done
    int 10h
    jmp .print

.init_done:
    push cs
    pop ds
    mov dx, msg_init
    mov ah, 09h
    int 21h    
    jmp .done

.build_bpb:
    ; Retorna o BPB como o DOS quer
    mov word [bx+18], bpb
    mov word [bx+20], cs
    mov word [bx+3], 0x0100
    jmp .done

.read:
    ; Implementação fake de leitura
    mov word [bx+3], 0x0100
    jmp .done

.write:
    ; Implementação fake de escrita
    mov word [bx+3], 0x0100
    jmp .done
.setlogdev:
    xor ax,ax
    jmp .done
.done:
    or   ax, 0x0100 ;set the success bit in AX
    les  di, cs:[reg_bx] ;get the address of the request header
    mov  cs:[di+3], ax ;set the status in the request header    pop es
    pop es
    pop ds
    popa
    retf
; --- Novas funções de debug ---
print_hex:
    ; Imprime DL em hexadecimal
    push ax
    push bx
    push cx
    push dx

    mov ah, 02h
    mov bl, dl

    ; Primeiro nibble
    mov cl, 4
    shr dl, cl
    call .print_nibble

    ; Segundo nibble
    mov dl, bl
    and dl, 0Fh
    call .print_nibble

    pop dx
    pop cx
    pop bx
    pop ax
    ret

.print_nibble:
    cmp dl, 10
    jb .digit
    add dl, 'A' - 10
    jmp .print
.digit:
    add dl, '0'
.print:
    int 21h
    ret

; --- Mensagens de Debug   ---
; --- Novas mensagens de debug ---
msg_debug db '[MOCADAS] Comando recebido: AL=0x$'
msg_crlf db 0Dh,0Ah,'$'
msg_dos  db '[MOCADAS] Carregado via DEVICEHIGH',0Dh,0Ah,'$'
msg_dos1 db '[MOCADAS] Driver saindo antes de processar requisicao',0Dh,0Ah,'$'
msg db "MOCADRV CARREGADO COM SUCESSO!",0Dh,0Ah
    db "USE A UNIDADE E:",0Dh,0Ah,0
msg_init db 'Init',0Dh,0Ah,'$'

; --- Tamanho Fixo   ---
driver_end:
times 1024-($-$$) db 0  ; 1KB exato
