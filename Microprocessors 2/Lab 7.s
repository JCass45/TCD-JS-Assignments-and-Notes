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

IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

IO1PIN 	EQU 0xE0028010
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2014–2016.

	EXPORT	start
start
; initialisation stacks
	ldr r0, =STACKMEM1
	ldr r1, =TOPST1
	add r0, #0x190
	str r0, [r1]
	
	ldr r0, =STACKMEM2
	ldr r1, =TOPST2
	add r0, #0x190
	str r0, [r1]
	
	mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	
	ldr r11, =TOPST1
	ldr r12, [r11]
	ldr r11, =program1
	
	ldr r11, =TOPST2
	ldr r12, [r11]
	ldr r11, =program2
	
	stmfd r12!,{r0-r11}^
	
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

	;ldr	r1,=(14745600/200)-1	 ; 5 ms = 1/200 second
	ldr	r1,=(14745600 * 2)-1	 ; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]
	
	; current process running set to program 1
	ldr r0, =ProcessID
	mov r1, #1
	str r1, [r0]
	
	b program1

endmain	b endmain

	AREA	InterruptStuff, CODE, READONLY
irqhan
; IMPORTANT that we don't use R10 - R12 in either of the programs
	ldr r11, =ProcessID
	ldr r12, [r11]
	cmp r12, #1
	beq proc1
	cmp r12, #2
	beq proc2
	b endmain ; Should never happen 
	
proc1
	mov r12, #2
	str r12, [r11] ; Update ProcessID
	
	sub	lr,lr,#4
	ldr r11, =TOPST1
	ldr r12, [r11]
	stmfd	r12!,{r0-r10,lr}	; save the environment of process 1
	str r12, [r11]	; Store the head of stack1
	
	ldr r12, =TOPST2	; Need to check if stack 2 is empty (ie no environment to restore)
	ldr r11, [r12]
	ldr r10, =STACKMEM2
	sub r11, #0x190
	cmp r10, r11	; Compare top of stack and bottom of stack address, if the same the stack is empty
	add r11, #0x190
	
	ldr r0, =STACKMEM2
	ldr r1, =TOPST2
	str r0, [r1]
	
	bne exit	
	b emptystack2

proc2
	mov r12, #1
	str r12, [r11] ; Update ProcessID

	sub	lr,lr,#4
	ldr r11, =TOPST2
	ldr r12, [r11]
	stmfd	r12!,{r0-r10,lr}	; save the environment of process 2
	str r12, [r11]
	
	ldr r12, =TOPST1	; Need to check if stack 1 is empty (ie no environment to restore)
	ldr r11, [r12]	; r11 has address of top of stack
	ldr r10, =STACKMEM1	; r10 has address of bottom of stack
	sub r11, #0x190
	cmp r10, r11	; Compare top of stack and bottom of stack address, if the same the stack is empty
	add r11, #0x190
	
	ldr r0, =STACKMEM1
	ldr r1, =TOPST1
	str r0, [r1]
	
	bne exit
	b emptystack1

exit
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC
	ldmfd	r11!,{r0-r10,pc}^	; load environment from top of stack1/2
	

emptystack2
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC
	
	b program2
	
emptystack1
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC
	
	b program1
	
;@-------------End of Interrupt Handler-----------@


	AREA	Subroutines, CODE, READONLY
;@------ Turns on the Green LED----------------@
program1
	ldr	r3,=IO0DIR
	ldr	r2,=0x00260000	 ;P1.17, P1.18, P1.21,
	str	r2,[r3]		;make them outputs
	ldr	r1,=IO0SET
	str	r2,[r1]		; turn everything off
	ldr	r3,=IO0CLR
	
	ldr r4, =0x00200000
	str r4, [r3]
	b program1
;@------ End of program 1----------------@

;@------ Turns on the Blue and Red LEDS----------------@
program2
	ldr	r3,=IO0DIR
	ldr	r2,=0x00260000	 ;P1.17, P1.18, P1.21,
	str	r2,[r3]		;make them outputs
	ldr	r1,=IO0SET
	str	r2,[r1]		;turn everything off
	ldr	r3,=IO0CLR
	
	ldr r4, =0x00060000
	str r4, [r3]
	b program2
		
;@------ End of program 2----------------@

	AREA	Stuff, DATA, READWRITE
STACKMEM1 	SPACE 400
TOPST1	 	SPACE 4

STACKMEM2 	SPACE 400
TOPST2		SPACE 4

ProcessID 	DCD 1
	END