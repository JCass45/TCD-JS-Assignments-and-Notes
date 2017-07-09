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

LEDMASK EQU 0x00260000
BUTTONMASK EQU 0x00F00000
GREEN 	EQU 0x00200000
BLUE 	EQU 0x00040000
RED 	EQU 0x00020000

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

	ldr	r1,=(14745600/200)-1	 ; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]
	
	ldr r2, =LEDMASK
	ldr r3, =IO0DIR
	str r2, [r3]
	
	ldr r2, =direction
	mov r3, #1
	str r3, [r2]
	
	ldr r2, =counterIRs
	mov r3, #50
	str r3, [r2]
	
	ldr r2, =counterLED
	mov r3, #1
	str r3, [r2]
	
polling
	
	ldr r2, =IO1PIN
	ldr r3, [r2]
	ldr r2, =BUTTONMASK
	and r3, r3, r2
		
	CMP r3, #0x00E00000
	BEQ change_dir
	
	CMP r3, #0x00D00000
	BEQ change_dir

	CMP r3, #0x00B00000
	BEQ change_dir
	
	CMP r3, #0x00700000
	BEQ change_dir
	
	b polling

	;ldr r2, =IO1PIN
	;ldr r3, [r2]
	;ldr r2, =BUTTONMASK
	;and r3, r3, r2
	
	;cmp r3, r2
	;beq polling

change_dir
	ldr r2, =direction
	ldr r3, [r2]
	eor r3, r3, #0x1		;flips the direction bit
	str r3, [r2]
	
	b polling
;from here, initialisation is finished, so it should be the main body of the main program

wloop	b	wloop  		; branch always
;main program execution will never drop below the statement above.

	AREA	InterruptStuff, CODE, READONLY
irqhan	
	sub	lr,lr,#4
	stmfd	sp!,{r0-r5,lr}	; the lr will be restored to the pc
	
	ldr r2, =LEDMASK
	
	ldr r3, =counterIRs
	ldr r4, [r3]
	
	cmp r4, #0
	bne exit
	
	ldr r3, =counterLED
	ldr r4, [r3]
	
	cmp r4, #1
	beq green
	
	cmp r4, #2
	beq blue
	
	cmp r4, #3
	beq red
	
green
	ldr r3, =direction
	ldr r5, [r3]
	cmp r5, #0
	bne greenb

	add r4, #1
	b greenl
	
greenb
	mov r4, #3
	
greenl
	ldr r3, =counterLED
	str r4, [r3]
	ldr r3, =IO0SET
	str r2, [r3]
	ldr r3, =IO0CLR
	ldr r5, =GREEN
	str r5, [r3]
	b reset50
	
blue
	ldr r3, =direction
	ldr r5, [r3]
	cmp r5, #0
	bne blueb

	add r4, #1
	b bluel
	
blueb
	sub r4, #1
	
bluel
	ldr r3, =counterLED
	str r4, [r3]
	ldr r3, =IO0SET
	str r2, [r3]
	ldr r3, =IO0CLR
	ldr r5, =BLUE
	str r5, [r3]
	b reset50
	
red
	ldr r3, =direction
	ldr r5, [r3]
	cmp r5, #0
	bne redb

	mov r4, #1
	b redl
	
redb
	sub r4, #1
	
redl
	ldr r3, =counterLED
	str r4, [r3]
	ldr r3, =IO0SET
	str r2, [r3]
	ldr r3, =IO0CLR
	ldr r5, =RED
	str r5, [r3]
	b reset50
	
exit
	sub r4, #1
	str r4, [r3]
	b skip
	
reset50
	ldr r3, =counterIRs
	mov r4, #50
	str r4, [r3]
	
skip
;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts


;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r5,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR

	AREA	Subroutines, CODE, READONLY

	AREA	Stuff, DATA, READWRITE
counterIRs	SPACE 4
counterLED	SPACE 4
direction	SPACE 4
	END