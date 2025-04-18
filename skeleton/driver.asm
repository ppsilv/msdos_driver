org 0
bits 16


MaxCmd equ 24
cr     equ 0x0d
lf     equ 0x0a
eom    equ '$'

Header:
        dd -1
        dw 0x0C840
        dw Strat
        dw Intr
        db 'SKELETON'

RHPtr:
        dd 0

Dispatch:
        dw Init                ; 0 - initialize the driver       
        dw MediaChk            ; 1 - check media type                                
        dw BuildBpb            ; 2 - build BIOS parameter block
        dw IoctlRd             ; 3 - read I/O control
        dw Read                ; 4 - read
        dw NwRead              ; 5 - read (network)
        dw InpStat             ; 6 - input status
        dw inpFlush            ; 7 - input flush
        dw Write               ; 8 - write
        dw WriteVerify         ; 9 - write verify
        dw OutStat             ; 10 - output status
        dw OutFlush            ; 11 - output flush
        dw IoctlWr             ; 12 - write I/O control
        dw DevOpen             ; 13 - open device
        dw DevClose            ; 14 - close device
        dw RemMedia            ; 15 - remove media
        dw OutBusy             ; 16 - output busy
        dw Error               ; 17 - error
        dw Error               ; 18 - error
        dw GenIoctl            ; 19 - general I/O control
        dw Error               ; 20 - error
        dw Error               ; 21 - error
        dw Error               ; 22 - error
        dw GetLogDev           ; 23 - get logical device number
        dw SetLogDev           ; 24 - set logical device number

Strat:
        mov word  cs:[RHPtr], bx
        mov word  cs:[RHPtr+2], es
        ret

Intr:
        push ax
        push bx
        push cx
        push dx
        push ds 
        push es
        push si
        push di
        push bp

        push cs     ;make local data addressable
        pop  ds     ;by setting DS = CS
        
        les  di, [RHPtr] ;get the address of the request header

        mov  bl, es:[di+2] ;get the command code
        xor  bh, bh ;clear the high byte of BX
        cmp  bl, MaxCmd ;check if the command code is valid
        ;jle  [Dispatch + bx * 2] ;jump to the appropriate handler
        jle  Intr1
        call Error ;call the error handler
        jmp  Intr2
Intr1:
        shl bx, 1 ;multiply BX by 2 to get the offset in the dispatch table

        ; Call the appropriate handler based on the command code
        call word [Dispatch + bx]
        
        les  di, [RHPtr] ;get the address of the request header
Intr2:
        or   ax, 0x0100 ;set the success bit in AX
        mov  es:[di+3], ax ;set the status in the request header

        pop bp
        pop di
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        ret

; Command code routines are called bu the interrupt routine
; via the dispatch table. The command code is passed in
; the low byte of BX. The high byte of BX is cleared
; before the command code is passed to the handler.
; Each routine should return AX = 0 if function was
; completed successfully, or AX = 0x8000 + error code if an error
; occurred. The error code is a number between 0 and 255.
; The error code is returned in the request header at offset 3.
; The request header is passed in ES:DI. The request header
; is a data structure that contains information about the
; request, such as the command code, status, and data buffer.
; The request header is defined in the BIOS documentation.


Init:
        ; Initialize the driver
        ; This is where you would set up any necessary data structures or state
        ; for your driver. For example, you might initialize a buffer or set up
        ; a file system structure.
        push es
        push di

        mov ax, cs
        mov bx,  Ident1
        call hexasc

        mov ah, 9
        mov dx,  Ident1
        int 21h

        pop di
        pop es

        mov word es:[di+14],  Init
        mov word es:[di+16], cs        
        ; Return success
        xor ax, ax
        ret
hexasc:
        ; Convert a string to ASCII hex
        push cx
        push dx

        mov dx, 4
hexasc1:
        mov cx, 4
        rol ax, cl
        mov cx, ax
        and cx, 0x0f
        add cx, '0'
        cmp cx, '9'
        jbe hexasc2
        add cx, 'A' - '9' - 1
hexasc2:
        mov [bx], cl
        inc bx
        dec dx
        jnz hexasc1

        pop dx
        pop cx       
        ; Return success
        xor ax, ax
        ret
Ident   db cr,lf,lf 
        db 'PDSilva Skeleton driver loaded', cr, lf, eom
        db cr,lf
        db 'Device Driver header at: '
Ident1  db 'XXXX:0000', cr, lf, eom

MediaChk:
        ; Check the media type
        ; This is where you would check the type of media that is currently
        ; inserted in the drive. For example, you might check if a diskette
        ; is present or if a CD-ROM is inserted.
        


        ; Return success
        xor ax, ax
        ret
BuildBpb:
        ; Build the BIOS parameter block
        ; This is where you would build the BIOS parameter block (BPB) for
        ; the media type that is currently inserted. The BPB contains information
        ; about the file system, such as the number of sectors per cluster,
        ; number of reserved sectors, and so on.
        
        ; Return success
        xor ax, ax
        ret
IoctlRd:
        ; Handle I/O control read requests
        ; This is where you would handle I/O control read requests from the
        ; operating system or other software. For example, you might read
        ; information about the media or the file system.
        
        ; Return success
        xor ax, ax
        ret
Read:
        ; Handle read requests
        ; This is where you would handle read requests from the operating
        ; system or other software. For example, you might read data from
        ; the media and return it to the caller.

        ; Return success
        xor ax, ax
        ret
NwRead:
        ; Handle network read requests
        ; This is where you would handle network read requests from the
        ; operating system or other software. For example, you might read
        ; data from a network resource and return it to the caller.
        
        ; Return success
        xor ax, ax
        ret
InpStat:
        ; Handle input status requests
        ; This is where you would handle input status requests from the
        ; operating system or other software. For example, you might check
        ; if there is data available to read from the media.
        
        ; Return success
        xor ax, ax
        ret
inpFlush:
        ; Handle input flush requests
        ; This is where you would handle input flush requests from the
        ; operating system or other software. For example, you might clear
        ; any buffered data that has not yet been read.
        
        ; Return success
        xor ax, ax
        ret
Write:
        ; Handle write requests
        ; This is where you would handle write requests from the operating
        ; system or other software. For example, you might write data to
        ; the media.
        
        ; Return success
        xor ax, ax
        ret
WriteVerify:
        ; Handle write verify requests
        ; This is where you would handle write verify requests from the
        ; operating system or other software. For example, you might verify
        ; that data has been written correctly to the media.
        
        ; Return success
        xor ax, ax
        ret
OutStat:
        ; Handle output status requests
        ; This is where you would handle output status requests from the
        ; operating system or other software. For example, you might check
        ; if there is space available to write data to the media.
        
        ; Return success
        xor ax, ax
        ret
OutFlush:
        ; Handle output flush requests
        ; This is where you would handle output flush requests from the
        ; operating system or other software. For example, you might clear
        ; any buffered data that has not yet been written.
        
        ; Return success
        xor ax, ax
        ret
IoctlWr:
        ; Handle I/O control write requests
        ; This is where you would handle I/O control write requests from the
        ; operating system or other software. For example, you might write
        ; information about the media or the file system.
        
        ; Return success
        xor ax, ax
        ret
DevOpen:
        ; Handle device open requests
        ; This is where you would handle device open requests from the
        ; operating system or other software. For example, you might open
        ; a file or prepare the media for use.
        
        ; Return success
        xor ax, ax
        ret
DevClose:
        ; Handle device close requests
        ; This is where you would handle device close requests from the
        ; operating system or other software. For example, you might close
        ; a file or prepare the media for removal.
        
        ; Return success
        xor ax, ax
        ret
RemMedia:
        ; Handle remove media requests
        ; This is where you would handle remove media requests from the
        ; operating system or other software. For example, you might
        ; prepare the media for removal or check if it is safe to remove.
        ; Return success
        xor ax, ax
        ret
OutBusy:
        ; Handle output busy requests
        ; This is where you would handle output busy requests from the
        ; operating system or other software. For example, you might check
        ; if the media is busy and return an appropriate status.
        
        ; Return success
        xor ax, ax
        ret
Error: ;bad command code in resquest header
        mov ax, 0x8003 ;error bit + "unknown command" code
        ret
GenIoctl:
        ; Handle general I/O control requests
        ; This is where you would handle general I/O control requests from
        ; the operating system or other software. For example, you might
        ; perform a specific operation on the media or file system.
        
        ; Return success
        xor ax, ax
        ret
GetLogDev:
        ; Handle get logical device number requests
        ; This is where you would handle get logical device number requests
        ; from the operating system or other software. For example, you might
        ; return the logical device number for the media.
        
        ; Return success
        xor ax, ax
        ret
SetLogDev:
        ; Handle set logical device number requests
        ; This is where you would handle set logical device number requests
        ; from the operating system or other software. For example, you might
        ; set the logical device number for the media.
        
        ; Return success
        xor ax, ax
        ret