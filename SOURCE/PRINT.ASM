section .text

print_string:
    mov     bx,sp

    mov     ax,0900h
    mov     dx,[bx+4]
    int     21h

    ret


print_string_2:
    mov     bx,sp

    mov     cx,[bx+4]
    mov     si,[bx+6]

    mov     ah,02h

.loop:
    lodsb
    mov     dl,al
    int     21h
    loop    .loop

    ret


print_newline:
    mov     ax,0600h

    mov     dl,0Dh
    int     21h

    mov     dl,0Ah
    int     21h

    ret
