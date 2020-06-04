# DLE Registration Code Generator

This program can generate registration codes for the Deluxe LORD Editor
(DLE), a 16-bit DOS program I wrote in 1995.

The Deluxe LORD Editor is a tool useful for SysOps running LORD
(Legend of the Red Dragon) on their BBS'. It's an editor and management
tool all-in-one, with several modules:

* Player data editor
* Monster data editor
* Menu/graphics ANSI editor
* Mailer

With these tools you can punish and reward your players, either by
editing their stats directly, or sending them specially-coded mail bombs
that granted them gold or whatever. The Player Editor includes an action
to "reset" a player so it was as if a day had passed and they could play
another set of turns. Very handy for a SysOp.

You could also use these to mod the game. While the core game loop could
not change, by changing the monster names and menus/screens/graphics, it
could certainly set the game in a different era or genre, or simply give
it a new flavour.

## History

I was still in high school when I wrote this thing and very much wanted
someone to pay me for a program that I wrote, so I disabled certain
features unless the program was unlocked with a code.

Give me $5 and I'll send you a code. I made a grand total of about $15
from that scheme.

25 years later, the SysOp of Danger Bay BBS, who goes by nIGHt rIDer,
reached out to me to ask if I was still able to generate codes for the
program.

Yes, there is still very much a BBS scene out there in 2020, and I
could not be happier to have learned about it.

The source to DLE is long lost, but I saw a puzzle ready to be solved;
I would hack the damn thing myself.

So that's what I've done. I grabbed a debug build of DOSbox, loaded DLE
into the debugger and began stepping through, one instruction at a time.

I mapped out code segments, function calls, memory regions. I found the
region of memory where the text "Unregistered" was stored, and from
there, the code to print it, the check for whether you were registered,
and, ultimately, the registration code validation. It was glorious.

## "Encryption"

My 16-year-old self thought he was pretty clever to come up with this.
I remember challenging a friend who said he knew a guy that could hack
anything to ask that guy to hack it.

They never took me up on it. I think they were scared.

The registration codes are strings of hex characters that basically
map to the SysOp and BBS Name fields one-to-one. For each character
in the SysOp name, there's 2 characters in the Reg 1 code, and thusly
for BBS Name / Reg 2 as well.

The algorithm to generate a code goes like this:

* Seed the random number generator with the static value 0x1935
  (6,453 decimal).

Then, for each character in the SysOp or BBS Name field:

* Pull a psuedo-random value from the RNG with a max value of 0xfe.
* Add 1.
* XOR it with the input character.
* Convert that value to a 2-character hex string (i.e. 0xAA -> "AA").

That's it. Because it's effectively a XOR with some cruft around it,
decoding the code is basically the same process:

* Seed the random number generator with the static value 0x1935
  (6,453 decimal).

Then for every two characters in the code:

* Convert the hex string to its numeric value (i.e. "AA" -> 0xAA).
* Pull a pseudo-random value from the RNG with a max value of 0xfe.
* Add 1.
* XOR it with the number to make a byte.
* Add that byte to a string.

Once that's done, compare the resulting string to either the SysOp name
(for Reg 1) or the BBS Name (for Reg 2). If both match, ta-da! Product
is registered and all the annoyware is disabled.

The key to this whole thing, really, is the random number generator.
See [RANDOM.ASM](SOURCE/RANDOM.ASM). I don't know what algorithm it
uses.

## "Hacking Protection"

I needed to find a way to stop hackers, and I knew that hackers used
tools like memory scanners to look for booleans that might map to an
"is_registered" variable, so I threw a wrench into the works.

Instead, I set a variable to a magic value:

* The unregistered, or "false" state of this variable is 0xE7CB.
* The registered, or "true" state of this variable is 0xE70D9.

I do not know the significance of these numbers, if any.

## Learnings

Going in I had only written or even debugged a minimal amount of
assembly, and everything I had written was usually just little snippets
inlined next to C or Pascal for executing a specific interrupt or
something like that.

That much was quite educational! I'd highly recommend anyone getting
into assembly to start at an earlier level of technology: code for a
16-bit 286 in real mode with 640kb of RAM.

It's one thing to step through existing code and make sense of it (with
the Intel x86 Architecture Guide in hand), and another thing entirely to
write code that executes. I'm still very much learning how to write NASM
code, and most of what I've written just looks like the machine code I
was stepping through.

For kicks, I compiled the REGCODE program with 16-bit NASM for DOS. It
produced identical output using the 64-bit NASM for Win32 but it just
felt more correct to compile it in the same context that the program
would run in.

## Future Work

Right now the only way to get a reg key out of this thing is to open it
in the DOSbox debugger, set a breakpoint on the return from `start`, and
copy the data from the memory display. That data will still be in byte
form (i.e. `0x34 0x57 0xA5 0x18 0x83`) so it needs to be written down by
hand in string form (`"3457A51883"`).

So, next steps might be to do that string conversion and print it out,
and maybe read the SysOp/BBS name from the console or DLE.CFG.

It could also write the codes directly into DLE.CFG.

As I pour more code into it -- I/O, screen printing, other things -- I'd
like to organize the code into more files and thus might look into
targeting an EXE instead. I've read that it _can_ be done by hand-coding
the EXE header in the .data section but it makes more sense to me to
just generate a Makefile and link it with GCC or something like that. I
would like to find a linker that generates original DOS headers though.
DLE.EXE's metadata header is just 28 bytes followed by a rather large
(relatively speaking) relocation table. Modern linkers, I think, are
more likely to generate larger headers and I'd like to avoid that.
