.equ ADDR_LEGO_JP1, 0xFF200060
.equ RED_LED, 0xFF200000
.global _start

_start:

	movia r10, ADDR_LEGO_JP1
	movia r13,RED_LED

	movia r18,0xffffffff  	#Turn all motor off
	stwio r18,0(r10)

	movia r18,0xfffff3fC
	stwio r18,0(r10)
	ldwio r18,0(r10)
	srli r18,27
	
print_LED:
	stwio r18, 0(r13)

LOOP:
	br _start