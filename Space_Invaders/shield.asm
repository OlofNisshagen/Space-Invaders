.equ SHIELD_TEMPLATE = 0b01100110

.dseg
SHIELD:	.byte	2

.cseg
SHIELD_INIT:
	ldi		r16, SHIELD_TEMPLATE
	load_x	SHIELD
	st		X+, r16
	st		X, r16
	ret

SHIELD_DISPLAY:
	push	r16
	push	r17
	push	r18

	load_X	SHIELD
	ldi		r18, GREEN

	ld		r16, X+
	ldi		r17, 13
	rcall	VMEM_PRINT_BYTE
	ld		r16, X
	ldi		r17, 12
	rcall	VMEM_PRINT_BYTE
	
	pop		r18
	pop		r17
	pop		r16
	ret