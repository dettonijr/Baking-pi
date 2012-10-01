/*
 * GPIO controller map
 * Base address = 0x20200000
 * 00 - 24: Function select
 * 28 - 36: Turn on pin
 * 40 - 48: Turn off pin
 * 52 - 60: Pin input
*/

/*
 * Return gpio address on r0
 *  void* GetGpioAddress()
 */
.globl GetGpioAddress
GetGpioAddress:
ldr r0, =0x20200000   
mov pc, lr

/*
 * Set GPIO pin to specified function
 *  void SetGpioFunction(int pin, int func)
 * 0 <= pin <= 53
 * 0 <= func <= 7
 */
.globl SetGpioFunction
SetGpioFunction:
/* Verifying if the values are in the correct range */
cmp r0,#53
cmpls r1,#7         @executes this only if r0 <= 53
movhi pc, lr        @return if r1 > 7 or r0 > 53

/* In case the values are correct: */
push {lr}           @saves lr
mov r2, r0          @saves r0
bl GetGpioAddress   @r0 = GetGpioAddres()

/* r0 += (r2/10)*4 
 * r2 = r2%10
 * OR
 * r0 = GPIO + 4*(pin/10)
 * r2 = i'th pin of the group of 10 pins.
 */
functionLoop$:
    cmp r2, #9
    subhi r2, #10
    addhi r0, #4
    bhi functionLoop$

add r2, r2, lsl#1   @r2 *= 3; #compute the position of the pin. 3 bits for pin
lsl r1, r2          @r1 = r1 << r2; #Put the code at the right position
str r1,[r0]         @store the code on GpioAddress
pop {pc}            @return
/* Warning: This function overwrite the previous code of the remaining pins */
/*TODO: FIX IT*/


/*
 * Set GPIO pin on/off
 *  void SetGpio(int pinNum, int pinVal)
 * 0 <= pinNum <= 53
 * pinVal zero or non-zero
 */
.globl SetGpio
SetGpio:
pinNum .req r0
pinVal .req r1

cmp pinNum,#53
movhi pc,lr         @return if pinNum > 53

push {lr}           @saves lr
mov r2, pinNum      @saves pinNum on r2
.unreq pinNum
pinNum .req r2 
bl GetGpioAddress    @put GpioAdd in r0
gpioAddr .req r0

pinBank .req r3
lsr pinBank, pinNum, #5 @pinBank = pinNum/32
lsl pinBank, #2         @compute offset of pinBank (each bank has 4 bytes)
add gpioAddr, pinBank   @add offset to gpioaddr
.unreq pinBank

and pinNum, #31         @pinNum %= 32
setBit .req r3
mov setBit, #1
lsl setBit, pinNum      @setBit = 1<<pinNum
.unreq pinNum

teq pinVal, #0          @test equality between pinVal and 0
.unreq pinVal
streq setBit, [gpioAddr,#40]    @store here if pinVal == 0
strne setBit, [gpioAddr,#28]    @if pinVal != 0 (refer controller address map)
.unreq setBit
.unreq gpioAddr
pop {pc}    @return
