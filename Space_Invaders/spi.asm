.equ DD_MOSI = PB5
.equ DD_SCK = PB7
.equ DDR_SPI = DDRB
.equ S_SELECT = PB4
	
.cseg
SPI_INIT:
	ldi		r17, (1<<DD_MOSI) | (1<<DD_SCK) | (1<<S_SELECT)
	out		DDR_SPI, r17
	ldi		r17, (1<<SPE) | (1<<MSTR)
	out		SPCR, r17
	ldi		r17, (1<<SPI2X)
	out		SPSR, r17
	ret

LATCH_RESET:
	cbi		PORTB, S_SELECT
	ret

LATCH:
	sbi		PORTB, S_SELECT
	ret

TRANSMIT:
	out		SPDR, r16
WAIT:
	sbis	SPSR, SPIF
	rjmp	WAIT
	cbi		SPCR, SPIE
	ret