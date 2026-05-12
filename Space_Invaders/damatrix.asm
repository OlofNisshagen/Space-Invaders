.cseg
DAMATRIX_ROW:
	lds		r17, CURRENT_ROW
	rcall	DISPLAY_ROW
	inc		r17
	rcall	DISPLAY_ROW
	inc		r17
	rcall	LATCH
	rcall	LATCH_RESET
	cpi		r17, SCREEN_SIZE
	brlo	DAMATRIX_EXIT
	clr		r17
DAMATRIX_EXIT:
	sts		CURRENT_ROW, r17
	ret

DISPLAY_ROW:
	LOAD_X	VMEM_BLUE
	rcall	DISPLAY_SEND
	LOAD_X	VMEM_GREEN
	rcall	DISPLAY_SEND
	LOAD_X	VMEM_RED
	rcall	DISPLAY_SEND

	rcall	CONVERT_ROW
	rcall	TRANSMIT
	ret

DISPLAY_SEND:
	ADD_X	r17
	ld		r16, X
	rcall	TRANSMIT
	ret

CONVERT_ROW:
	push	r17
	ldi		r16, 1
	lsr		r17
	tst		r17
	breq	CONVERT_EXIT
CONVERT_LOOP:
	lsl		r16
	dec		r17
	brne	CONVERT_LOOP
CONVERT_EXIT:
	com		r16
	pop		r17
	ret