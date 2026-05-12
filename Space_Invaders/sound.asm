.cseg
GENERATE_SOUND:
	lds		r16, CHANNELS_ACTIVE
	tst		r16
	breq	SOUND_ZERO		
	ldi		r17, CHANNELS_AMOUNT
	clr		r22
GENERATE_SOUND_LOOP:
	lsr		r16
	brcs	UPDATE_SOUND
GENERATE_SOUND_LOOP_CONTINUE:
	dec		r17
	brne	GENERATE_SOUND_LOOP
	tst		r22
	brne	PLAY_SOUND
	ret

PLAY_SOUND:
	sbic	PORTB, PB1
	rjmp	SOUND_ZERO
	sbi		PORTB, PB1
	ret

SOUND_ZERO:
	cbi		PORTB, PB1
	ret

UPDATE_SOUND:
	push	r16
	push	r17
	
	ldi		r21, CHANNELS_AMOUNT
	mov		r16, r21
	sub		r16, r17

	load_x	CH_INTERVAL
	add_x	r16
	ld		r17, X
	add_x	r21
	ld		r18, X
	add_x	r21
	ld		r19, X
	add_x	r21
	ld		r20, X

	inc		r18
	cp		r17, r18
	breq	PLAY_SOUND_UPDATE	

UPDATE_SOUND_WHATEVER:
	load_x	CH_INTERVAL_DURATION
	add_x	r16
	st X,	r18

	load_x	CH_LENGTH_DURATION
	add_x	r16
	st		X, r20

UPDATE_SOUND_EXIT:
	pop		r17
	pop		r16
	rjmp	GENERATE_SOUND_LOOP_CONTINUE

PLAY_SOUND_UPDATE:
	inc		r22
	clr		r18
	inc		r20
	cp		r19, r20
	breq	STOP_SOUND
	rjmp	UPDATE_SOUND_WHATEVER

STOP_SOUND:
	push	r16
	rcall	CLEAR_CHANNEL
	ldi		r21, $01
	tst		r16
	breq	STOP_SOUND_LOOP_EXIT
STOP_SOUND_LOOP:
	lsl		r21
	dec		r16
	brne	STOP_SOUND_LOOP
STOP_SOUND_LOOP_EXIT:
	com		r21
	lds		r16, CHANNELS_ACTIVE
	and		r16, r21
	sts		CHANNELS_ACTIVE, r16
	pop		r16
	rjmp	UPDATE_SOUND_EXIT