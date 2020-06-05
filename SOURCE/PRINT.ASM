section .text

print_string:
    push    bp
    mov     bp,sp

    mov     ax,0900h
    mov     dx,[bp+2]
    int     21h

    pop     bp
    ret


print_string_2:
    push    bp
    mov     bp,sp
    push    si

    mov     cx,[bp+2]
    mov     si,[bp+4]

    mov     ah,02h

.loop:
    lodsb
    mov     dl,al
    int     21h
    loop    .loop

    pop     si
    pop     bp
    ret


print_newline:
    mov     ax,0600h

    mov     dl,0Dh
    int     21h

    mov     dl,0Ah
    int     21h

    ret
