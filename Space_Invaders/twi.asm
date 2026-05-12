	.equ	TWI_BAUD_RATE = 150
	.equ	TWI_STOP_DELAY = $A4

.macro TOUT
	push	r16
	rcall	TWI_STARTBIT
	ldi		r16, @0
	lsl		r16
	out		TWDR, r16
	rcall	TWI_WAIT
	pop		r16

	mov		r16, @1
	rcall	TWI_WRITE
	rcall	TWI_STOP
.endmacro

TIN:
	push	r16
	rcall	TWI_STARTBIT
	ldi		r16, BUTTON_ADDRESS
	lsl		r16
	inc		r16
	out		TWDR, r16
	rcall	TWI_WAIT
	pop		r16
	rcall	TWI_READ
	rcall	TWI_STOP
	ret

TWI_STARTBIT:
	ldi		r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	out		TWCR, r16
	rjmp	TWCR_WAIT

TWI_STOP:
	ldi		r16, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
	out		TWCR, r16
	ldi		r16, TWI_STOP_DELAY
TWI_DELAY:
	dec		r16
	brne	TWI_DELAY
	ret

TWI_WRITE:
	out		TWDR, r16
	rjmp	TWI_WAIT 

TWI_READ:
	rcall	TWI_WAIT	
	in		r19, TWDR
	ret

TWI_WAIT:
	ldi		r16, (1<<TWINT)|(1<<TWEN)
	out		TWCR, r16
TWCR_WAIT:
	in		r16, TWCR
	sbrs	r16, TWINT
	rjmp	TWCR_WAIT
	ret

TWI_OPEN:
	ldi		r16, TWI_BAUD_RATE
	out		TWBR, r16
	clr		r16
	out		TWSR, r16
	ldi		r16, (1<<TWEN)
	out		TWCR, r16
	ret