.dseg 
SEED:	.byte 1 

.cseg
RANDOMIZE_SEED:
	push	r16
	push	r17
	lds		r16, SEED       
	lsr		r16             
	brcc	RANDOMIZE_SEED_EXIT    
	ldi		r17, 0xB8      
	eor		r16, r17       
RANDOMIZE_SEED_EXIT:
    sts		SEED, r16      
    pop		r17
    pop		r16
    ret

GET_RANDOM_16:
	lds		r16, SEED
	andi	r16, $0F
	ret