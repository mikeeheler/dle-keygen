# Development

This document is just a place to keep notes on working on this thing.

## Call Convention

The original DLE code was written in Turbo Pascal and thus was compiled
to use the [pascal][1] calling convention.

Since this project is pure assembly that doesn't interface with any
external APIs, it's free to use any convention. To that end, conventions
are helpful for consistency and it uses the [cdecl][2] convention.

In summary:

* Callee must preserve all registers except AX, CX, and DX.
* Ordinal values can be returned in AL, AX, or DX:AX.
* All arguments are pushed onto the stack.
* The caller cleans up the stack.
  * The caller's only real obligation here is to restore SP before
    returning-- not necessarily after every call.
* Argument push order is meaningless in pure assembly. Just put stuff on
  the stack where the called function expects them.


### Example

16-bit assembly follows:

```asm
bits    16
cpu     286
org     0100h


section .data

my_string           db  'Hello, World!',0x0D,0x0A,'$'
my_string_length    equ $-my_string


section .text

main:
    push    bp
    mov     bp,sp
    ; Reserve some space on the stack for local data
    sub     sp,0100h

    lea     dx,[bp-0100h]
    push    dx                  ; Save for later

    ; Copy string from DS into local stack
    push    dx
    push    my_string
    push    my_string_length
    call    memcpy
    add     sp,6                ; Caller cleanup

    ; Print to screen
    pop     dx
    mov     ax,0900h
    int     21h

    mov     sp,bp
    pop     bp

    ; Exit program
    mov     ax,4C00h
    int     21h


memcpy:
    ; Save non-volatile registers
    push    bp
    push    di
    push    si
    mov     bp,sp

    mov     di,[bp+12]
    mov     si,[bp+10]
    mov     cx,[bp+8]
    rep     movsb

    ; Restore non-volatile registers
    mov     sp,bp
    pop     si
    pop     di
    pop     bp
    ret
```

[1]: https://en.wikipedia.org/wiki/X86_calling_conventions#pascal
[2]: https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl
