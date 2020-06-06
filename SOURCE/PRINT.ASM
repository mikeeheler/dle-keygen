 ; Just a few helper functions for printing text to the screen
 ; print_string prints a '$'-terminated string to stdout
 ; print_newline sends CRLF to the terminal

section .text

; int 21h/AH=09h - Print '$'-terminated string to stdout
print_string:
    push    bp
    mov     bp,sp

    mov     ax,0900h
    mov     dx,[bp+4]
    int     21h

    mov     sp,bp
    pop     bp
    ret


; Emits CRLF directly to stdout
print_newline:
    mov     ax,0600h

    mov     dl,0Dh
    int     21h

    mov     dl,0Ah
    int     21h

    ret
