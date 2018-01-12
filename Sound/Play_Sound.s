.equ AUDIO_FIFO,0xFF203040
.section .data
.align 2
LOWEST_KEY:
.incbin "Metal.wav"
end1:
SECOND_LOWEST_KEY:
.incbin "Ding.wav"
end2:
LAST_KEY:
.incbin "Elevator.wav"
end4:

.section .text	
.global _start
_start:

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
movia r9,LOWEST_KEY
br PLAY_LOWEST_KEY
