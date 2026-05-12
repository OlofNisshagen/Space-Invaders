.equ ENEMY_HEIGHT = 6
.equ ENEMY_START_LEFT = $FF
.equ ENEMY_START_RIGHT = $80

.dseg
ENEMY:				.byte	ENEMY_HEIGHT
ENEMY_ROW:			.byte	1
ENEMY_DIRECTION:	.byte	1

.cseg
ENEMY_INIT:
	push	r16
	sts		ENEMY_ROW, r2
	sts		ENEMY_DIRECTION, r2
	ldi		r16, ENEMY_START_RIGHT
	ldi		r17, ENEMY_START_LEFT
	load_x	ENEMY
	ldi		r16, ENEMY_HEIGHT
	lsr		r16
ENEMY_INIT_LOOP:
	st		X+, r16
	st		X+, r17
	dec		r16
	brne	ENEMY_INIT_LOOP
	pop		r16
	ret

ENEMY_UPDATE:
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20

	lds		r16, TIMER_ENEMY
	tst		r16
	brne	ENEMY_EXIT

	ldi		r19, 2
	lds		r16, ENEMY_DIRECTION

	SFX 2
	
	load_x	ENEMY
	ldi		r18, ENEMY_HEIGHT
	lsr		r18

	tst		r16
	breq	RIGHT_WALL_LOOP
	adiw	X, 1
	rjmp	LEFT_WALL_LOOP

ENEMY_EXIT:
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	ret

RIGHT_WALL_LOOP:
	push	r18
	ld		r16, X
	sbrc	r16, 0
	rjmp	ENEMY_WALL_HIT
	add_x	r19
	dec		r18
	brne	RIGHT_WALL_LOOP
	pop		r18
	load_x	ENEMY
	
RIGHT_ROW_LOOP:
	ld		r16,	X+
	ld		r17, X
	lsr		r16
	bst		r17, 0
	bld		r16, 7
	lsr		r17
	st		X, r17
	st		-X, r16
	add_x	r19
	dec		r18
	brne	RIGHT_ROW_LOOP
	rjmp	WIN_CHECK

LEFT_WALL_LOOP:
	push	r18
	ld		r16, X
	sbrc	r16, 7
	rjmp	ENEMY_WALL_HIT
	add_x	r19
	dec		r18
	brne	LEFT_WALL_LOOP
	pop		r18
	load_x	ENEMY

LEFT_ROW_LOOP:
	ld		r16, X+
	ld		r17, X
	lsl		r17
	bst		r16, 7
	bld		r17, 0
	lsl		r16
	st		X, r17
	st		-X, r16
	add_x	r19
	dec		r18
	brne	LEFT_ROW_LOOP
	rjmp	WIN_CHECK



ENEMY_WALL_HIT:
	ldi		r17, 1
	lds		r16, ENEMY_DIRECTION
	eor		r16, r17
	sts		ENEMY_DIRECTION, r16 
	lds		r16, ENEMY_ROW
	inc		r16
	sts		ENEMY_ROW, r16
LOSS_CHECK:
	rcall	ENEMY_ROW_CHECK
	ldi		r18, 7
	sub		r18, r17
	sub		r18, r16
	brne	WIN_CHECK
LOSS:
	ldi		r16, 3
	rcall	STATE_INIT
	rjmp	ENEMY_EXIT

WIN_CHECK:
	rcall	ENEMY_ROW_CHECK
	tst		r17
	breq	WIN
	ret
	
WIN:
	rcall	WARM_START
	ldi		r17, 2
	sts		STATE, r17
	ret

ENEMY_ROW_CHECK:
	load_X	ENEMY 
	ldi		r17, ENEMY_HEIGHT
	add_x	r17
	lsr		r17
ENEMY_ROW_CHECK_LOOP:
	ld		r18, -X
	ld		r19, -X
	or		r18, r19
	brne	ENEMY_ROW_CHECK_EXIT
	dec		r17
	brne	ENEMY_ROW_CHECK_LOOP	
ENEMY_ROW_CHECK_EXIT:
	ret



ENEMY_DISPLAY:
	load_x	ENEMY
	ldi		r20, ENEMY_HEIGHT
	lds		r17, ENEMY_ROW
	lsl		r17
	ldi		r18, PURPLE
ENEMY_DISPLAY_LOOP:
	ld		r16, X+
	rcall	VMEM_PRINT_BYTE
	inc		r17
	dec		r20
	brne	ENEMY_DISPLAY_LOOP
	ret