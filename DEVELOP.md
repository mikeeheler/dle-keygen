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
* Argument push order is meaningless in pure assembly. Just put stuff on
  the stack where the called function expects them.

[1]: https://en.wikipedia.org/wiki/X86_calling_conventions#pascal
[2]: https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl
