.equ switches, 0x00003010
.equ leds, 0x00003000
.global _start
_start: movia r2, switches
movia r3, leds
LOOP: ldbio r4, 0(r2)
stbio r4, 0(r3)
br LOOP
.end