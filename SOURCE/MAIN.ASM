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

; For printed output
sysop_name  db  'Sysop : $'
bbs_name    db  'Bbs   : $'
reg1        db  'Reg 1 : $'
reg2        db  'Reg 2 : $'

; For the hex string conversion
hex         db  '0123456789ABCDEF'

section .text

main:
    push    bp
    mov     bp,sp
    ; Reserve 2 strings on the stack
    ; 1 byte for length and 256 bytes for content
    sub     sp,0202h

    ; locals: sysop_key [bp-0101h], bbs_key [bp-0202h]


    lea     ax,[bp-0101h]
    push    ax
    push    sysop
    push    sysop_len
    call    .gen_key


    lea     ax,[bp-0202h]
    push    ax
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

    lea     ax,[bp-0101h]
    push    ax
    call    .print_key
    call    print_newline


    push    reg2
    call    print_string

    lea     ax,[bp-0202h]
    push    ax
    call    .print_key
    call    print_newline


    mov     sp,bp
    pop     bp
    ret


; Inputs:
; bp+6 - input string
; bp+4 - input string length
;
; Outputs:
; bp+8 - output key in binary
.gen_key:
    push    bp
    mov     bp,sp
    push    di
    push    si

    ; Seed the random number generator
    mov     ax,1935h
    mov     dx,0
    push    ax
    push    dx
    call    rng_seed

    ; initialize the memory where we're writing the key, mostly for
    ; debugging.
    mov     di,[bp+8]
    mov     ax,0xBE00
    stosw
    mov     ax,0xBEEF
    mov     cx,0x7F
    rep     stosw

    ; loop init
    mov     cx,[bp+4]
    mov     si,[bp+6]
    mov     di,[bp+8]
    ; key length will be stored at index 0
    inc     di

.gen_key.loop:
    push    cx

    ; Set the mask for the RNG. This causes it to return 0 <= N < 0xFF.
    mov     ax,00FFh
    push    ax
    call    rng_next_int
    pop     dx

    ; Add 1 to the range to put the value in the range of 1-255.
    inc     ax
    mov     ah,al               ; Store it in AH

    ; Read an input byte, XOR the result with the RNG byte, and write it
    ; to the output.
    ; "Encryption," ladies and gentlemen.
    lodsb
    xor     al,ah
    stosb

    pop     cx
    loop    .gen_key.loop

    ; Store result length in first byte
    mov     ax,di
    mov     di,[bp+8]
    sub     ax,di
    dec     ax
    xor     ah,ah
    stosb

    pop     si
    pop     di
    mov     sp,bp
    pop     bp
    ret


.byte_to_ascii:
    push    si

    xor     ch,ch
    xor     dh,dh

    mov     dl,al
    and     dl,0xF0
    shr     dl,4

    mov     cl,al
    and     cl,0x0F

    mov     si,hex
    add     si,dx
    lodsb
    mov     ah,al

    mov     si,hex
    add     si,cx
    lodsb

    xchg    ah,al

    pop     si
    ret


.print_key:
    push    bp
    mov     bp,sp
    sub     sp,0201h

    push    di
    push    si

    lea     ax,[bp-0201h]
    mov     di,ax

    mov     si,[bp+4]
    lodsb
    mov     cl,al
    xor     ch,ch
.print_key.loop:
    push    cx

    lodsb
    call    .byte_to_ascii
    mov     dx,ax
    mov     ax,0200h
    int     21h
    xchg    dl,dh
    int     21h

    pop     cx
    loop    .print_key.loop

    pop     si
    pop     di

    mov     sp,bp
    pop     bp
    ret
