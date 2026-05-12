.equ DEATH_TIME = 30
.equ TITLE_ANIMATION_TIME = 30

.dseg
STATE:			.byte	1
STATE_TIMER:	.byte	1

.cseg
.org $00
	rjmp START
.org OC2addr
	rjmp TIMER2_ISR
.org OC0addr 
	rjmp TIMER0_ISR 

START:
	jmp		HW_INIT
	
.include	"library.inc"

HW_INIT: 
	ldi		r17, HIGH(RAMEND)
	out		SPH, r17
	ldi		r17, LOW(RAMEND)
	out		SPL, r17

	clr		r2
	sbi		PORTD, PD5

	rcall	TWI_OPEN
	rcall	JOYSTICK_CONFIG
	rcall	VMEM_INIT
	rcall	SPI_INIT
	rcall	INTERRUPT_INIT   
	rcall	CLEAR_BUTTON
	rcall	LCD_INIT 
	rcall	SOUND_INIT
	
	rcall	WARM_START
	rjmp	TITLE
	
WARM_START:
	cli
	rcall	STATE_INIT
	rcall	GAMEPLAY_INIT
	rcall	TITLE_INIT 
	SFX		2
	sei
	ret

TITLE:
	cli 
	rcall	INIT_LCD_TITLE
	rcall	CLEAR_VMEM
	rcall	TITLE_UPDATE
	rcall	DISPLAY_TITLE 
	sei 
	rjmp	STATE_EXIT

TITLE_ANIMATION:
	cli
	rcall	CLEAR_VMEM
	rcall	DISPLAY_TITLE
	rcall	TITLE_TIMER
	sei
	rjmp	STATE_EXIT

GAME: 
	cli  
	rcall	CLEAR_POINTS_FLAG
	rcall	INIT_LCD_MAIN
	ldi		r16, 30
	rcall	CLEAR_VMEM
	rcall	GAMEPLAY_UPDATE
	rcall	DISPLAY_GRAPHICS 
	sei  

	lds		r16, POINTS_FLAG
	cpse	r16, r2
	call	LCD_POINTS 
	call	LCD_UPDATE_HEALTH
	rjmp	STATE_EXIT
		
DEATH:
	cli  
	rcall	INIT_LCD_GAMEOVER
	rcall	CLEAR_VMEM
	rcall	ENEMY_DISPLAY
	lds		r16, STATE_TIMER
	inc		r16
	sts		STATE_TIMER, r16
	ldi		r17, DEATH_TIME
	sei
	cpse	r16, r17
	rjmp	STATE_EXIT 
	rcall	CHECK_HIGHSCORE
	rcall	SET_POINTS_FLAG 
	clr		r16
	sts		LCD_GAMEOVER_PLAYED,r16
	rcall	WARM_START 
	rjmp	TITLE

STATE_EXIT:
	sei
	rcall	GAMEPLAY_DELAY
	lds		r16, STATE
	cpi		r16, 0 
	breq	TITLE
	cpi		r16, 1
	breq	TITLE_ANIMATION
	cpi		r16, 2
	breq	GAME
	cpi		r16, 3
	breq	DEATH
	rjmp	GAME 

STATE_INIT:
	sts		STATE, r2
	sts		STATE_TIMER, r2
	ret