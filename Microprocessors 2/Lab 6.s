; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010
	
IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

PINSEL1 EQU 0xE002C004
DACREG  EQU 0XE006C000
DACWRITEMASK EQU 0xFFFF003F

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2014–2016.

	EXPORT	start
start
; initialisation code

; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/44052)-1	 ; frequency of timed interrupts i.e interrupt every X seconds
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]
	
; Initialise the DAC
	ldr r0, =PINSEL1
	mov r2, #0x00080000 ; Ensure we set bit 19 and clear bit 18 in the PINSEL1 reg to turn DAC on
	str r2, [r0]
	
	ldr r0, =DACREG
	mov r2, #0x00000000 ; Ensure bit 16 is cleared to give a 1us settle time
	str r2, [r0]
; Initialise the IndexCounter
reset
	ldr r0, =IndexCounter
	mov r1, #1
	str r1, [r0]
	ldr r10, =SamplingVals
	
while
	ldr r0, =IndexCounter
	ldr r1, [r0] ; Prev index counter
	ldr r2, [r0] ; Current index counter 
	mov r3, #100
	cmp r2, r3
	bhi reset
	cmp r1, r2
	beq while ; While Current index and previous index are the same
	
	ldr r4, [r10], #4 ; Move along the array (4 bytes because each array index occupies 4 bytes of space)
	lsl r4, #6 ; Line up Sampling Values with bits 15:6 of the DAC register
	
	ldr r5, =DACREG
	ldr r6, [r5]
	ldr r7, =DACWRITEMASK
	and r6, r7 ; Clear bits 15:6
	str r6, [r5]
	str r4, [r5] ; Set bits 15:6
	
	ldr r0, =IndexCounter
	ldr r1, [r0]
	ldr r2, [r0]
	
	b while

;from here, initialisation is finished, so it should be the main body of the main program

wloop	b	wloop  		; branch always
;main program execution will never drop below the statement above.
	AREA	Stuff, CODE, READWRITE
IndexCounter 	DCB 	1	
SamplingVals	DCD		0x0, 0x26, 0x4c, 0x72, 0x97, 0xbb, 0xde, 0x100, 0x120, 0x13e, 0x15b, 0x175, 0x18e, 0x1a4, 0x1b7, 0x1c8, 0x1d7, 0x1e2, 0x1eb, 0x1f0, 0x1f3, 0x1f3, 0x1f0, 0x1ea, 0x1e1, 0x1d5, 0x1c7, 0x1b6, 0x1a2, 0x18c, 0x173, 0x158, 0x13c, 0x11d, 0xfd, 0xdb, 0xb8, 0x93, 0x6e, 0x49, 0x22, 0xfffffffd, 0xffffffd7, 0xffffffb1, 0xffffff8b, 0xffffff66, 0xffffff42, 0xffffff1f, 0xfffffefd, 0xfffffedd, 0xfffffebf, 0xfffffea3, 0xfffffe88, 0xfffffe70, 0xfffffe5a, 0xfffffe47, 0xfffffe36, 0xfffffe28, 0xfffffe1d, 0xfffffe15, 0xfffffe0f, 0xfffffe0d, 0xfffffe0d, 0xfffffe10, 0xfffffe17, 0xfffffe20, 0xfffffe2c, 0xfffffe3b, 0xfffffe4c, 0xfffffe60, 0xfffffe76, 0xfffffe8f, 0xfffffeaa, 0xfffffec7, 0xfffffee6, 0xffffff06, 0xffffff28, 0xffffff4c, 0xffffff70, 0xffffff95, 0xffffffbb, 0xffffffe1, 0x6, 0x2d, 0x53, 0x78, 0x9d, 0xc1, 0xe4, 0x105, 0x125, 0x144, 0x160, 0x17a, 0x192, 0x1a8, 0x1bb, 0x1cb, 0x1d9, 0x1e4
		
	AREA	InterruptStuff, CODE, READONLY
irqhan
	sub	lr,lr,#4
	stmfd	sp!,{r0-r8,lr}	; the lr will be restored to the pc
;this is the body of the interrupt handler
; just increment the IndexCounter and exit
	ldr r0, =IndexCounter
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]
;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r8,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR

	AREA	Subroutines, CODE, READONLY
		
	END