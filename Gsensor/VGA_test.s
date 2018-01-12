.text
.global _start

_start:
	.equ ADDR_VGA, 0x08000000
	.equ ADDR_CHAR, 0x09000000
	.equ TIMER, 0xFF202000

	
	#r2 = VGA
	#r3 = CHAR
	#r4 = Col
	#r5 = length & width
	#r6 = startX
	#r7 = nowY
	#r8 = offset address
	#r9 = temp
	#r10 = nowX
	movia r2, ADDR_VGA
	movia r3, ADDR_CHAR
	movia r4, 0xffff 			#White
	movia r5, 0b1101110			#length & width
	movia r6, 0b1100100			#startX
	movia r7, 0b1100100			#startY
	movia sp, 0x03fffffc
	mov r10, r6
	movia r8, ADDR_VGA
	
	addi sp,sp, -24
	stw r8, 0(sp)
	stw r10, 4(sp)
	stw r4, 8(sp)
	stw r5, 12(sp)
	stw r6, 16(sp)
	stw r7, 20(sp)
	call CLEAR_SCREEN
	ldw r7, 20(sp)
	ldw r6, 16(sp)
	ldw r5, 12(sp)
	ldw r4, 8(sp)
	ldw r10, 4(sp)
	ldw r8, 0(sp)
	addi sp,sp,24
	
	addi sp,sp, -24
	stw r8, 0(sp)
	stw r10, 4(sp)
	stw r4, 8(sp)
	stw r5, 12(sp)
	stw r6, 16(sp)
	stw r7, 20(sp)
	#call CLEAR_CHAR
	ldw r7, 20(sp)
	ldw r6, 16(sp)
	ldw r5, 12(sp)
	ldw r4, 8(sp)
	ldw r10, 4(sp)
	ldw r8, 0(sp)
	addi sp,sp,24
	
	br DRAW
	
	movi  r11, 0x54   			#ASCII for 'T'
	stbio r11,2580(r3) 			#(20,20)
	movi  r11, 0x45   			#ASCII for 'E'
	stbio r11,2581(r3) 			#(22,20)
	movi  r11, 0x53   			#ASCII for 'S'
	stbio r11,2582(r3) 			#(24,20)
	movi  r11, 0x54   			#ASCII for 'T'
	stbio r11,2583(r3) 			#(26,20)

	
DRAW:
	movia r8, ADDR_VGA
	muli r9, r10, 2
	add r8, r8, r9
	muli r9, r7, 1024
	add r8, r8, r9
	sthio r4,0(r8) 				#pixel (r10,r7) offset is r8 = r2 + r10*2 + r7*1024
	
LOOP_X:
	addi r10, r10, 1
	beq r10, r5, LOOP_Y
	br DRAW

LOOP_Y:
	addi r7, r7, 1
	beq r7, r5, EXIT
	mov r10, r6
	br DRAW	
	
EXIT:
	br EXIT
	
###############################################################
CLEAR_SCREEN:
	movia r8, ADDR_VGA
	movia r4, 0x0000
	movia r5, 0b11110000		#length 240
	movia r12, 0b101000000		#width 320
	movia r6, 0b0			#startX
	movia r7, 0b0			#startY
	

DRAW_CS:
	movia r8, ADDR_VGA
	muli r9, r10, 2
	add r8, r8, r9
	muli r9, r7, 1024
	add r8, r8, r9
	sthio r4,0(r8) 				#pixel (r10,r7) offset is r8 = r2 + r10*2 + r7*1024
	
LOOP_X_CS:
	addi r10, r10, 1
	beq r10, r12, LOOP_Y_CS
	br DRAW_CS

LOOP_Y_CS:
	addi r7, r7, 1
	beq r7, r5, END_CS
	mov r10, r6
	br DRAW_CS

END_CS:
	ret
	
###############################################################
CLEAR_CHAR:
	movia r8, ADDR_CHAR
	movia r4, 0x00 			#space
	movia r5, 0b111100		#length 60
	movia r12, 0b1010000		#width 80
	movia r6, 0b0			#startX
	movia r7, 0b0			#startY
	

DRAW_CC:
	movia r8, ADDR_CHAR
	muli r9, r10, 1
	add r8, r8, r9
	muli r9, r7, 128
	add r8, r8, r9
	stbio r4,0(r8) 				#pixel (r10,r7) offset is r8 = r2 + r10*1 + r7*128
	
LOOP_X_CC:
	addi r10, r10, 1
	beq r10, r12, LOOP_Y_CC
	br DRAW_CC

LOOP_Y_CC:
	addi r7, r7, 1
	beq r7, r5, END_CC
	mov r10, r6
	br DRAW_CC

END_CC:
	ret