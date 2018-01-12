.equ ADDR_LEGO_JP1, 0xFF200060
.equ ADDR_PS2, 0xFF200100
.equ TIMER_1, 0xff202000 
.equ TIMER_2, 0xff202020			#IRQ = 2
.equ PERIOD_TIMER1, 2000000			#5M, 0.02s
.equ PERIOD_TIMER2, 1000000000  	#1G, 10 sec
.equ RED_LED, 0xFF200000




.data
#arraaaaaaaaaaaaaaayyyyyyyyyyyyy
.align 1
SPEED_COUNTER:
	.hword	0

CURRENT_SET:
	.hword	1

MAX_COUNTER:
	.hword	1

CURRENT_RPM:
	.word	0

CURRENT_ANGLE:
	.word	0

.text

.global _start

_start:

	movia sp,0x03fffffc

#register list:
#r8 = PS/2 Address			
#r9 = RED_LED
#r10 = motor base
#r11 = Timer 1 base
#r12 = SPEED_COUNTER					//R/W 
#r13 = Timer 2 base
#r14 = saved timer Save_snapshot 		//saved
#r15 = saved snapshot gap 				//saved
#r16 = current rpm 						//saved
#r17 = current position status  		//saved
#r18 = temp value1
#r19 = temp value2

#Timer set:
#TIMER_1 is used to control speed by switching motors
#TIMER_2 is used to detect current speed

#initialize 
	movia r8, ADDR_PS2
	movia r9, RED_LED
	movia r10, ADDR_LEGO_JP1
	movia r11, TIMER_1
	movia r13, TIMER_2


#set Timer 2
	
	movui r18, %lo(PERIOD_TIMER2)
	stwio r18, 8(r13)
	movui r18, %hi(PERIOD_TIMER2)
	stwio r18, 12(r13)
	
	#reset timer
	stwio r0, 0(r13)
	movui r18, 0x6
	stwio r18, 4(r13)

#Set_Timer_1:
	
	movui r18, %lo(PERIOD_TIMER1)
	stwio r18, 8(r11)
	movui r18, %hi(PERIOD_TIMER1)
	stwio r18, 12(r11)

	#reset timer
	stwio r0, 0(r11)
	movui r18, 0x7
	stwio r18, 4(r11)

#set motor and sensor
	movia r18, 0x07f557ff		#set direction register
	stwio r18, 4(r10)
	
	#set threshold
	movia r18, 0xFCBFEFFF		#11111 1001 011 1111 1110 1111 1111 1111
	stwio r18, 0(r10)
	movia r18, 0xFCDFFFF0		#11111 1001 101 1111 1111 1111 1111 1111
	stwio r18, 0(r10)

	#set interrupt bit
	movia r18, 0x10000000
	stwio r18, 8(r10)

	#enable PS2 interrupt
	movui r18, 0b1
	stwio r18, 4(r8)

	#enable interrupt
	movui r18, 0x081		#IRQ0 -> Timer1;IRQ7 -> PS2; IRQ11 -> LEGO controll JP1
	wrctl ctl3, r18			#enable ienable
	movui r18, 0b1
	wrctl ctl0,r18         	#Enable PIE bit

Loop:
	# rdctl r19, ctl0
	# rdctl r20, ctl3
	# rdctl r21, ctl4

	movi r17, 0

	addi sp, sp, -40
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)
	stw r12, 16(sp)
	stw r13, 20(sp)
	stw r14, 24(sp)
	stw r15, 28(sp)
	stw r16, 32(sp)
	stw r17, 36(sp) 
	call check_speed
	ldw r8, 0(sp)
	ldw r9, 4(sp)
	ldw r10, 8(sp)
	ldw r11, 12(sp)
	ldw r12, 16(sp)
	ldw r13, 20(sp)
	ldw r14, 24(sp)
	ldw r15, 28(sp)
	ldw r16, 32(sp)
	ldw r17, 36(sp)	
	addi sp, sp, 40

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

	addi sp, sp, -40
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)
	stw r12, 16(sp)
	stw r13, 20(sp)
	stw r14, 24(sp)
	stw r15, 28(sp)
	stw r16, 32(sp)
	stw r17, 36(sp)

	movia r8, ADDR_PS2
	movia r9, RED_LED
	movia r10, ADDR_LEGO_JP1
	movia r11, TIMER_1
	movia r13, TIMER_2
	
	rdctl et, ctl4
	andi et, et, 0b1
	bne et, r0, Handler_Timer_1

	rdctl et, ctl4
	andi et, et, 0x80
	bne et, r0, Handler_PS2

	rdctl et, ctl4
	andi et, et, 0x800
	bne et, r0, Handler_Sensor

	br Return

Handler_PS2:
	ldwio et, 0(r8)
	ldbio et, 0(r8)
	# movia r14, RED_LED
	stwio et, 0(r9)

	movui r18, 0x16			#1
	beq	et, r18, Speed_set_1
	movui r18, 0x1E			#2
	beq	et, r18, Speed_set_2
	movui r18, 0x26			#3
	beq	et, r18, Speed_set_3
	movui r18, 0x25			#4
	beq	et, r18, Speed_set_4
	movui r18, 0x2E			#5
	beq	et, r18, Speed_set_5
	
	br Return

Speed_set_1:
	movui r12, 1
	movia r18, CURRENT_SET
	sth r12, 0(r18)	
	movia r18, SPEED_COUNTER
	sth r0, 0(r18)
	br Return
	
Speed_set_2:
	movui r12, 2
	movia r18, CURRENT_SET
	sth r12, 0(r18)
	movia r18, SPEED_COUNTER
	sth r0, 0(r18)			
	br Return
	
Speed_set_3:
	movui r12, 3
	movia r18, CURRENT_SET
	sth r12, 0(r18)
	movia r18, SPEED_COUNTER
	sth r0, 0(r18)			
	br Return	
	
Speed_set_4:
	movui r12, 4
	movia r18, CURRENT_SET
	sth r12, 0(r18)	
	movia r18, SPEED_COUNTER
	sth r0, 0(r18)			
	br Return	

Speed_set_5:
	movui r12, 5
	movia r18, CURRENT_SET
	sth r12, 0(r18)
	movia r18, SPEED_COUNTER
	sth r0, 0(r18)				
	br Return


Handler_Sensor:
	stwio r0, 16(r13)
	stwio r0, 20(r13)
	mov r18, r0
	mov r19, r0
	bne r14, r0, Save_snapshot

Read_new_snapshot:	
	ldhuio r18, 16(r13)
	mov r14, r18
	ldhuio r18, 20(r13)
	slli r18, r18, 16
	or r14, r14, r18

	movia r18, 0xFFFFFFFF			#acknowledge LEGO controller
	stwio r18,12(r10)

	bne r19, r0, Update_gap

	br Return

Update_gap:
	bgt r14, r19, Negative_gap
	sub r15, r19, r14
	br Calculate_rpm

Negative_gap:
	mov r15, r19
	movia et, PERIOD_TIMER2
	sub r18, r14, et
	sub r18, r0, r18
	add r15, r15, r18
	br Calculate_rpm

Calculate_rpm:
	movia r18, 3000000000
	divu et, r18, r15
	muli r16, et, 2
	movia r18, CURRENT_RPM
	stw r16, 0(r18)
	# stwio r16, 0(r9)
	br Return 

Save_snapshot:
	mov r19, r14
	br Read_new_snapshot

Handler_Timer_1:
	#movui r18, 0b10
	ldhuio r18, 0(r10)       			#load current motor status	
	andi r19, r18, 0x0001
	bne r19, r0, TURN_ON
	movia r18, MAX_COUNTER
	ldhu et, 0(r18)
	movia r18, SPEED_COUNTER
	ldhu r19, 0(r18)
	blt r19, et, ADD_1
	beq r19, et, Reset_counter
	bgt r19, et, Reset_counter
	stwio r0, 0(r11)
	
	br Return

ADD_1:
	addi r19, r19, 1
	sth r19, 0(r18)
	br Return

Reset_counter:
	sth r0, 0(r18)

	ldwio r18, 0(r10)       			#load current motor status
	ori r18, r18, 0b0101
	stwio r18, 0(r10)

	br Return

TURN_ON:
	ldwio r18, 0(r10)       			#load current motor status
	andi r18, r18, 0b1010				#turn off
	stwio r18, 0(r10)
	br Return

Return:
	# ldw et, 0(sp)
	# wrctl ctl1,et
	# ldw et, 4(sp)
	# ldw ea, 8(sp)
	# addi sp, sp, 12
	subi ea,ea,4

	ldw r8, 0(sp)
	ldw r9, 4(sp)
	ldw r10, 8(sp)
	ldw r11, 12(sp)
	ldw r12, 16(sp)
	ldw r13, 20(sp)
	ldw r14, 24(sp)
	ldw r15, 28(sp)
	ldw r16, 32(sp)
	ldw r17, 36(sp)	
	addi sp, sp, 40
	eret


#========================Routine=======================#

check_speed:

	movia r8, CURRENT_SET
	ldhu r9, 0(r8)
	movia r8, MAX_COUNTER
	ldhu r10, 0(r8)

	movia r18, CURRENT_ANGLE
	ldw r17, 0(r18)

	movi r11, -10
	blt r17, r11, Break
	movui r11, 10
	bgt r17, r11, Accelerate

	sth r9, 0(r8)

end:
	ret


Break:
	movi r11, -20
	blt r17, r11, Break_harder
	subi r9, r9, 1
	sth r9, 0(r8)

	br end

Break_harder:
	movi r12, 2
	blt r9, r12, Zero
	subi r9, r9, 2
	sth r9, 0(r8)
	br end

Zero:
	sth r0, 0(r8)
	br end

Accelerate:
	movi r11, 20
	bgt r17, r11, Acc_harder
	addi r9, r9, 1
	sth r9, 0(r8)
	br end

Acc_harder:
	addi r9, r9, 2
	sth r9, 0(r8)
	br end
