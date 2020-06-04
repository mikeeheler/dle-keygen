; These algorithms come from the code in DLE.EXE.
;
; I presume they were part of the Random module in Turbo Pascal, but I
; am not sure.
;
; Of interest is that while this was built for 16-bit architecture, it
; uses a 32-bit seed in the form of two 16-bit words. Or maybe TP had a
; 32-bit int type and this is just what operations on that type compiled
; down to.
;
; A key part of the algorithm seems to be the prime number 33,797
; (0x8405).
;
; Also, and maybe this is the pattern with psuedo-random generators, but
; it seems to function by mutating the seed and then the next_int
; function just riffs on that a bit given its input mask.
;

section .text

; Set a specific seed for the RNG
rng_seed:
    mov     bx,sp

    mov     ax,[bx+4]
    mov     [rng_seed_1],ax
    mov     ax,[bx+2]
    mov     [rng_seed_2],ax

    retn    4

; 1 input param: upper bound
; The returned value will be less than the number passed in.
rng_next_int:
    enter   0,0

    call    rng_next_seed

    mov     cx,dx
    mul     word [bp+2]
    mov     ax,cx
    mov     cx,dx
    mul     word [bp+2]
    add     ax,cx
    adc     dx,0
    mov     ax,dx

    leave
    retn    2

; This here is why it's called a pseudo-random number generator.
; There's nothing random about this at all.
rng_next_seed:
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

; This is a prime number: 33,797
rng_const   dw      8405h
