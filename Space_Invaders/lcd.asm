.equ LCD_ADDR = $20

.dseg
POINTS:					.byte	5  
HIGHSCORE:				.byte	5  
LCD_MAIN_PLAYED:		.byte	1
LCD_GAMEOVER_PLAYED:	.byte	1 
LCD_TITLE_PLAYED:		.byte	1
POINTS_FLAG:			.byte	1

.cseg
LCD_INIT:
	push	r19
    push	r20

    ldi		r19, 40   ;40ms startup delay
    call	LCD_DELAY
	
	ldi		r20, 0b00110000 ;0x30, 3 gånger 
	call	SEND_NIBBLE
    ldi		r19, 5
    call	LCD_DELAY ;vänta 5ms

	call	SEND_NIBBLE
    ldi		r19, 1
    call	LCD_DELAY  ;vänta 1ms

	call	SEND_NIBBLE
	ldi		r20, 0b00100000   ; Steg 4: 0x20 växla till 4-bit  
	call	SEND_NIBBLE 

	ldi		r20, $20 	;function set
	call	SEND_NIBBLE 
	ldi		r20,0b11000000
	call	SEND_NIBBLE  

	clr		r20
	call	SEND_NIBBLE 
	ldi		r20, $80 
	call	SEND_NIBBLE 

	clr		r20
	call	SEND_NIBBLE
	ldi		r20, $10 
	ldi		r19, 2 
	call	LCD_DELAY   ;0x01 clear display, vänta 2ms 

	clr		r20
	call	SEND_NIBBLE 
	ldi		r20, $60 
	call	SEND_NIBBLE     ; 0x06 entry mode

	clr		r20 
	call	SEND_NIBBLE 
	ldi		r20, $C0 
	call	SEND_NIBBLE      ; 0x0C display on 
  
	sts		LCD_MAIN_PLAYED,r2
	sts		LCD_GAMEOVER_PLAYED,r2  
	call	RESET_POINTS
	call	RESET_HIGHSCORE

	call	LCD_TITLE

    pop		r20
    pop		r19
    ret

SEND_NIBBLE:  
	push	r20

	ori		r20, 0b00001000		;BL = 1 
    andi	r20, 0b11111011    ;E = 0
    tout	LCD_ADDR, r20
    ori		r20, 0b00000100	    ; E = 1
    tout	LCD_ADDR, r20
    andi	r20, 0b11111011	 ; E = 0
    tout	LCD_ADDR, r20

    pop		r20
	ret 

SEND_LETTER: 
	push	r20
	push	r16
	mov		r16, r20  
	andi	r20, 0b11110000 ;höga nibble 
	ori		r20, 1 
	call	SEND_NIBBLE  
	lsl		r16 ;low nibble 
	lsl		r16 
	lsl		r16
	lsl		r16 
	ori		r16, 1 
	mov		r20, r16 
	call	SEND_NIBBLE
	pop		r16
	pop		r20
	ret 

LCD_LINE_1:
	clr		r20
	call	SEND_NIBBLE  
	ldi		r20, $20
	call	SEND_NIBBLE    
	ret 

LCD_LINE_2:
	push	r20
	ldi		r20, 0b11000000 
	call	SEND_NIBBLE    
	ldi		r20, 0b00000000 
	call	SEND_NIBBLE      
	pop		r20
	ret  

LCD_CLEAR: 
	push	r20 
	push	r19
	clr		r20
	call	SEND_NIBBLE  
	ldi		r20, $10
	call	SEND_NIBBLE    
	ldi		r19, 2
	call	LCD_DELAY
	pop		r19 
	pop		r20 
	ret

LCD_POINT_START:
	push	r20
	ldi		r20, 0b11000000 
	call	SEND_NIBBLE    
	ldi		r20, 0b10110000 
	call	SEND_NIBBLE      
	pop		r20
	ret 

LCD_UPDATE_HEALTH:
	push	r16 
	push	r20 
	lds		r16, LIVES
	cpi		r16,3
	breq	LCD_LIFE3
	cpi		r16,2 
	breq	LCD_LIFE2 
	cpi		r16,1
	breq	LCD_LIFE1  
	brne	LCD_UPDATE_HEALTH_EXIT

LCD_LIFE3: 
	ldi		r20, $6F
	call	LCD_HEALTH3_POINT  
	call	SEND_LETTER
	call	LCD_HEALTH2_POINT  
	call	SEND_LETTER 
	call	LCD_HEALTH1_POINT  
	call	SEND_LETTER 
	rjmp	LCD_UPDATE_HEALTH_EXIT

LCD_LIFE2:  
	call	LCD_HEALTH1_POINT
	ldi		r20, $78  
	call	SEND_LETTER
	rjmp	LCD_UPDATE_HEALTH_EXIT

LCD_LIFE1: 
	call	LCD_HEALTH2_POINT
	ldi		r20 ,$78 
	call	SEND_LETTER

LCD_UPDATE_HEALTH_EXIT:
	pop		r20 
	pop		r16
	ret

LCD_HEALTH1_POINT:
	push	r20
	ldi		r20, 0b10000000 
	call	SEND_NIBBLE    
	ldi		r20, 0b10110000 
	call	SEND_NIBBLE      
	pop		r20
	ret  

LCD_HEALTH2_POINT:
	push	r20
	ldi		r20, 0b10000000 
	call	SEND_NIBBLE    
	ldi		r20, 0b11010000 
	call	SEND_NIBBLE      
	pop		r20
	ret 
	 
LCD_HEALTH3_POINT:
	push	r20
	ldi		r20, 0b10000000 
	call	SEND_NIBBLE    
	ldi		r20, 0b11110000 
	call	SEND_NIBBLE      
	pop		r20
	ret  

LCD_TITLE:   
	push	r16 
	push	r20
	call	LCD_CLEAR 
	ldi		r16, 16  
	load_Z	TITTLE1_CHARACTERS 

TITLE_LINE1_LOOP: 
	lpm		r20, Z+  
	call	SEND_LETTER 
	dec		r16 
	brne	TITLE_LINE1_LOOP  
	ldi		r16, 15
	load_Z	TITTLE2_CHARACTERS  
	call	LCD_LINE_2 

TITLE_LINE2_LOOP:
	lpm		r20 ,Z+  
	call	SEND_LETTER 
	dec		r16 
	brne	TITLE_LINE2_LOOP   
	ldi		r20, 3  
	sts		LIVES, r20 
	ldi		r16, 1
	sts		LCD_TITLE_PLAYED, r16
	pop		r20
	pop		r16
	ret

RESET_POINTS: 
	push	r16
	load_X	points 
	ldi		r16, 5
RESET_POINTS_LOOP: 
	st		X+, r2 
	dec		r16
	brne	RESET_POINTS_LOOP
	pop		r16
	ret  

RESET_HIGHSCORE:	
	push	r16
	load_x	HIGHSCORE 
	ldi		r16, 5
RESET_HIGHSCORE_LOOP: 
	st		X+, r2 
	dec		r16
	brne	RESET_HIGHSCORE_LOOP
	pop		r16
	ret 

LCD_GAMEOVER:   
	push	r16 
	push	r20
	call	LCD_CLEAR 
	ldi		r16, 13
	load_Z	GAMEOVER_CHARACTERS 
GAMEOVER_LOOP: 
	lpm		r20, Z+  
	call	SEND_LETTER 
	dec		r16 
	brne	GAMEOVER_LOOP     
	ldi		r16, 10
	load_Z	GAMEOVER2_CHARACTERS
	call LCD_LINE_2 
GAMEOVER2_LOOP:
	lpm		r20, Z+  
	call	SEND_LETTER 
	dec		r16 
	brne	GAMEOVER2_LOOP   
	call	CHECK_HIGHSCORE
	call	LCD_HIGHSCORE
	ldi		r16, 1
	sts		LCD_GAMEOVER_PLAYED, r16  
	clr		r16
	sts		LCD_MAIN_PLAYED, r16 
	sts		LCD_TITLE_PLAYED, r16

	pop		r20 
	pop		r16
	ret 

LCD_MAIN:   
	push	r16 
	push	r17
	push	r20 
	
	call	LCD_CLEAR  
	ldi		r16, 6
	load_Z  MAIN1_CHARACTERS
MAIN1_LOOP: 
	lpm		r20, Z+  
	call	SEND_LETTER 
	dec		r16 
	brne	MAIN1_LOOP   
	ldi		r20, $6F
	call	LCD_HEALTH3_POINT  
	call	SEND_LETTER
	call	LCD_HEALTH2_POINT  
	call	SEND_LETTER 
	call	LCD_HEALTH1_POINT  
	call	SEND_LETTER 

	ldi		r16,7
	load_z	MAIN2_CHARACTERS  
	call	LCD_LINE_2 
 MAIN2_LOOP:
	lpm		r20, Z+  
	call	SEND_LETTER 
	dec		r16 
	brne	MAIN2_LOOP   
	call	LCD_POINTS 
 
	pop		r20 
	pop		r17
	pop		r16
	ret 

CHECK_HIGHSCORE: 
	push	r16  
	push	r17
	push	r18

	ldi		r18, 16
 CHECK_HIGHER_SCORE:  
	dec		r18
	load_X	POINTS 
	load_y	HIGHSCORE 
	add_x	r18
	add_y	r18   

	ld		r16, X
	ld		r17, Y
	cp		r16, r17 
	brlo	HIGHSCORE_EXIT  
	cpse	r18, r2
	breq	CHECK_HIGHER_SCORE 
	ldi		r18, 5
	load_X  POINTS 
	load_y  HIGHSCORE 

 CHANGE_HIGHSCORE_LOOP: 
	ld		r16, X+ 
	st		Y+, r16 
	dec		r18 
	brne	CHANGE_HIGHSCORE_LOOP
 HIGHSCORE_EXIT:
	call	RESET_POINTS
	pop		r18
	pop		r17
	pop		r16
	ret

LCD_POINTS:  
	push	r16  
	push	r17 
	push	r19
	push	r20   
	clc
	ldi		r17, 4
	call	LCD_POINT_START
POINTS_SEND_LOOP: 
	load_x	POINTS  
	add		XL,	r17
	ld		r16, X 
	load_z	POINTS_NUMBERS
	add_Z	r16 
	lpm		r20, Z 
	call	SEND_LETTER  
	ldi		r19, 2
	call	LCD_DELAY
	dec		r17 
	brne	POINTS_SEND_LOOP   
	load_x	POINTS
	ld		r16, X 
	load_z	POINTS_NUMBERS
	add_z	r16 
	lpm		r20 ,Z 
	call	SEND_LETTER  
 
	ldi		r16, 1
	sts		LCD_MAIN_PLAYED, r16

	pop		r20 
	pop		r19
	pop		r17
	pop		r16
	ret  

LCD_HIGHSCORE:  
	push	r16  
	push	r17 
	push	r19
	push	r20   
	clc
	ldi		r17, 4
	call	LCD_POINT_START
HIGHSCORE_SEND_LOOP: 
	load_x	HIGHSCORE  
	add		XL, r17
	ld		r16, X 
	LOAD_Z	POINTS_NUMBERS
	ADD_Z	r16 
	lpm		r20 ,Z 
	call	SEND_LETTER  
	ldi		r19, 2
	call	LCD_DELAY
	dec		r17 
	brne	HIGHSCORE_SEND_LOOP   
	LOAD_X	HIGHSCORE
	ld		r16, X 
	LOAD_Z	POINTS_NUMBERS
	ADD_Z	r16 
	lpm		r20, Z 
	call	SEND_LETTER  
 
	ldi		r16, 1
	sts		LCD_MAIN_PLAYED,r16

	pop		r20 
	pop		r19
	pop		r17
	pop		r16
	ret 

LCD_DELAY:
    push	r17
    push	r18
LCD_DELAY_OUTER:
    ldi		r17, $FF
LCD_DELAY_MIDDLE:
    ldi		r18, $FF
LCD_DELAY_INNER:
    dec		r18
    brne	LCD_DELAY_INNER
    dec		r17
    brne	LCD_DELAY_MIDDLE
    dec		r19
    brne	LCD_DELAY_OUTER
    pop		r18
    pop		r17
    ret  

INIT_LCD_MAIN: 
	push	r16 
	push	r17
	ldi		r16, 1
	lds		r17, LCD_MAIN_PLAYED
	cpse	r16, r17
	call	LCD_MAIN
	pop		r17
	pop		r16
	ret  
		
INIT_LCD_TITLE: 
	push	r16 
	push	r17
	ldi		r16, 1
	lds		r17, LCD_TITLE_PLAYED
	cpse	r16, r17
	call	LCD_TITLE
	pop		r17
	pop		r16
	ret 

INIT_LCD_GAMEOVER: 
	push	r16 
	push	r17
	ldi		r16, 1
	lds		r17, LCD_GAMEOVER_PLAYED
	cpse	r16, r17
	call	LCD_GAMEOVER
	pop		r17
	pop		r16
	ret

CLEAR_POINTS_FLAG:
	sts		POINTS_FLAG, r2
	ret

SET_POINTS_FLAG:
	push	r17
	ldi		r17, 1
	sts		POINTS_FLAG, r17
	pop		r17
	ret

TITTLE1_CHARACTERS: 
	.db $53,$50,$41,$43,$45,$B0,$49,$4E,$44,$41,$56,$49,$44,$53,$21,$21
TITTLE2_CHARACTERS:   
	.db $10,$10,$10,$52,$31,$10,$54,$4F,$10,$53,$54,$41,$52,$54 
GAMEOVER_CHARACTERS:
	.db $10,$10,$10,$47,$41,$4D,$45,$10,$4F,$56,$45,$52,$21, 0 
GAMEOVER2_CHARACTERS:
	.db $48,$49,$47,$48,$53,$43,$4F,$52,$45,$3A
		

	MAIN1_CHARACTERS: 
		.db $4C,$49,$56,$45,$53,$3A


	MAIN2_CHARACTERS:   
	.db $50,$4F,$49,$4E,$54,$53,$3A, 0

	POINTS_NUMBERS: 
	.db $30,$31,$32,$33,$34,$35,$36,$37,$38,$39