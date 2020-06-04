bits    16                      ; Hell yeah, brutha!
cpu     286                     ; Hell yeah, brutha!

; This is necessary when using NASM's BIN format and compiling to a COM
; file.
org     0100h

; Entrypoint stub. This needs to be the first code in the file.
section .text

    call    start
    mov     ax,4C00h
    int     21h


%include 'RANDOM.ASM'


section .data

bbs         db  'BBS Name'
bbs_len     equ $-bbs

sysop       db  'SysOp Name'
sysop_len   equ $-sysop


section .bss

count       resw    1
index       resw    1
tmp         resw    1

bbs_key     resb    0100h
sysop_key   resb    0100h


section .text

start:
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
    enter   0,0

    ; Seed the random number generator
    mov     ax,1935h
    push    ax
    mov     ax,0
    push    ax
    call    rng_seed

    ; zero out the memory where we're writing
    ; the key, mostly for debugging.
    mov     di,[bp+8]
    mov     al,0
    mov     cx,0100h
    rep     stosb

    ; Initialize the counter
    mov     cx,[bp+4]
    mov     [count],cx
    mov     word [index],0

    ; Initialize the registers for lodsb/stosb
    mov     si,[bp+6]
    mov     di,[bp+8]

.loop:
    ; Set the mask for the RNG. This causes it to return 0 <= N < 0xFF.
    mov     ax,00ffh
    push    ax
    call    rng_next_int
    ; Add 1 to the range to make the value in the range of 1-255.
    inc     ax
    mov     [tmp],al

    ; Read a byte from the source string
    lodsb
    ; XOR that byte with the byte we got from the RNG
    xor     al,[tmp]
    ; Store that in the result
    stosb

    ; Loop boilerplate
    inc     word [index]
    mov     ax,[count]
    cmp     ax,[index]
    jne     .loop

    leave
    retn    6
