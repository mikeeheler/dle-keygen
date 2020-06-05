section .text

; Have DOS print a '$'-terminated string
print_string:
    push    bp
    mov     bp,sp

    mov     ax,0900h
    mov     dx,[bp+4]
    int     21h

    mov     sp,bp
    pop     bp
    ret


; Print a certain number of bytes
print_string_2:
    push    bp
    mov     bp,sp
    sub     sp,0101h

    push    di
    push    si

    lea     dx,[bp-0101h]
    mov     di,dx
    mov     si,[bp+6]
    mov     cx,[bp+4]
    xor     ch,ch
    rep     movsb
    mov     al,024h
    stosb

    mov     ax,0900h
    lea     dx,[bp-0101h]
    int     21h

    pop     si
    pop     di

    mov     sp,bp
    pop     bp
    ret


print_newline:
    mov     ax,0600h

    mov     dl,0Dh
    int     21h

    mov     dl,0Ah
    int     21h

    ret
