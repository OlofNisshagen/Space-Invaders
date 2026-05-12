.cseg
INTERRUPT_INIT: 
	ldi		r16,(1<<WGM01) | (1<<CS02) | (0<<CS01) | (1<<CS00)
	out		TCCR0,r16  
	ldi		r16,(1<<WGM21) | (1<<CS22) | (1<<CS21) | (0<<CS20)
	out		TCCR2,r16  
	ldi		r16,5
	out		OCR0,r16 
	ldi		r16,1
	out		OCR2,r16 
	ldi		r16,(1<<OCIE2) | (1<<OCIE0)
	out		TIMSK,r16 
	ret

TIMER0_ISR: 
	push	r16 
	in		r16, SREG 
	push	r16
	push	r17
	push	r18

	rcall	DAMATRIX_ROW 
	
	pop		r18
	pop		r17
	pop		r16
	out		SREG, r16
	pop		r16
	reti

TIMER2_ISR:
	push	r16
	in		r16, SREG
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r24
	push	XL
	push	XH

	rcall	GENERATE_SOUND
	rcall	RANDOMIZE_SEED

	pop		XH
	pop		XL
	pop		r24
	pop		r21
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	out		SREG, r16
	pop		r16 
	reti 