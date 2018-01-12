
.global main
main:
.section .data
.align 2
LOWEST_KEY:
.incbin "C:/Users/olvan/OneDrive/ECE243/Project/Combined/Metal.wav"
end1:
SECOND_LOWEST_KEY:
.incbin "C:/Users/olvan/OneDrive/ECE243/Project/Combined/Ding.wav"
end2:
LAST_KEY:
.incbin "C:/Users/olvan/OneDrive/ECE243/Project/Combined/Elevator2.wav"
end4:

.align 1
SPEED_COUNTER:
	.hword	0

CURRENT_SET:
	.hword	1


MAX_COUNTER:
	.hword	1

.align 2
CURRENT_RPM:
	.word	0

CURRENT_ANGLE:
	.word	0

.section .text	
	.equ ADDR_VGA, 0x08000000
	.equ ADDR_CHAR, 0x09000000
	.equ GPIO_JP2, 0xFF200070
	.equ GPIO_JP1, 0xFF200060
	.equ RED_LED, 0xFF200000
	.equ TIMER, 0xff202000
	.equ PERIOD, 50000000
	.equ CLEAR_PERIOD, 4
	.equ AUDIO_FIFO,0xFF203040
	.equ ADDR_LEGO_JP1, 0xFF200060
	.equ ADDR_PS2, 0xFF200100
	.equ TIMER_1, 0xff202000 
	.equ TIMER_2, 0xff202020			#IRQ = 2
	.equ PERIOD_TIMER1, 2000000			#5M, 0.02s
	.equ PERIOD_TIMER2, 1000000000  	#1G, 10 sec





    movia sp,0x03fffffc
#initialize 1
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


# Initializa 2
	movi r8,CLEAR_PERIOD
	
	addi sp,sp,-4
	stw ra,0(sp)
	movi r12,100
	movi r11,100
#===Start of main routine====#	
	Drawing:
   
    #addi sp,sp,-20
    #stw r8,0(sp)
    #stw r9,4(sp)
    #stw r10,8(sp)
    #stw r11,12(sp)
    #stw r12,16(sp)
    #call PLAY_SOUND
    #ldw r8,0(sp)
    #ldw r9,4(sp)
    #ldw r10,8(sp)
    #ldw r11,12(sp)
    #ldw r12,16(sp)
    #addi sp,sp,20

#----Get G sensor reading---#	
	addi sp,sp,-20
	stw r8,0(sp)
	stw r9,4(sp)
	stw r10,8(sp)
	stw r13,12(sp)
	stw r14,16(sp)
	call Poll_G
	ldw r8,0(sp)
	ldw r9,4(sp)
	ldw r10,8(sp)
	ldw r13,12(sp)
	ldw r14,16(sp)
	addi sp,sp,20
    
#=---Check speed and current saved G sensor reading--#    
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
#-----Clean the previous screen---------#
	movi r13,100  #Assume r13 store the value of the total G
    bne r8,r0,NO_clear
	movi r8,CLEAR_PERIOD
	addi sp,sp, -28
	stw r8, 0(sp)
	stw r10, 4(sp)
	stw r4, 8(sp)
	stw r5, 12(sp)
	stw r6, 16(sp)
	stw r7, 20(sp)
	stw r12,24(sp)
	call CLEAR_SCREEN
	ldw r7, 20(sp)
	ldw r6, 16(sp)
	ldw r5, 12(sp)
	ldw r4, 8(sp)
	ldw r10, 4(sp)
	ldw r8, 0(sp)
	ldw r12,24(sp)
	addi sp,sp,28

    NO_clear:
    addi r8,r8,-1
	addi sp,sp,-4
    stw r8,0(sp)
#------------Draw the square-----------------#

#-----------------------y=80,x=100-0-----------------#
CONTI2:
movi r14,80  
movi r15,70 	

Y_80_X_100_TO_0:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14
mov r9,r15			
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)			
mov r7,r8   
mov r10,r9 
addi r7,r7,160
subi r10,r10,120 #120-r10
sub r10,r0,r10
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16	

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r14,r14,-1	
bne r0,r14,Y_80_X_100_TO_0

#-----------------------y=80,x=-100-0-----------------#
movi r14,-80  
movi r15,70 	

Y_80_X_N100_TO_0:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14
mov r9,r15			
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)			
mov r7,r8   
mov r10,r9 
addi r7,r7,160
subi r10,r10,120 #120-r10
sub r10,r0,r10
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16	

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r14,r14,1	
bne r0,r14,Y_80_X_N100_TO_0

 	

#-----------------------y=80-0,x=100-----------------#

movi r14,80  
movi r15,70

Y_80_TO_0_X_100:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14
mov r9,r15			
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)			
mov r7,r8   
mov r10,r9 
addi r7,r7,160
subi r10,r10,120 #120-r10
sub r10,r0,r10
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16	

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r15,r15,-1	
bne r0,r15,Y_80_TO_0_X_100

#------------------------y=-80-0,x=100----------------#
movi r14,80  
movi r15,-70
 	
Y_N80_TO_0_X_100:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14  
mov r9,r15 
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)			
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r15,r15,1
bne r15,r0,Y_N80_TO_0_X_100

#------------------------y=-80,x=100-0----------------#
movi r14,80  
movi r15,-70
 	
Y_N80_X_100_TO_O:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14  
mov r9,r15 
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)			
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r14,r14,-1
bne r14,r0,Y_N80_X_100_TO_O

#------------------------y=-80,x=-100-0----------------#

movi r14,-80  
movi r15,-70

Y_N80_X_N100_TO_0:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14  
mov r9,r15 
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)			
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r14,r14,1
bne r14,r0,Y_N80_X_N100_TO_0


#------------------------y=-80-0,x=-100----------------#

movi r14,-80  
movi r15,-70

Y_N80_TO_0_X_N100:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14  
mov r9,r15  
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)		
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r15,r15,1
bne r15,r0,Y_N80_TO_0_X_N100

#------------------------y=80-0,x=-100----------------#

movi r14,-80  
movi r15,70

Y_80_TO_0_X_N100:
addi sp,sp,-8
stw r14,0(sp)
stw r15,4(sp)

mov r8,r14  
mov r9,r15  
call Matrix_transform
addi sp,sp,-16
stw r8,0(sp)
stw r9,4(sp)
stw r11,8(sp)
stw r12,12(sp)		
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
ldw r11,8(sp)
ldw r12,12(sp)	
addi sp,sp,16

ldw r14,0(sp)
ldw r15,4(sp)
addi sp,sp,8

addi r15,r15,-1
bne r15,r0,Y_80_TO_0_X_N100

#----------End of square drawing--------------------#
   
ldw r8,0(sp)
addi sp,sp,4

br Drawing
#------------End of main routine--------------------#
ldw ra,0(sp)
addi sp,sp,4	
	
ret 	
#-----------------End of the routine----------------#
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

#------------------POll GPIO TO GET G SENSOR READING----#
Poll_G:
#pin list:
#pin 0 read_valid
#pin 1 X/Y
#pin 2 N/P
#pin 4-11 value	
#register list:
#r8 = JP2 Address
#r9 = current read value
#r10 = current flag
#r16 = N/P
#r17 = X/Y
#r13 = LED Address
#r14 = temp
	.equ GPIO_JP2, 0xFF200070
	.equ GPIO_JP1, 0xFF200060
	.equ RED_LED, 0xFF200000
	
	addi sp,sp,-12
	stw ra,0(sp)
	stw r16,4(sp)
	stw r17,8(sp)

	movia r8,GPIO_JP2
	movia r13,RED_LED

    load_flag:
	ldw r10, 0(r8)
	andi r14, r10, 0b1
	beq r14, r0, load_flag
		
	andi r14, r10, 0b10
	srli r14, r14, 1
	mov r16, r14
	
	andi r14, r10, 0b100
	srli r14, r14, 2
	mov r17, r14

	srli r10, r10, 4
	andi r10, r10, 0x000000ff
	muli r10,r10,2
		
print_LED:
	stwio r10, 0(r13)	
	beq r16,r0,NEG
	br POS
	
	NEG:
	sub r10,r0,r10 #Invert the sign
	br CONTI_X_Y
	POS:	
	CONTI_X_Y:
	beq r17,r0,Assign_Y
	br Assign_X
	Assign_Y:
    mov r12,r10 
	br Go_return
	Assign_X:
    mov r11,r10   #Assume r11 store Gx
	br Go_return

    #Store the current reading of x angle into the global variable
	movia r16,CURRENT_ANGLE
	stw r11,0(r16)
	
Go_return:
	
	
	ldw ra,0(sp)
	ldw r16,4(sp)
	ldw r17,8(sp)
	addi sp,sp,12
	ret
#------------------------------------Sound routine---------------------------------------#
PLAY_SOUND:


movia r8,AUDIO_FIFO
movia r9,LOWEST_KEY
movia r10,end4
ldwio r11,0(r8)
movia r12,0xfffffffc
and r11,r11,r12
stwio r11,0(r8)

PLAY_LOWEST_KEY:
movi r11,50
LOOPING:
addi r11,r11,-1
bne r11,r0,LOOPING

#WAIT:
#ldwio r11,4(r8)       #Read available space from the audio fifo data register

#andhi r11,r11,65280   #Mask the left channel write available space
#beq r11,r0,WAIT
#ldwio r11,4(r8)

#andhi r11,r11,255
#beq r11,r0,WAIT


ldwio r11,0(r9)
stwio r11,8(r8)
stwio r11,12(r8)


addi r9,r9,1

KEEP_PLAYING:
bne r9,r10,PLAY_LOWEST_KEY

ret

#------------------------Check Speed--------#
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
#----------------Clean screen--------------------#
#---------------CLEAR_SCREEN routine----------------#
CLEAR_SCREEN:
	movia r4, 0x0000			#black
	movia r5, 0b11110000		#length 240
	movia r12, 0b101000000		#width 320
	movia r6, 0b0			#startX
	movia r7, 0b0			#startY
	

DRAW_CS:
	movia r8, ADDR_VGA
	muli r9, r6, 2
	add r8, r8, r9
	muli r9, r7, 1024
	add r8, r8, r9
	sthio r4,0(r8) 				#pixel (r6,r7) offset is r8 = r2 + r6*2 + r7*1024
	
LOOP_X_CS:
	addi r6, r6, 1
	beq r6, r12, LOOP_Y_CS
	br DRAW_CS

LOOP_Y_CS:
	movia r6, 0b0
	addi r7, r7, 1
	beq r7, r5, END_CS
	br DRAW_CS

END_CS:
	ret
	#-----------------------Draw a pixel-----------------#
	#-------------------VGA routine---------------------#
Draw_screen:
	movia r11, 0xffff 			#Color = White
	
	movia r8, ADDR_VGA			#r8 = Final offset, inital = ADDR_VGA
	muli r9, r7, 2				#r9 = temp, now temp = x * 2
	add r8, r8, r9				#r8 = r8 + r9
	muli r9, r10, 1024			#temp = y * 1024
	add r8, r8, r9				#r8 = r8 + r9
	sthio r11,0(r8) 			#pixel (r7,r10) offset is r8 = ADDR_VGA + r7*2 + r10*1024
ret
    #-------------Matrix transformation-------------#
    #-------------------Routine used to transform x,y,z coordinates--------------#
Matrix_transform:

addi sp,sp,-4  #Save return adress before calling sub_routine
stw ra,0(sp)


addi sp,sp,-32
stw r8,0(sp)
stw r9,4(sp)
stw r10,8(sp)
stw r11,12(sp)
stw r12,16(sp)
stw r13,20(sp)
stw r14,24(sp)
stw r15,28(sp)


mov r4,r13     #First parameter is the total G
mov r5,r12     #Second parameter is Gy
# call get_cos_ratio #Tested: Works Function: Get the cos ratio timed by 1000
stw r2,28(sp)         #Store cos(thetay) into r15


ldw r13,20(sp) #Access the old value
ldw r11,12(sp) 
ldw r12,16(sp)

mov r4,r13     #First parameter is the total G
mov r5,r11     #Second parameter is Gx
# call get_cos_ratio
mov r16,r2     #Store cos(thetax) into r16








ldw r8,0(sp)
ldw r9,4(sp)
ldw r10,8(sp)
ldw r11,12(sp)
ldw r12,16(sp)
ldw r13,20(sp)
ldw r14,24(sp)
ldw r15,28(sp)
addi sp,sp,32

#-------Calculate new X---#
mul r19,r16,r8 #Costhetax*x
add r20,r20,r19
movi r21,1000
div r20,r20,r21   #Correct the ratio by dividing 1000

mov r4,r13
mov r5,r12

addi sp,sp,-32
stw r8,0(sp)
stw r9,4(sp)
stw r10,8(sp)
stw r11,12(sp)
stw r12,16(sp)
stw r13,20(sp)
stw r14,24(sp)
stw r15,28(sp)
# call get_cos_ratio
ldw r8,0(sp)
ldw r9,4(sp)
ldw r10,8(sp)
ldw r11,12(sp)
ldw r12,16(sp)
ldw r13,20(sp)
ldw r14,24(sp)
ldw r15,28(sp)
addi sp,sp,32

movi r3,1000
sub r2,r3,r2

mul r19,r2,r9
movi r21,1000
div r19,r19,r21

bgt r12,r0,X_SUB
br X_ADD

X_SUB:
bgt r8,r0,ADD_X
br SUB_X

X_ADD:
bgt r8,r0,SUB_X
br ADD_X

SUB_X:
sub r20,r20,r19
br CONTI_X

ADD_X:
add r20,r20,r19
br CONTI_X

CONTI_X:
addi sp,sp,-4
stw r20,0(sp)     #Store the transformed x coordinate onto stack
mov r20,r0        #Reset r20 

#-------Calculate new Y---#
mul r19,r9,r15    #y*cos(thetay)
movi r21,1000
div r19,r19,r21   #Correct the ratio by dividing 1000
add r20,r20,r19

mov r4,r13
mov r5,r11

addi sp,sp,-32
stw r8,0(sp)
stw r9,4(sp)
stw r10,8(sp)
stw r11,12(sp)
stw r12,16(sp)
stw r13,20(sp)
stw r14,24(sp)
stw r15,28(sp)
# call get_cos_ratio
ldw r8,0(sp)
ldw r9,4(sp)
ldw r10,8(sp)
ldw r11,12(sp)
ldw r12,16(sp)
ldw r13,20(sp)
ldw r14,24(sp)
ldw r15,28(sp)
addi sp,sp,32

movi r3,1000
sub r2,r3,r2

mul r19,r2,r8
movi r21,1000
div r19,r19,r21

bgt r11,r0,Y_SUB
br Y_ADD

Y_SUB:
bgt r9,r0,ADD_Y
br SUB_Y


Y_ADD:
bgt r9,r0,SUB_Y
br ADD_Y

ADD_Y:
add r20,r20,r19
br CONTI_Y

SUB_Y:
sub r20,r20,r19
br CONTI_Y

CONTI_Y:
addi sp,sp,-4
stw r20,0(sp)
mov r20,r0        #Reset r20

#------Calculate new z---#

#---Assign new x,y,z to x,y,z registers--#

ldw r9,0(sp)
addi sp,sp,4

ldw r8,0(sp)
addi sp,sp,4

ldw ra,0(sp)
addi sp,sp,4

ret
#-------End of subroutine---------------------#


