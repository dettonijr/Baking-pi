.section .init
.globl _start
_start:
b main

.section .text
main:
mov sp, #0x8000

pinNum .req r0
pinFunc .req r1
mov pinNum, #16
mov pinFunc, #1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc


loop$:
/* Turn on LED */
mov r0, #16 @previous SetGpioFunc could have erased r0
mov r1, #0
bl SetGpio

/* Waiting */
mov r2,#0x3F0000
wait1$:
sub r2,#1
cmp r2,#0
bne wait1$

/* Turn off LED */
mov r0, #16 @previous SetGpioFunc could have erased r0
mov r1, #1
bl SetGpio

/* Waiting */
mov r2,#0x3F0000
wait2$:
sub r2,#1
cmp r2,#0
bne wait2$

b loop$           @loops forever

