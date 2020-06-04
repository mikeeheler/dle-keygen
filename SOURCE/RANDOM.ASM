section .text

rng_seed:
    mov     bx,sp

    mov     ax,[bx+4]
    mov     [rng_seed_1],ax
    mov     ax,[bx+2]
    mov     [rng_seed_2],ax

    retn    4

rng_next_byte:
    enter   0,0

    call    rng_next

    mov     cx,dx
    mul     word [bp+2]
    mov     ax,cx
    mov     cx,dx
    mul     word [bp+2]
    add     ax,cx
    adc     dx,0x0000
    mov     ax,dx

    leave
    retn    2

; This here is why it's called a pseudo-random number
; generator. There's nothing random about this at all.
rng_next:
    mov     ax,[rng_seed_1]
    mov     bx,[rng_seed_2]
    mov     cx,ax
    mul     word [rng_const]
    shl     cx,3
    add     ch,cl
    add     dx,cx
    add     dx,bx
    shl     bx,2
    add     dx,bx
    add     dh,bl
    shl     bx,5
    add     dh,bl
    add     ax,1
    adc     dx,0
    mov     [rng_seed_1],ax
    mov     [rng_seed_2],dx
    retn


section .bss

rng_seed_1  resw    1
rng_seed_2  resw    1


section .data

rng_const   equ     8405h
