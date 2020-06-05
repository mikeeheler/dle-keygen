bits    16                      ; Hell yeah, brutha!
cpu     286                     ; Hell yeah, brutha!
global  _start
org     0100h                   ; Tell NASM where COM code is loaded


; Entrypoint stub. This needs to be the first code in the file.
section .text

_start:
    call    main
    mov     ax,4C00h
    int     21h


%include 'RANDOM.ASM'
%include 'PRINT.ASM'


section .data

; These are the default values from when DLE's SETUP.EXE is first run.
bbs         db  'Even Cooler Bbs'
bbs_len     equ $-bbs

sysop       db  'Really Cool Sysop'
sysop_len   equ $-sysop

hex         db  '0123456789ABCDEF'

sysop_name  db  'Sysop : $'
bbs_name    db  'Bbs   : $'
reg1        db  'Reg 1 : $'
reg2        db  'Reg 2 : $'


section .bss

bbs_key     resb    0100h
sysop_key   resb    0100h


section .text

main:
    push    bp
    mov     bp,sp

    push    sysop_key
    push    sysop
    push    sysop_len
    call    .gen_key

    push    bbs_key
    push    bbs
    push    bbs_len
    call    .gen_key


    push    sysop_name
    call    print_string

    push    sysop
    push    sysop_len
    call    print_string_2
    call    print_newline


    push    bbs_name
    call    print_string

    push    bbs
    push    bbs_len
    call    print_string_2
    call    print_newline


    push    reg1
    call    print_string

    push    sysop_key
    call    .print_key
    call    print_newline

    push    reg2
    call    print_string

    push    bbs_key
    call    .print_key
    call    print_newline

    mov     sp,bp
    pop     bp
    ret


.gen_key:
    ; Inputs:
    ; bp+6 - input string
    ; bp+4 - input string length
    ;
    ; Outputs:
    ; bp+8 - output key in binary
    push    bp
    mov     bp,sp

    ; Seed the random number generator
    mov     ax,1935h
    mov     dx,0
    push    ax
    push    dx
    call    rng_seed

    ; initialize the memory where we're writing the key, mostly for
    ; debugging.
    mov     di,[bp+8]
    mov     ax,0xFEBE
    mov     cx,0x80
    rep     stosw

    ; loop init
    mov     cx,[bp+4]
    mov     si,[bp+6]
    mov     di,[bp+8]
    ; key length will be stored at index 0
    inc     di

.loop:
    push    cx

    ; Set the mask for the RNG. This causes it to return 0 <= N < 0xFF.
    mov     ax,00FFh
    push    ax
    call    rng_next_int
    ; In a loop so restore the stack
    add     sp,2

    ; Add 1 to the range to make the value in the range of 1-255.
    inc     ax
    ; Store it in AH
    mov     ah,al

    ; Read a byte from the source string
    lodsb
    ; XOR that byte with the byte we got from the RNG
    xor     al,ah
    ; Store that in the result
    stosb

    pop     cx
    loop    .loop

    ; Store result length in first byte
    mov     ax,di
    mov     di,[bp+8]
    sub     ax,di
    dec     ax
    xor     ah,ah
    stosb

    mov     sp,bp
    pop     bp
    ret


.hex_to_string:
    push    bp
    mov     bp,sp

    mov     sp,bp
    pop     bp
    ret


.print_key:
    push    bp
    mov     bp,sp

    mov     sp,bp
    pop     bp
    ret
