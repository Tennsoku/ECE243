.equ ADDR_CHAR, 0x09000000
.global _start
_start:
#x + 128*y
Print_Speed:
movi r16,0x3e	
addi sp,sp,-4
stw ra,0(sp)
movia r15,ADDR_CHAR

movi r8,0x43 #C
stbio r8,1(r15) 
movi r8,0x55 #U
stbio r8,2(r15)
movi r8,0x52 #R
stbio r8,3(r15)
movi r8,0x52 #R
stbio r8,4(r15)
movi r8,0x45 #E
stbio r8,5(r15)
movi r8,0x4E #N
stbio r8,6(r15)
movi r8,0x54 #T
stbio r8,7(r15)
movi r8,0x20 #SPACE
stbio r8,8(r15)
movi r8,0x53 #S
stbio r8,9(r15) 
movi r8,0x50 #P
stbio r8,10(r15)
movi r8,0x45 #E
stbio r8,11(r15)
movi r8,0x45 #E
stbio r8,12(r15)
movi r8,0x44 #D
stbio r8,13(r15)
movi r8,0x3A #:
stbio r8,14(r15)
movi r8,0x20 #SPACE
stbio r8,15(r15)

movi r20,9

#CONTINUE:
andi r10,r16,0x0f
andi r11,r16,0xf0
slli r11,r11,4
bgt r10,r20,LEAST_CONVERSION
cont_3:
bgt r11,r20,SECOND_CONVERSION
cont_4:
srli r13,r11,4
add r12,r12,r13


addi r10,r10,48
addi r11,r11,48
addi r12,r12,48
#andi r9,r16,0x0f
#bgt r9,r20,GREATER_CONVERSION_1
#br LESS_CONVERSION_1
cont_1:
#mov r10,r9

#movi r20,9
#andi r9,r16,0xf0
#srli r9,r9,4
#bgt r9,r20,GREATER_CONVERSION_2
#br LESS_CONVERSION_2
cont_2:
#mov r11,r9



stbio r10,18(r15)
stbio r11,17(r15)
stbio r12,16(r15)

LOOP:
br LOOP



GREATER_CONVERSION_1:
addi r9,r9,55
br cont_1

LESS_CONVERSION_1:
addi r9,r9,48
br cont_1

GREATER_CONVERSION_2:
addi r9,r9,55
br cont_2

LESS_CONVERSION_2:
addi r9,r9,48
br cont_2

LEAST_CONVERSION:
subi r10,r10,9
addi r11,r11,1
br cont_3

SECOND_CONVERSION:
subi r11,r11,9
addi r12,r12,1
br cont_4






