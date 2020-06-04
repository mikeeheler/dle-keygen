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


section .data

bbs         db  'BBS Name'
bbs_len     equ $-bbs

sysop       db  'SysOp Name'
sysop_len   equ $-sysop


section .bss

bbs_key     resb    0100h
sysop_key   resb    0100h


section .text

main:
    push    sysop_key
    push    sysop
    push    sysop_len
    call    .gen_key

    push    bbs_key
    push    bbs
    push    bbs_len
    call    .gen_key

    retn


.gen_key:
    ; Inputs:
    ; bp+6 - input string
    ; bp+4 - input string length
    ;
    ; Outputs:
    ; bp+8 - output string
    enter   0,0

    ; Seed the random number generator
    mov     ax,1935h
    mov     dx,0
    push    ax
    push    dx
    call    rng_seed

    ; zero out the memory where we're writing the key, mostly for
    ; debugging.
    mov     di,[bp+8]
    mov     ax,0
    mov     cx,0080h
    rep     stosw

    ; loop init
    mov     cx,[bp+4]
    mov     si,[bp+6]
    mov     di,[bp+8]

.loop:
    push    cx

    ; Set the mask for the RNG. This causes it to return 0 <= N < 0xFF.
    mov     ax,00FFh
    push    ax
    call    rng_next_int
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

    leave
    retn    6
