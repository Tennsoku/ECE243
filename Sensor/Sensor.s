.equ ADDR_LEGO_JP1, 0xFF200060
.equ RED_LED, 0xFF200000
.global _start

_start:

	movia r10, ADDR_LEGO_JP1
	movia r13, RED_LED

	movia r18, 0x07f557ff
	stwio r18, 4(r10)

	movia r18, 0xffffffff  	#Turn all motor off
	stwio r18, 0(r10)

	ldwio r14, 0(r10)
	movia r18, 0xfffffbff
	and r14, r14, r18
	stwio r14, 0(r10)

Read:
	ldwio r9, 0(r10)
	srli r9,r9, 11
	andi r9,r9,1
	bne r9, r0, Read
	
	ldwio r18, 0(r10)
	srli r18, r18, 27
	
print_LED:
	stwio r18, 0(r13)

LOOP:
	br Read