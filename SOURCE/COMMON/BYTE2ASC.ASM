section .data

hex_array   db  '0123456789ABCDEF'


section .text

; Converts a byte into a 2-byte ASCII representation
; i.e. 0xCD -> "CD"
; Result is returned in AX with the high 4 bits represented in AL and
; the low 4 bits in AH. This is so that they can be written in order
; to a memory stream with `stosw` (assumes little-endian byte order).
byte_to_ascii:
    push    si

    xor     ch,ch
    xor     dh,dh

    mov     dl,al
    and     dl,0xF0
    shr     dl,4

    mov     cl,al
    and     cl,0x0F

    mov     si,hex_array
    add     si,dx
    lodsb
    mov     ah,al

    mov     si,hex_array
    add     si,cx
    lodsb

    xchg    ah,al

    pop     si
    ret
