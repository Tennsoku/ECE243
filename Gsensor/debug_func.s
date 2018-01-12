#--debug
addi sp,sp,-32
stw r8,0(sp)
stw r9,4(sp)
stw r10,8(sp)
stw r11,12(sp)
stw r12,16(sp)
stw r13,20(sp)
stw r14,24(sp)
stw r15,28(sp)
mov r4,r2
call printDec
ldw r8,0(sp)
ldw r9,4(sp)
ldw r10,8(sp)
ldw r11,12(sp)
ldw r12,16(sp)
ldw r13,20(sp)
ldw r14,24(sp)
ldw r15,28(sp)
addi sp,sp,32
#--debug