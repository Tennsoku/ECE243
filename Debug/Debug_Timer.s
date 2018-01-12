.equ ADDR_LEGO_JP1, 0xFF200060
.equ ADDR_PS2, 0xFF200100
.equ TIMER_1, 0xff202000 
.equ TIMER_2, 0xff202020	#IRQ = 2
.equ PERIOD, 100000000  #checking period is 1 sec/100MHz
.equ RED_LED, 0xFF200000

.global _start

_start:

	movia sp,0x03fffffc


#initialize 
	movia r8, ADDR_PS2
	movia r9, RED_LED
	movia r10, ADDR_LEGO_JP1
	movia r11, TIMER_1
	movia r13, TIMER_2

#set motor and sensor
	movia r18, 0x07f557ff		#set direction register
	stwio r18, 4(r10)
	#set threshold
	movia r18, 0xFBBFFBFF		#11111 0111 011 1111 1111 1011 1111 1111
	stwio r18, 0(r10)
	movia r18, 0xFBDFFFFF		#11111 0111 101 1111 1111 1111 1111 1111
	stwio r18, 0(r10)


#set Timer 2
	
	# movui r18, %lo(PERIOD)
	# stwio r18, 8(r13)
	# movui r18, %hi(PERIOD)
	# stwio r18, 12(r13)
	# #reset timer
	# stwio r0, 0(r13)
	# movui r18, 0x6
	# stwio r18, 4(r13)
		
	movia r12, 100000000

Set_Timer_1:
	
	andi r18,r12,0xFFFF
	stwio r18, 8(r11)
	srli r18, r12,16
	andi r18, r18,0xFFFF
	stwio r18, 12(r11)
	#reset timer
	stwio r0, 0(r11)
	movui r18, 0x7
	stwio r18, 4(r11)

	#enable interrupt
	movui r18, 0x001		#IRQ0 -> Timer1;IRQ7 -> PS2; IRQ11 -> LEGO controll JP1
	wrctl ctl3, r18			#enable ienable
	movui r18, 0b1
	wrctl ctl0,r18         	#Enable PIE bit

Loop:
	rdctl r19, ctl0
	# rdctl r20, ctl1
	# rdctl r21, ctl2
	rdctl r20, ctl3
	rdctl r21, ctl4
	br Loop 

#========================ISR=======================#
.section .exceptions, "ax"
.global ISR
ISR:
	# subi sp, sp, 12 
	# stw et, 0(sp)
	# rdctl et, ctl1
	# stw et, 4(sp)
	# stw ea, 8(sp)
	
	rdctl et, ctl4
	andi et, et, 0b1
	bne et, r0, Handler_Timer_1
	br Return

Handler_Timer_1:
	#movui r18, 0b10

	#Debug Session
	movia r9, RED_LED
	ldwio r18, 0(r9)
	andi r18, r18, 0b1
	bne r18, r0, Turn_off
	movui r18, 0b1
	stwio r18, 0(r9)

	
	br Return

Turn_off:
	stwio r0, 0(r9)
	br Return

Return:
	# ldw et, 0(sp)
	# wrctl ctl1,et
	# ldw et, 4(sp)
	# ldw ea, 8(sp)
	# addi sp, sp, 12
	subi ea,ea,4

	stwio r0, 0(r11)
	eret