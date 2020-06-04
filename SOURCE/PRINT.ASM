section .text

print_string:
    enter   0,0

    mov     ax,0900h
    mov     dx,[bp+4]
    int     21h

    leave
    retn    2


print_string_2:
    enter   0,0

    mov     cx,[bp+4]
    mov     si,[bp+6]

    mov     ah,02h

.loop:
    lodsb
    mov     dl,al
    int     21h
    loop    .loop

    leave
    retn    4


print_newline:
    mov     ax,0600h

    mov     dl,0Dh
    int     21h

    mov     dl,0Ah
    int     21h

    retn
