.equ BLUE	= 0b00000001
.equ GREEN	= 0b00000010
.equ CYAN	= 0b00000011
.equ RED	= 0b00000100
.equ PURPLE	= 0b00000101
.equ YELLOW	= 0b00000110
.equ WHITE	= 0b00000111

.equ SCREEN_SIZE = 16

.macro LOAD_X
	ldi		XL, low(@0)
	ldi		XH, high(@0)
.endmacro

.macro LOAD_Y
	ldi		YL, low(@0)
	ldi		YH, high(@0)
.endmacro

.macro LOAD_Z
	ldi		ZL, low(@0*2)
	ldi		ZH, high(@0*2)
.endmacro

.macro ADD_X
	add		XL, @0
	adc		XH, r2
.endmacro

.macro ADD_Y
	add		YL, @0
	adc		YH, r2
.endmacro

.macro ADD_Z
	add		ZL, @0
	adc		ZH, r2
.endmacro

.macro SFX
	push	r16
	ldi		r16, @0
	call	ADD_SOUND
	pop		r16
.endmacro