	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011.

	EXPORT	start
start

IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

		ldr	r1,=IO0DIR
		ldr	r2,=0x00C0B700	;select P1.8-P1.10, P1.12, P1.13, P1.15, P1.21, P1.22
		str	r2,[r1]		;make them outputs
		ldr	r1,=IO0CLR
		str	r2,[r1]		;clr them to turn the LEDs off
		ldr	r2,=IO0SET
; r1 points to the CLEAR register
; r2 points to the SET register

	
		ldr r6,=0x00C0B700	;bit mask
		ldr	r5,=0x403100	; loop back when we get to 'F'
		
floop	ldr r10, =Numbers ; Pointer to data we want to display on 7-seg in memory

wloop	ldr r0, [r10], #4
		str	r0,[r2]	   	; set the bits -> turn on the segments decided by the value in r0

; delay for a while
		ldr	r4,=8000000
dloop	subs	r4,r4,#1
		bne	dloop

		str	r6,[r1]		;clear the bits -> return everything to off

		cmp	r0,r5
		bne	wloop		; not yet reached 'F'
		b	floop		; reached 'F', reset to '0'
		
stop	B	stop

	AREA 	Data, CODE, READONLY
Numbers DCD  0x803700, 0x0600, 0xC01300, 0xC00700, 0x402600, 0xC02500, 0xC03500, 0x0700, 0xC03700, 0x402700, 0x403700, 0xC03400, 0x803100, 0xC01600, 0xC03100, 0x403100
	END