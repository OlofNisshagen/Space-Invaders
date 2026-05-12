.dseg
VMEM_RED:		.byte	SCREEN_SIZE
VMEM_GREEN:		.byte	SCREEN_SIZE
VMEM_BLUE:		.byte	SCREEN_SIZE
CURRENT_ROW:	.byte	1

.cseg
VMEM_INIT:
	sts		CURRENT_ROW, r2
	ret

CLEAR_VMEM:
	load_x	VMEM_RED
	rcall	CLEAR_COLOR
	load_x	VMEM_GREEN
	rcall	CLEAR_COLOR
	load_x	VMEM_BLUE
	rcall	CLEAR_COLOR
	ret

CLEAR_COLOR:
	push	r16
	ldi		r16, SCREEN_SIZE
CLEAR_LOOP:
	st		X+, r2
	dec		r16
	brne	CLEAR_LOOP
	pop		r16
	ret

VMEM_PRINT:
	push	r19
	push	r20
	push	XL
	push	XH
	rcall	VMEM_CONVERT
	rcall	VMEM_BINARY
	rcall	VMEM_COLORS
	pop		XH
	pop		XL
	pop		r20
	pop		r19
	ret

VMEM_PRINT_BYTE:
	push	XL
	push	XH
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	
	mov		r20, r16
	rcall	VMEM_COLORS

	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	pop		XH
	pop		XL
	ret

VMEM_CONVERT:
	ldi		r20, 15
	lsl		r17
	sub		r20, r17
	cpi		r16, 8
	brsh	VMEM_CONVERT_BYTE
	rjmp	VMEM_CONVERT_EXIT
VMEM_CONVERT_BYTE:
	subi	r16, 8
	subi	r20, 1
VMEM_CONVERT_EXIT:
	mov		r17, r20
	ret

VMEM_COLORS:
	load_x	VMEM_RED
	sbrc	r18, 2
	rcall	VMEM_LOAD_COLOR

	load_x	VMEM_GREEN
	sbrc	r18, 1
	rcall VMEM_LOAD_COLOR

	load_x	VMEM_BLUE
	sbrc	r18, 0
	rcall	VMEM_LOAD_COLOR
	ret

VMEM_BINARY:
	ldi		r20, $80
	tst		r16
	breq	VMEM_BINARY_EXIT
VMEM_BINARY_LOOP:
	lsr		r20
	dec		r16
	tst		r16
	brne	VMEM_BINARY_LOOP
VMEM_BINARY_EXIT:
	ret

VMEM_LOAD_COLOR:
	push	r19
	add_x	r17
	ld		r19, X
	or		r19, r20
	st		X, r19
	pop		r19
	ret