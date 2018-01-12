.global start2
	.equ ADDR_VGA, 0x08000000
	.equ ADDR_CHAR, 0x09000000
movia sp,0x03fffffc
movi r11,70   #Assume r11 store Gx
movi r12,20   #Assume r12 store Gy
movi r13,100  #Assume r13 store the value of the total G
start2:

addi sp,sp,-4
stw ra,0(sp)

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


movi r8,100  
movi r9,80  
movi r10,0 	
movi r11,80   #Assume r11 store Gx
movi r12,40   #Assume r12 store Gy
movi r13,100  #Assume r13 store the value of the total G
call Matrix_transform
addi sp,sp,-8
stw r8,0(sp)
stw r9,4(sp)		
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
subi r10,r10,120 #120-r10
sub r10,r0,r10
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
addi sp,sp,8		


movi r8,100  
movi r9,-80  
movi r10,20 	
movi r11,80   #Assume r11 store Gx
movi r12,-40   #Assume r12 store Gy
movi r13,100  #Assume r13 store the value of the total G
call Matrix_transform
addi sp,sp,-8
stw r8,0(sp)
stw r9,4(sp)		
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
addi sp,sp,8


movi r8,-100  
movi r9,-80  
movi r10,0 	
movi r11,-80   #Assume r11 store Gx
movi r12,-40   #Assume r12 store Gy
movi r13,100  #Assume r13 store the value of the total G
call Matrix_transform
addi sp,sp,-8
stw r8,0(sp)
stw r9,4(sp)		
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
addi sp,sp,8


movi r8,-100  
movi r9,80  
movi r10,0 	
movi r11,-80   #Assume r11 store Gx
movi r12,40   #Assume r12 store Gy
movi r13,100  #Assume r13 store the value of the total G
call Matrix_transform
addi sp,sp,-8
stw r8,0(sp)
stw r9,4(sp)		
mov r7,r8   #Move transformed y into r7  
mov r10,r9 #Move transformed x into r10	
addi r7,r7,160
sub r10,r0,r10 #-r10
addi r10,r10,120
call Draw_screen
ldw r8,0(sp)
ldw r9,4(sp)
addi sp,sp,8




	
ldw ra,0(sp)
addi sp,sp,4

br start2	
	
ret 	
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
call get_cos_ratio #Tested: Works Function: Get the cos ratio timed by 1000
stw r2,28(sp)         #Store cos(thetay) into r15



 
ldw r13,20(sp)
ldw r11,12(sp) 
ldw r12,16(sp)

mov r4,r13     #First parameter is the total G
mov r5,r11     #Second parameter is Gx
call get_cos_ratio
mov r16,r2     #Store cos(thetax) into r16

ldw r13,20(sp)
ldw r11,12(sp) 
ldw r12,16(sp) 

mov r4,r13
mov r5,r12     #Second parameter is Gy
call get_sin_ratio
mov r17,r2     #Store sin(thetay) into r17

ldw r13,20(sp)
ldw r11,12(sp) 
ldw r12,16(sp)
 
mov r4,r13     #First parameter is the total G
mov r5,r11     #Second parameter is Gx
call get_sin_ratio
mov r18,r2     #Store sin(thetax) into r18


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
mul r19,r15,r8 #Cosy*x
add r20,r20,r19
mul r19,r17,r10    #Siny*z
sub r20,r20,r19    #Cosy*x-siny*z
movi r21,1000
div r20,r20,r21   #Correct the ratio by dividing 1000



addi sp,sp,-4
stw r20,0(sp)     #Store the transformed x coordinate onto stack
mov r20,r0        #Reset r20 

#-------Calculate new Y---#
mul r19,r18,r17   #sin(-thetax)*sin(-thetay)=sin(thetax)*sin(thetay)
mul r19,r19,r8    #r9=sin(thetax)*sin(thetay)*x

movia r21,1000000
div r19,r19,r21   #Correct the ratio by dividing 1000000



add r20,r20,r19

mul r19,r9,r16    #y*cos(thetax)

movi r21,1000
div r19,r19,r21   #Correct the ratio by dividing 1000
add r20,r20,r19

mul r19,r18,r15   #sin(thetax)*cos(thetay)
mul r19,r19,r10   #sin(thetax)*cos(thetay)*z
movia r21,1000000
div r19,r19,r21   #Correct the ratio by dividing 1000000
add r20,r20,r19   



addi sp,sp,-4
stw r20,0(sp)
mov r20,r0        #Reset r20

#------Calculate new z---#

mul r19,r17,r16   #-sin(-thetay)*cos(-thetax)
mul r19,r19,r8    #-sin(-thetay)*cos(-thetax)*x
movia r21,1000000
div r19,r19,r21   #Correct the ratio by dividing 1000000
add r20,r20,r19

mul r19,r18,r9    #sin(thetax)*y
movi r21,1000
div r19,r19,r21   #Correct the ratio by dividing 1000
sub r20,r20,r19

mul r19,r15,r16
mul r19,r19,r10
movia r21,1000000
div r19,r19,r21   #Correct the ratio by dividing 1000000
add r20,r20,r19

addi sp,sp,-4
stw r20,0(sp)
mov r20,r0

#---Assign new x,y,z to x,y,z registers--#


ldw r10,0(sp)
addi sp,sp,4

ldw r9,0(sp)
addi sp,sp,4


ldw r8,0(sp)
addi sp,sp,4

 
ldw ra,0(sp)
addi sp,sp,4

ret

#-------------------End of the routine--------------#

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
#-----------------End of the routine----------------#

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
#-----------------End of the routine----------------#