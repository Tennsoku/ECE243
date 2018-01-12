.equ ADDR_LEGO_JP1, 0xFF200060
.equ TIMER_1, 0xff202000 
.equ TIMER_2, 0xff202020	#IRQ = 2
.equ PERIOD,100000000  #checking period is 1 sec

.data
#arraaaaaaaaaaaaaaayyyyyyyyyyyyy
SPEED_LIST:
	.word
	.word
	.word
	.word
	.word


.global _start

_start:

	movia sp,0x03fffffc

#initialize 
	movia r8, ADDR_PS2
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

#enable interrupt
	movui r14, 0x881		#IRQ0 -> Timer1;IRQ7 -> PS2; IRQ11 -> LEGO controll JP1
	wrctl ctl3, r14			#enable ienable
	movui r14, 0b1
	wrctl ctl0,r14         	#Enable PIE bit

#register list:
#r8 = PS/2 Address
#r9 = read value
#r10 = motor base
#r11 = Timer 1 base
#r12 = Timer1_Period
#r13 = Timer 2 base
#r14 = saved timer snapshot
#r15 = saved snapshot gap
#r16 = current speed
#r17 = 
#r18 = temp value1
#r19 = temp value2

#Timer set:
#TIMER_1 is used to control speed by switching motors
#TIMER_2 is used to detect current speed



#set Timer 2
	
	movui r18, %lo(PERIOD)
	stwio r18, 8(r13)
	movui r18, %hi(PERIOD)
	stwio r18, 12(r13)
	#reset timer
	stwio r0, 0(r13)
	movui r18, 0x6
	stwio r18, 4(r8)
	
	movia r12, 1000000

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

	#enable PS2 interrupt
	movui r18, 0b1
	stwio r18, 4(r8)

	#bne r15, r0, Get_speed

	
	
Motor:
	
	movia r18,0x082fffff  	#Turn all motor off
	stwio r18,0(r10)

Loop:
	br Set_Timer_1 

Get_speed: 
	
	
	
	
	
#========================ISR=======================#
.section .exceptions, "ax"
IHandler:
	subi sp, sp, 12 
	stw et, 0(sp)
	srctl et, ctl1
	stw et, 4(sp)
	stw ea, 8(sp)
	
	rdctl et, ctl4
	andi et, et, 0x80
	bne et, r0, Handler_PS2
	rdctl et, ctl4
	andi et, et, 0b1
	bne et, r0, Handler_Timer_1
	rdctl et, ctl4
	andi et, et, 0x800
	bne et, r0, Handler_Sensor
	
	
Handler_Timer_1:
	ldwio r18,0(r10)       	#load current motor status	
	andi r19, r18, 0b0001
	bne r15, r0, TURN_OFF
	br TURN_ON

TURN_OFF:
	ori r18, r18, 0b0101
	stwio r18, 0(r10)
	br Return

TURN_ON:
	andi r18, r18, 0b1010
	stwio r18, 0(r10)
	br Return	

Handler_Senor:
	stwio r0, 16(r10)
	stwio r0, 20(r10)
	mov r18, r0
	mov r19, r0
	bne r14, r0, Save_snapshot

Read_new_snapshot:	
	ldhio r18, 16(r10)
	mov r14, r18
	ldhio r18, 20(r10)
	slli r18, r18, 16
	or r14, r14, r18

	bne r19, r0, Update_gap

	br Return

Save_snapshot:
	mov r19, r14
	br Read_new_snapshot

Update_gap:
	blt r14, r19, Negative_gap
	sub r15, r14, r19
	br Return
	
Negative_gap:
	add r15, r14, r0
	subi r18, r19, 100000000
	subi r18, r0, r18
	add r15, r15, r18
	br Return
	
Handler_PS2:
	ldb r9, 0(r8)

	movui r18, 0x16			#1
	beq	r9, r18, Speed_set_1
	movui r18, 0x1E			#2
	beq	r9, r18, Speed_set_2
	movui r18, 0x26			#3
	beq	r9, r18, Speed_set_3
	movui r18, 0x25			#4
	beq	r9, r18, Speed_set_4
	movui r18, 0x2E			#5
	beq	r9, r18, Speed_set_5
	br Return

Speed_set_1:
	movia r12, 1000000		#1 MHz
	br Reset_TIMER_1
	
Speed_set_2:
	movia r12, 800000		#0.8 MHz
	br Reset_TIMER_1
	
Speed_set_3:
	movia r12, 500000		#0.5 MHz
	br Reset_TIMER_1	
	
Speed_set_4:
	movia r12, 300000		#0.3 MHz
	br Reset_TIMER_1	

Speed_set_5:
	movia r12, 1000000		#0.1 MHz
	br Reset_TIMER_1

Reset_TIMER_1:
	andi r18,r12,0xFFFF
	stwio r18, 8(r11)
	srli r18, r12,16
	andi r18, r18,0xFFFF
	stwio r18, 12(r11)
	#reset timer
	stwio r0, 0(r11)
	movui r18, 0x7
	stwio r18, 4(r11)

Return:
	ldw et, 0(sp)
	wrctl ctl1,et
	ldw et, 4(sp)
	ldw ea, 8(sp)
	addi sp, sp, 12
	subi ea,ea,4
	eret