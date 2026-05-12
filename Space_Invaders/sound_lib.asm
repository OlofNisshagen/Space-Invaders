.equ CHANNELS_AMOUNT = 4

.dseg
SPEAKER_DIRECTION:		.byte	1

CHANNELS_ACTIVE:		.byte	1

CH_INTERVAL:			.byte	CHANNELS_AMOUNT
CH_INTERVAL_DURATION:	.byte	CHANNELS_AMOUNT
CH_LENGTH:				.byte	CHANNELS_AMOUNT
CH_LENGTH_DURATION:		.byte	CHANNELS_AMOUNT

.cseg
SOUND_INIT:
	ldi		r16, $FF
	out		DDRB, r16
	sts		SPEAKER_DIRECTION, r2
	sts		CHANNELS_ACTIVE, r2
	ldi		r16, CHANNELS_AMOUNT
CLEAR_CHANNELS:
	dec		r16
	rcall	CLEAR_CHANNEL
	tst		r16
	brne	CLEAR_CHANNELS
	ret

CLEAR_CHANNEL:
	ldi		r17, CHANNELS_AMOUNT
	load_x	CH_INTERVAL
	add_x	r16
	st		X, r2
	add_x	r17
	st		X, r2
	add_x	r17
	st		X, r2
	add_x	r17
	st		X, r2
	ret

ADD_SOUND:
	push	r16
	push	r17
	push	r18
	push	r19
	lds		r18, CHANNELS_ACTIVE
	ldi		r17, CHANNELS_AMOUNT
ADD_SOUND_LOOP:
	lsr		r18
	brcc	SOUND_TO_CHANNEL
	dec		r17
	brne	ADD_SOUND_LOOP
	rjmp	ADD_SOUND_EXIT
	
SOUND_TO_CHANNEL:
	ldi		r19, CHANNELS_AMOUNT
	sub		r19, r17
	load_z	SFX_TABLE
	lsl		r16
	add_z	r16

	lpm		r17, Z+
	lpm		r18, Z
	mov		ZL, r17
	mov		ZH, r18
	lsl		ZL
	rol		ZH

	load_x	CH_INTERVAL
	rcall	ADD_VALUE

	load_x	CH_INTERVAL_DURATION
	rcall	ADD_VALUE

	load_x	CH_LENGTH
	rcall	ADD_VALUE

	load_x CH_LENGTH_DURATION
	rcall	ADD_VALUE

	ldi		r17, $01
	tst		r19
	breq	SOUND_TO_CHANNEL_EXIT
SOUND_TO_CHANNEL_LOOP:
	lsl		r17
	dec		r18
	brne	SOUND_TO_CHANNEL_LOOP
SOUND_TO_CHANNEL_EXIT:
	lds		r16, CHANNELS_ACTIVE
	or		r16, r17
	sts		CHANNELS_ACTIVE, r16
ADD_SOUND_EXIT:
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	ret

ADD_VALUE:
	add_x	r19
	lpm		r16, Z+
	st		X, r16
	ret
	
SFX_TABLE:
	.dw		SFX_SHOOT
	.dw		SFX_ENEMY
	.dw		SFX_MENU

SFX_SHOOT:	.db 5, 50, 200, 0
SFX_ENEMY:	.db 15, 0, 150, 0
SFX_MENU:	.db 3, 0, 255, 0