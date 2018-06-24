USE16
ORG   0x08400
JMP   boot

msg:
  DB  0x0a,0x0a,"Booting Kernel...",0x00

boot:
  MOV SI, msg
cput:
  MOV   AL, [SI]
  ADD   SI, 1
  CMP   AL, 0
  JE    halt
  MOV   AH, 0x0e
  MOV   BH, 0x00
  MOV   BL, 0x07
  MOV   BX, 15
  INT   0x10
  JMP   cput

halt:
  HLT
  JMP halt
