/*
 * GPIO controller map
 * Base address = 0x20200000
 * 00 - 24: Function select
 * 28 - 36: Turn on pin
 * 40 - 48: Turn off pin
 * 52 - 60: Pin input
*/

.section .init
.globl _start
_start:
ldr r0,=0x20200000  @GPIO controller address 
/* This block of code enable output mode on 16th pin */
mov r1,#1           
lsl r1,#18          @ r1 = 2<<18 #3 bits/pin, we want the 6th pin.
str r1,[r0,#4]      @ sets the 18th bit on 0x20200004

mov r1,#1
lsl r1,#16

loop$:
str r1,[r0,#40]     @sets the turn-off bit of 16th pin

/* Waiting */
mov r2,#0x3F0000
wait1$:
sub r2,#1
cmp r2,#0
bne wait1$

str r1,[r0,#28]     @sets the turn-on bit of 16th pin

/* Waiting */
mov r2,#0x3F0000
wait2$:
sub r2,#1
cmp r2,#0
bne wait2$

b loop$           @loops forever

