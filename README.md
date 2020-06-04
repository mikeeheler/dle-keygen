# DLE Registration Code Generator

This program can generate registration codes for the Deluxe LORD Editor
(DLE), a 16-bit DOS program I wrote in 1995.

The Deluxe LORD Editor is a tool useful for SysOps running LORD, or
Legend of the Red Dragon, on their BBS's. It's an editor and management
tool all-in-one, with several modules:

* Player data editor
* Monster data editor
* Menu/graphics ANSI editor
* Mailer

With these tools you can punish and reward your players, either by
editing their stats directly, or sending them specially-coded mail bombs
that granted them gold or whatever. The Player Editor included an action
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
