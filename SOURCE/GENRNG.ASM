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
    push    bp
    mov     bp,sp
    sub     sp,2

    push    1935h
    push    0
    call    rng_seed
    add     sp,4

    mov     cx,COUNT
    mov     word [bp-2],0

.loop:
    push    cx

    push    00FFh
    call    rng_next_int
    inc     ax
    pop     dx

    call    byte_to_ascii

    mov     dx,ax
    mov     ax,0200h
    int     21h
    xchg    dh,dl
    int     21h
    mov     dl,0x20
    int     21h

    inc     word [bp-2]
    cmp     word [bp-2],16
    jne     .no_newline

    mov     dl,0x0D
    int     21h
    mov     dl,0x0A
    int     21h
    mov     word [bp-2],0

.no_newline:
    pop     cx
    loop    .loop

    pop     dx
    pop     di

    mov     sp,bp
    pop     bp

    mov     ax,4C00h
    int     21h


%include 'COMMON\BYTE2ASC.ASM'
%include 'COMMON\PRINT.ASM'
%include 'COMMON\RANDOM.ASM'
