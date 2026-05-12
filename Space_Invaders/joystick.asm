JOYSTICK_CONFIG: 
	ldi		r16, (0<< ADLAR) | (1<<REFS0) | (0<<REFS1)
	out		ADMUX,r16 
	ldi		r16, (1 << ADEN) | (1<<ADPS0) | (1<<ADPS1) | (1<<ADPS2) 
	out		ADCSRA,r16  
	ret 

JOYSTICK_CONVERT: 
	push	r16
	ldi		r16, PA2
	sbi		ADMUX, 1
	sbi		ADCSRA, ADSC
	 
CONVERT_WAIT: 
	sbic	ADCSRA, ADSC 
	rjmp	CONVERT_WAIT    
 	in		r17,ADCH 
	pop		r16
	ret 