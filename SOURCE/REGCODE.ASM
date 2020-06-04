bits    16
cpu     286
org     0100h

section .text

    call    start
    mov     ax,4C00h
    int     21h


%include 'RANDOM.ASM'


section .data

bbs         db  'BBS Name'
bbs_len     equ $-bbs

sysop       db  'Sysop Name'
sysop_len   equ $-sysop

hex         db  '0123456789ABCDEF'


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

%ifdef DEBUG
    ; zero out the memory where we're writing
    ; the key, mostly for debugging.
    mov     di,[bp+8]
    mov     al,0
    mov     cx,0100h
    rep     stosb
%endif

    mov     cx,[bp+4]
    mov     [count],cx
    mov     word [index],0

    mov     si,[bp+6]
    mov     di,[bp+8]

.loop:
    mov     ax,00ffh
    push    ax
    call    rng_next_byte
    inc     ax
    mov     [tmp],al

    lodsb
    xor     al,[tmp]
    stosb

    inc     word [index]
    mov     ax,[count]
    cmp     ax,[index]
    jne     .loop

    leave
    retn    6
