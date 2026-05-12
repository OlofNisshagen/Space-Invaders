.equ ENEMY_BULLET_AMOUNT = 2

.dseg
ENEMY_BULLET_X:	.byte	ENEMY_BULLET_AMOUNT
ENEMY_BULLET_Y:	.byte	ENEMY_BULLET_AMOUNT

.cseg 
RESET_ENEMY_BULLETS: 
	ldi		r16, ENEMY_BULLET_AMOUNT
	LOAD_X	ENEMY_BULLET_X
	LOAD_Y	ENEMY_BULLET_Y
	ldi		r19, 1
ENEMY_BULLET_RESET_LOOP:
	rcall	RESET_ENEMY_BULLET
	add_x	r19
	add_y	r19
	dec		r16
	brne	ENEMY_BULLET_RESET_LOOP 
	ret  	

RESET_ENEMY_BULLET:
	push	r17
	ldi		r17,7
	st		X, r17
	st		Y, r17
	pop		r17
	ret

ENEMY_BULLET_UPDATE: 
	push	r16
	push	r17
	push	r18
	push	r20
	push	XL
	push	XH
	push	YL
	push	YH

	ldi		r18, ENEMY_BULLET_AMOUNT 
	ldi		r20, 1
	clr		r21
	LOAD_X	ENEMY_BULLET_X
	LOAD_Y	ENEMY_BULLET_Y

FIND_ENEMY_BULLETS_LOOP:  
	ld		r16, X
	ld		r17, Y  
	call	ENEMY_BULLET
	add_x	r20
	add_y	r20
	dec		r18
	brne	FIND_ENEMY_BULLETS_LOOP
	rjmp	ENEMY_BULLET_UPDATE_EXIT

ENEMY_BULLET:
	cpi		r17, 7
	brne	ACTIVE_BULLET
	breq	INACTIVE_BULLET
	
ACTIVE_BULLET:
	push	r16
	tst		r17
	brne	ACTIVE_BULLET_UPDATE
	rcall	RESET_ENEMY_BULLET
	rjmp	ACTIVE_BULLET_EXIT
ACTIVE_BULLET_UPDATE:
	dec		r17 
	st		Y, r17
	call	ENEMY_BULLET_COLLISIONS
ACTIVE_BULLET_EXIT:
	pop		r16
	ret

INACTIVE_BULLET:
	push	r16
	push	r17
	push	r18

	tst		r21
	brne	INACTIVE_BULLET_EXIT

	inc		r21
	rcall	GET_RANDOM_16
	push	r16

	rcall	NORMALIZE_PLAYER_BULLET 
	rcall	CONVERT_TO_BINARY
	
CHECK_ENEMY_ON_ROW:
	push	XL
	push	XH
	LOAD_X	ENEMY
	ldi		r23, ENEMY_HEIGHT
	subi	r23, 1
	sub		r23, r18
	ADD_X	r23
	ldi		r19, ENEMY_HEIGHT
	lsr		r19

CHECK_ENEMY_ON_ROW_LOOP:
	ld		r17, X
	and		r17, r16
	tst		r17
	brne	CHECK_ENEMY_ON_ROW_VALID
	subi	XL, 2
	sbc		XH, r2
	dec		r19
	brne	CHECK_ENEMY_ON_ROW_LOOP
CHECK_ENEMY_ON_ROW_VALID:
	pop		XH
	pop		XL
	pop		r16
	tst		r19
	breq	INACTIVE_BULLET_EXIT
ENEMY_BULLET_SHOOT:
	st		X, r16
	ldi		r17, 7
	ldi		r18, ENEMY_HEIGHT
	lsr		r18
	sub		r17, r18
	sub		r18, r19
	add		r17, r18
	lds		r18, ENEMY_ROW
	sub		r17, r18
	st		Y, r17
INACTIVE_BULLET_EXIT:
	pop		r18
	pop		r17
	pop		r16
	ret


ENEMY_BULLET_UPDATE_EXIT:
	pop		YH
	pop		YL
	pop		XH
	pop		XL
	pop		r20
	pop		r18
	pop		r17
	pop		r16
	ret

ENEMY_BULLET_COLLISIONS:  
	rjmp	ENEMY_BULLET_COLLISION_PLAYER 
ENEMY_BULLET_COLLISION_CONT:
	pop		r18
	rjmp	ENEMY_BULLET_COLLISION_BARRIER
ENEMY_BULLET_COLLISION_EXIT:
	ret

ENEMY_BULLET_COLLISION_PLAYER:
	push	r18
	lds		r18, PLAYER_X
	cpi		r17, 0		;kolla ifall samma rad som spelaren
	brne	ENEMY_BULLET_COLLISION_CONT
	cp		r16, r18
	brne	ENEMY_BULLET_COLLISION_CONT

PLAYER_HIT: 
	rcall	RESET_ENEMY_BULLET
	lds		r18, LIVES 
	dec		r18  
	sts		LIVES, r18  
	tst		r18 
	brne	ENEMY_BULLET_COLLISION_PLAYER_EXIT 
	push	r17 
	ldi		r17,3 
	sts		STATE, r17
	sts		STATE_TIMER, r2 
	pop		r17
ENEMY_BULLET_COLLISION_PLAYER_EXIT:
	pop		r18
	rjmp	ENEMY_BULLET_COLLISION_EXIT
	

ENEMY_BULLET_COLLISION_BARRIER: 
	push	r16
	push	r17
	push	r18
	push	XL
	push	XH
	cpi		r17, 1
	brne	ENEMY_BULLET_COLLISION_BARRIER_EXIT
	
	rcall	NORMALIZE_PLAYER_BULLET 
	rcall	CONVERT_TO_BINARY
	
	LOAD_X	SHIELD
	add_x	r18
	ld		r17, X
	
	and		r16, r17
	tst		r16
	breq	ENEMY_BULLET_COLLISION_BARRIER_EXIT 
	com		r16
	and		r16, r17
	st		X, r16
	pop		XL
	pop		XH
	rcall	RESET_ENEMY_BULLET
	push	XL ;x pushas för att sedan kunna popas direkt i exit under, huvudvärk annars
	push	XH
	
ENEMY_BULLET_COLLISION_BARRIER_EXIT:
	pop		XH
	pop		XL
	pop		r18
	pop		r17
	pop		r16
	rjmp	ENEMY_BULLET_COLLISION_EXIT

ENEMY_BULLETS_DISPLAY:
	push	r16
	push	r17
	push	r18 
	push	r19 
	push	r20

	LOAD_X	ENEMY_BULLET_X
	LOAD_Y	ENEMY_BULLET_Y

	ldi		r18, CYAN
	ldi		r20, ENEMY_BULLET_AMOUNT
ENEMY_BULLETS_DISPLAY_LOOP:
	ld		r16, X+
	ld		r17, Y+
	ldi		r19, 7
	cpse	r17, r19
	rcall	VMEM_PRINT
	dec		r20
	brne	ENEMY_BULLETS_DISPLAY_LOOP
ENEMY_BULLETS_DISPLAY_EXIT:
	pop		r20
	pop		r19
	pop		r18 
	pop		r17 
	pop		r16
	ret