; This tool generates a table containing the first 256 results from the
; random number generator given the input seed 0x1935.
;
; That table can be used to port the key generator to other platforms
; not dependent on the characteristics of 16-bit math.
;

bits    16
cpu     286
global  _start
org     0100h


%define COUNT 8000h


section .text

_start:
    call    genrng_main
    mov     ax,4C00h
    int     21h

genrng_main:
    push    bp
    mov     bp,sp
    sub     sp,COUNT+2

    push    di

    push    1935h
    push    0
    call    rng_seed
    add     sp,4

    lea     di,[bp-COUNT]
    mov     cx,COUNT

    mov     word [bp-COUNT-2],0

.loop:
    push    cx

    push    00FFh
    call    rng_next_int
    inc     ax
    stosb
    pop     dx

    call    byte_to_ascii

    mov     dx,ax
    mov     ax,0200h
    int     21h
    xchg    dh,dl
    int     21h
    mov     dl,0x20
    int     21h

    inc     word [bp-COUNT-2]
    cmp     word [bp-COUNT-2],16
    jne     .no_newline

    mov     dl,0x0D
    int     21h
    mov     dl,0x0A
    int     21h
    mov     word [bp-COUNT-2],0

.no_newline:
    pop     cx
    loop    .loop

    pop     dx
    pop     di

    mov     sp,bp
    pop     bp
    ret


%include 'COMMON\BYTE2ASC.ASM'
%include 'COMMON\PRINT.ASM'
%include 'COMMON\RANDOM.ASM'
