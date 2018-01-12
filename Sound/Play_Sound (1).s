.equ AUDIO_FIFO,0xFF203040
.section .data
.align 2
LOWEST_KEY:
.incbin "Sound1.wav"
end1:
SECOND_LOWEST_KEY:
.incbin "Sound2.wav"
end2:
MIDDLE_KEY:
.incbin "Sound3.wav"
end3:

.section .text
.global _start
_start:

movia r8,AUDIO_FIFO
movia r9,LOWEST_KEY
movia r10,end1

PLAY_LOWEST_KEY:
WAIT:
ldwio r11,4(r8)       #Read available space from the audio fifo data register
andhi r11,r11,65280   #Mask the left channel write available space
beq r11,r0,WAIT

ldwio r11,0(r9)
stwio r11,8(r8)


addi r9,r9,1

KEEP_PLAYING:
bne r9,r10,PLAY_LOWEST_KEY
movia r9,LOWEST_KEY
br PLAY_LOWEST_KEY

