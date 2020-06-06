# Development

This document is just a place to keep notes on working on this thing.

## Requirements

* DOSBox -- [0.74.3][dosbox-download] is known to work
* [NASM][nasm] -- [2.14.02][nasm-download] is known to work
* (Recommended) A debug-enabled build of DOSBox (download [here][dosbox-debug])

## Building

NASM for any platform will work to build the assembly into a .COM file
that can be run in DOSBox. This includes the DOS build of NASM, which
was used while building this tool.

From the root of the project, run this command:

    NASM SOURCE\MAIN.ASM -ISOURCE -fbin -O0 -o BIN\DLEREG.COM

As a convenience, `BUILD.BAT` is included to build the tool from a
DOSBox session.

## Debugging

In a debug-enabled build of DOSBox, run

    DEBUG BIN\DLEREG.COM

Or just run `DEBUG.BAT`, which assumes that NASM is in the system path.

This is a pretty raw debugging session. There are no symbols or links to
the source. Just pure assembly.

## Conventions

### Strings

None of the data in this thing is expected to exceed 255 bytes, so
strings use the pascal convention: a single byte at the front stores
the string length, following by the characters (assumed to map to code
page 437).

### Function Calls

The original DLE code was written in Turbo Pascal and thus was compiled
to use the [pascal][x86cc-pascal] calling convention.

Since this project is pure assembly that doesn't interface with any
external APIs, it's free to use any convention. To that end, conventions
are helpful for consistency and it uses the [cdecl][x86cc-cdecl]
convention.

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

[dosbox-download]: <https://www.dosbox.com/download.php?main=1> (Download DOSBox)
[dosbox-debug]: <https://www.vogons.org/viewtopic.php?t=7323> (Download DOSBox Debug Build)
[nasm]: <https://www.nasm.us/> (Netwide Assembler)
[nasm-download]: <https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/> (Download NASM)
[x86cc-pascal]: <https://en.wikipedia.org/wiki/X86_calling_conventions#pascal> (Pascal Calling Convention)
[x86cc-cdecl]: <https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl> (CDECL Calling Convention)
