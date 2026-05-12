.equ PLAYER_START_POS = 4

.dseg
PLAYER_X:	.byte	1

.cseg
PLAYER_INIT:
	push r16
	ldi r16, PLAYER_START_POS
	sts PLAYER_X, r16
	pop r16
	ret

PLAYER_UPDATE:
	push r16
	push r17
	push r18

	lds r18, TIMER_PLAYER
	tst r18
	brne PLAYER_EXIT

	lds r16, PLAYER_X
	rcall JOYSTICK_CONVERT
	tst r17
	breq DECREASE_PLAYER
	cpi r17, 3
	breq INCREASE_PLAYER
	rjmp PLAYER_EXIT

DECREASE_PLAYER:
	clr r18
	cpse r16, r18
	dec r16
	rjmp TIMER_PLAYER_UPDATE	

INCREASE_PLAYER:
	ldi r18, 15
	cpse r16, r18
	inc r16

TIMER_PLAYER_UPDATE:
	SFX 0
	ldi r17, TIMER_PLAYER_LENGTH
	sts TIMER_PLAYER, r17
PLAYER_EXIT:
	sts PLAYER_X, r16
	pop r18
	pop r17
	pop r16
	ret

PLAYER_DISPLAY:
	lds r16, PLAYER_X
	ldi r17, 0
	ldi r18, RED		
	rcall VMEM_PRINT
	ret