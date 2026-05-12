.equ BUTTON_ADDRESS = $27

.dseg
PREVIOUSLY_PRESSED:	.byte	1

.cseg
CLEAR_BUTTON:
	sts		PREVIOUSLY_PRESSED, r2
	ret

GET_BUTTON:
	push	r16
	lds		r16, PREVIOUSLY_PRESSED
	rcall	TIN
	mov		r20, r19
	sts		PREVIOUSLY_PRESSED, r19
	com		r20
	add		r16, r20
	breq	GET_BUTTON_EXIT
	ldi		r19, $FF
GET_BUTTON_EXIT:
	pop		r16
	ret
