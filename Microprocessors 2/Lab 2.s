	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011.

	EXPORT	start
start

IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

IO1PIN 	EQU 0xE0028010
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
		
		ldr r7, =0x00F00000  ; button mask
		ldr r6, =0x00260000	 ;LED mask

		ldr	r11,=IO0DIR
		ldr	r2,=0x00260000	 ;P1.17, P1.18, P1.21,
		str	r2,[r11]		;make them outputs
		ldr	r1,=IO0CLR
		str	r2,[r1]		;clr them to turn the LEDs on
		ldr	r2,=IO0SET
		ldr	R10,=IO1PIN
; r1 points to the CLEAR register
; r2 points to the SET register

;resetoutput
polling
		
		
		ldr R4, [R10]
		AND R5, R7, R4
		
		CMP R5, #0x00E00000
		BEQ if1_20
		
		CMP R5, #0x00D00000
		BEQ if1_21
		
		CMP R5, #0x00B00000
		BEQ if1_22
		
		CMP R5, #0x00700000
		BEQ if1_23
		
		CMP R5, #0x00F00000
		BEQ if_none
		
		B	more_than_1
if1_20
		
		str r6, [r2]
		ldr r9, =0x00200000
		str r9, [r1] 	;R1 is the clear register, turn the green led on	
		B polling
if1_21
		
		str r6, [r2]
		ldr r9, =0x00040000
		str r9, [r1] 	;R1 is the clear register, turn the blue led on
		B polling
if1_22
		
		str r6, [r2]
		ldr r9, =0x00020000
		str r9, [r1] 	;R1 is the clear register, turn the red led on
		B polling
if1_23	
	
		str r6, [r2]
		ldr r9, =0x00240000
		str r9, [r1] 	;R1 is the clear register, turn the led to cyan
		B polling
if_none		
		ldr r6, =0x00260000 ; flip back to output
		str r6, [r11]
		str r6, [r2]
		ldr r9, =0x00260000
		str r9, [r1] 	;R1 is the clear register, turn the white led on
		B polling
		
more_than_1
		ldr r6, =0x00000000
		str r6, [r11]
		B polling



		
		

	




		;str r6, [r2]
		
		
		;;
		;str r6, [r1]		
		;ldr	r4,=16000000
;dloop0	subs	r4,r4,#1
		;bne	dloop0
		
		
;main_loop		
		;;Turning on the green LED
		;ldr r9, =0x00200000
		;str r9, [r1] 	;R1 is the clear register, turn the green led on
		
		;ldr	r4,=8000000
;dloop1	subs	r4,r4,#1
		;bne	dloop1
		
		;str r9, [r2]	;r2 is the set register, turn green led off
		
		;;Turning on the blue LED
		;ldr r9, =0x00040000
		;str r9, [r1]
		
		;ldr	r4,=8000000
;dloop2	subs	r4,r4,#1
		;bne	dloop2
		
		;str r9, [r2]
		
		;;Turning on the red LED
		;ldr r9, =0x00020000
		;str r9, [r1]
		
		;ldr	r4,=8000000
;dloop3	subs	r4,r4,#1
		;bne	dloop3
		
		;str r9, [r2]

		;B main_loop
		
		
		
stop	B	stop


	END
