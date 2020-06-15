# DLE Registration Code Generator

This program can generate registration codes for the Deluxe LORD Editor
(DLE), a 16-bit DOS program I wrote in 1995.

Since the source was lost, I have taken it upon myself to hack the
registration key algorithm and now provide keys freely to all those who
wish to have them.

Create keys for yourself at https://mikeeheler.github.io/dle-keygen/.

Read on for information about the program and the process of hacking it.

## About DLE

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

This repository is at once code, archive, blog post, and online key
generator.

## History

I was still in high school when I wrote this thing and very much wanted
someone to pay me for a program that I wrote, so I disabled certain
features unless the program was unlocked with a code.

Give me $5 and I'll send you a code. I made a grand total of about $15
from that scheme.

25 years later, the SysOp of Danger Bay BBS, who goes by Night Rider,
reached out to me to ask if I was still able to generate codes for the
program.

Yes, there is still very much a BBS scene out there in 2020, and I could
not be happier to have learned about it.

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
(Narrator: He wasn't.) I remember challenging a friend who said he knew
a guy that could hack anything to ask that guy to hack it.

They never took me up on it. I think they were scared. Clearly.

The registration codes are strings of hex characters that basically
map to the SysOp and BBS Name fields one-to-one. For each character
in the SysOp name, there's 2 characters in the Reg 1 code, and thusly
for BBS Name / Reg 2 as well.

The algorithm to generate a code goes like this:

* Seed the random number generator with the static value 0x1935
  (6,453 decimal).

Then, for each character in the SysOp or BBS Name field:

* Pull a psuedo-random value less than 255 from the RNG.
* Add 1.
* XOR it with the input character.
* Convert that value to a 2-character hex string (i.e. 0xAA -> "AA").

That's it. Because it's effectively a XOR with some cruft around it,
decoding the code is basically the same process:

* Seed the random number generator with the static value 0x1935
  (6,453 decimal).

Then for every two characters in the code:

* Convert the hex string to its numeric value (i.e. "AA" -> 0xAA).
* Pull a psuedo-random value less than 255 from the RNG.
* Add 1.
* XOR it with the number to make a byte.
* Add that byte to a string.

Once that's done, compare the resulting string to either the SysOp name
(for Reg 1) or the BBS Name (for Reg 2). If both match, ta-da! Product
is registered and all the annoyware is disabled.

The key to this whole thing, really, is the random number generator.
See [RANDOM.ASM][random-asm-source]. I don't know what algorithm
it uses, but it seems to depend somewhat on how 16-bit x86 instructions
handle math on 32-bit numbers.

I couldn't be arsed to convert the RNG into Javascript so the online
generator uses a [lookup table][lookup-table] of pre-generated RNG
values from the [GENRNG][genrng-asm-source] tool.

## "Hacking Protection"

I needed to find a way to stop hackers, and I knew that hackers used
tools like memory scanners to look for booleans that might map to an
"is_registered" variable, so I threw a wrench into the works.

Instead, I set a variable to a magic value:

* The unregistered, or "false" state of this variable is 0xE7CB.
* The registered, or "true" state of this variable is 0xE70D9.

I do not know the significance of these numbers, if any.

I was tempted to just edit the DLE.EXE binary to ensure the checksums
were always set to the _registered_ value, but as I thought about it, I
knew that I wanted to keep that exe intact. It was built on January
22nd, 1996 at 06:51:44 and there it has sat, unmodified. It didn't feel
right to change it now.

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
was stepping through. I'm now inspired to write some larger apps in pure
286-era assembly just to try my hand at it.

For kicks, I compiled the REGCODE program with 16-bit NASM for DOS
during development. It produced identical output using the 64-bit NASM
for Win32 but it just felt more correct to compile it in the same
context that the program would run in.

[lookup-table]: FILES/RNGTABLE.TXT
[random-asm-source]: SOURCE/COMMON/RANDOM.ASM
[genrng-asm-source]: SOURCE/GENRNG.ASM
