 ; Just a few helper functions for printing text to the screen
 ; print_string prints a '$'-terminated string to stdout
 ; print_string_2 takes a string and a byte length and prints it to stdout
 ; print_newline sends CRLF to the terminal

section .text

print_string:
    push    bp
    mov     bp,sp

    mov     ax,0900h
    mov     dx,[bp+4]
    int     21h

    mov     sp,bp
    pop     bp
    ret


print_string_2:
    push    bp
    mov     bp,sp
    push    si

    mov     si,[bp+6]
    mov     cx,[bp+4]
    mov     ah,06h
.loop:
    lodsb
    mov     dl,al
    int     21h
    loop    .loop

    pop     si
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
