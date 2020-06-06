bits    16                      ; Hell yeah, brutha!
cpu     286                     ; Hell yeah, brutha!
global  _start
org     0100h                   ; Tell NASM where COM code is loaded


; Entrypoint stub. This needs to be the first code in the file.
section .text

_start:
    call    dlereg_main
    mov     ax,4C00h
    int     21h


%include 'COMMON\BYTE2ASC.ASM'
%include 'COMMON\RANDOM.ASM'
%include 'COMMON\PRINT.ASM'


section .data

; For printed output
sysop_name  db  'Sysop : $'
bbs_name    db  'Bbs   : $'
reg1        db  'Reg 1 : $'
reg2        db  'Reg 2 : $'


section .text

dlereg_main:
    push    bp
    mov     bp,sp

    ; allocate local stack space (384 bytes)
    ; sp-128 - key input buffer (128 bytes)
    ; sp-256 - reg code 1 (128 bytes)
    ; sp-384 - reg code 2 (128 bytes)
    sub     sp,0180h
    push    bx

.read_sysop:
    push    sysop_name
    call    print_string

    lea     ax,[bp-0080h]
    push    ax
    call    read_key_input
    call    print_newline
    add     sp,4

    cmp     byte [bp-0080h],0
    je      .read_sysop

    lea     dx,[bp-0100h]
    lea     bx,[bp-0080h]
    push    dx
    push    bx
    call    gen_key
    add     sp,4

.read_bbs:
    push    bbs_name
    call    print_string

    lea     ax,[bp-0080h]
    push    ax
    call    read_key_input
    call    print_newline
    add     sp,4

    cmp     byte [bp-0080h],0
    je      .read_bbs

    lea     dx,[bp-0180h]
    lea     bx,[bp-0080h]
    push    dx
    push    bx
    call    gen_key
    add     sp,4


    push    reg1
    call    print_string

    lea     ax,[bp-0100h]
    push    ax
    call    print_key
    call    print_newline


    push    reg2
    call    print_string

    lea     ax,[bp-0180h]
    push    ax
    call    print_key
    call    print_newline

    add     sp,8


    pop     bx
    mov     sp,bp
    pop     bp
    ret


; Read up to 7F characters from stdin
; Result will be stored at the pointer from the stack
read_key_input:
    push    bp
    mov     bp,sp
    sub     sp,082h

    push    bx
    push    di
    push    si

    lea     bx,[bp-082h]
    mov     byte [bx],080h

    ; int 21h/AX=0Ch buffered input
    ; result at [bp-0100]
    ; [0] = max characters
    ; [1] = number of characters input
    ; [2] = the characters read from the buffer
    mov     ax,0C0Ah
    mov     dx,bx
    int     21h

    mov     di,[bp+4]
    lea     si,[bp-081h]
    lodsb
    mov     cl,al
    stosb
    xor     ch,ch
    rep     movsb

    pop     si
    pop     di
    pop     bx

    mov     sp,bp
    pop     bp
    ret


; Inputs:
; bp+4 - input string
;
; Outputs:
; bp+6 - output key in binary
gen_key:
    push    bp
    mov     bp,sp
    push    di
    push    si

    ; Seed the random number generator
    push    1935h
    push    0
    call    rng_seed

    ; loop init
    mov     di,[bp+6]
    mov     si,[bp+4]
    lodsb
    mov     cl,al
    xor     ch,ch
    ; key length will be stored at index 0
    inc     di

.loop:
    push    cx

    ; Set the mask for the RNG. This causes it to return 0 <= N < 0xFF.
    push    00FFh
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
    loop    .loop

    ; Store result length in first byte
    mov     ax,di
    mov     di,[bp+6]
    sub     ax,di
    dec     ax
    xor     ah,ah
    stosb

    pop     si
    pop     di
    mov     sp,bp
    pop     bp
    ret




; Takes a binary key as input, converts it to ASCII, and prints to the
; standard output stream (STDOUT).
;
; Binary keys are stored with their length in the first byte and the
; rest in the subsequent bytes, much as strings except the data is
; binary and not encoded characters.
;
; This routine makes use of byte_to_ascii to convert each input byte to
; a 2-byte ASCII pair, which is then saved into the local stack. Once
; the conversion is complete, an ASCII '$' (0x24) is appended so that
; DOS int 21h/AH=09h will print it as a complete string to the output
; stream.
print_key:
    push    bp
    mov     bp,sp
    sub     sp,00FFh

    push    bx
    push    di
    push    si

    xor     ch,ch

    lea     bx,[bp-00FFh]
    mov     di,bx

    ; Grab the input length
    mov     si,[bp+4]
    lodsb
    mov     cl,al

.loop:
    push    cx

    lodsb
    call    byte_to_ascii
    stosw

    pop     cx
    loop    .loop

    mov     al,24h
    stosb

    mov     ax,0900h
    lea     dx,[bp-00FFh]
    int     21h

    pop     si
    pop     di
    pop     bx

    mov     sp,bp
    pop     bp
    ret
