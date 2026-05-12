.dseg
CURRENT_TEXTURE:	.byte	1

.cseg
TITLE_INIT:
	sts		CURRENT_TEXTURE, r2
	ret

DISPLAY_TITLE:
	push	r20
	ldi		r20, 16
	load_x	VMEM_GREEN
	lds		r16, CURRENT_TEXTURE
	lsl		r16
	ldi     ZL, low(PICK_TEXTURE_TABLE << 1)   ; Load low byte of address
    ldi     ZH, high(PICK_TEXTURE_TABLE << 1)  ; Load high byte of address
	add_z	r16
	ijmp
PICK_TEXTURE_TABLE:
	load_z	ENEMY_TEXTURE_0
	rjmp	DISPLAY_TITLE_LOOP
	load_z	ENEMY_TEXTURE_1
	rjmp	DISPLAY_TITLE_LOOP
	load_z	ENEMY_TEXTURE_2
	rjmp	DISPLAY_TITLE_LOOP
	load_z	ENEMY_TEXTURE_3
	rjmp	DISPLAY_TITLE_LOOP

DISPLAY_TITLE_LOOP:
	lpm		r16, Z+
	st		X+, r16
	dec		r20
	brne	DISPLAY_TITLE_LOOP
	pop		r20
	ret

TITLE_UPDATE:
	rcall	GET_BUTTON
	sbrs	r19, 0
	rjmp	TITLE_UPDATE_ANIMATION
	ret

TITLE_UPDATE_ANIMATION:
	SFX		2
	push	r17
	ldi		r17, 1
	sts		STATE, r17
	sts		STATE_TIMER, r2
	sts		CURRENT_TEXTURE, r17
	pop		r17
	ret

TITLE_TIMER:
	push	r16
	push	r17
	push	r18

	lds		r18, CURRENT_TEXTURE
	inc		r18
	sts		CURRENT_TEXTURE, r18
	lds		r16, STATE_TIMER
	inc		r16
	sts		STATE_TIMER, r16
	ldi		r17, TITLE_ANIMATION_TIME
	cpse	r16, r17
	rjmp	TITLE_TIMER_EXIT
	ldi		r18, 2
	sts		STATE, r18
	rcall	SOUND_INIT

TITLE_TIMER_EXIT:
	pop		r18
	pop		r17
	pop		r16
	ret
	
ENEMY_TEXTURE_0:
	.db $10, $08, $20, $04, $F0, $0F, $D8, $1B, $FC, $3F, $F4, $2F, $14, $28, $60, $06
ENEMY_TEXTURE_1:
	.db $10, $08, $20, $04, $F0, $0F, $D8, $1B, $FC, $3F, $F2, $4F, $10, $08, $20, $04
ENEMY_TEXTURE_2:
	.db $10, $08, $20, $04, $F0, $0F, $DA, $5B, $FC, $3F, $F8, $1F, $10, $08, $10, $08
ENEMY_TEXTURE_3:
	.db $10, $08, $24, $24, $F4, $2F, $DC, $3B, $FC, $3F, $F8, $1F, $10, $08, $08, $10