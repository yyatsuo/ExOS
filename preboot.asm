USE16
ORG   0x08400
JMP   boot

BOTPAK  EQU   0x00280000  ;bootpack
DSKCAC  EQU   0x00100000  ;disk cache
DSKCAC0 EQU   0x00008000  ;disk cache (REALMODE)

CYLS    EQU   0x0FF0
LEDS    EQU   0x0FF1
VMODE   EQU   0x0FF2
SCRNX   EQU   0x0FF4
SCRNY   EQU   0x0FF6
VRAM    EQU   0x0FF8

boot:
  MOV   AL, 0x13    ;VGA Graphics 320x200x8bit color
  MOV   AH, 0x00
  INT   0x10

  ; Store Screen Params
  MOV   BYTE  [VMODE], 0x8
  MOV   WORD  [SCRNX], 320
  MOV   WORD  [SCRNY], 200
  MOV   DWORD [VRAM],  0x000a0000

  ; Store Keyboard LED status
  MOV   AH, 0X02
  INT   0x16
  MOV   [LEDS], AL

  ; Disable Interrupts
  MOV   AL, 0xFF
  OUT   0x21, AL
  NOP
  OUT   0xA1, AL
  CLI

  ; Enable A20 Line
  CALL  waitkbdout
  MOV   AL, 0xD1
  OUT   0x64, AL
  CALL  waitkbdout
  MOV   AL, 0xDF
  OUT   0x60, AL
  CALL waitkbdout

  ; Transition From Real to Protected
  ; Load GDT
  LGDT  [GDTR0]
  MOV   EAX, CR0
  AND   EAX, 0x7FFFFFFF   ; Disable Paging
  OR    EAX, 0x00000001   ; Enable BIT0 (For protected mode)
  MOV   CR0, EAX

pipelineflush:
  ; Flush pipeline
  MOV   AX, 1*8
  MOV   DS, AX
  MOV   ES, AX
  MOV   FS, AX
  MOV   GS, AX
  MOV   SS, AX

; copy bootpack
  MOV   ESI, bootpack
  MOV   EDI, BOTPAK
  MOV   ECX, 512*1024/4
  CALL  memcpy

; copy disk data
  MOV   ESI, 0x7c00
  MOV   EDI, DSKCAC
  MOV   ECX, 512/4
  CALL  memcpy

; copy other data
  MOV   ESI, DSKCAC0+512
  MOV   EDI, DSKCAC+512
  MOV   ECX, 0
  MOV   CL, BYTE [CYLS]
  IMUL  ECX, 512*18*2/4
  SUB   ECX, 512/4
  CALL  memcpy

;start bootpack
  MOV   EBX, BOTPAK
  MOV   ECX, [EBX+16]
  ADD   ECX, 3
  SHR   ECX, 2
  JZ    skip
  MOV   ESI, [EBX+20]
  ADD   ESI, EBX
  MOV   EDI, [EBX+12]
  CALL  memcpy

skip:
  MOV   ESP, [EBX+12]
  JMP   DWORD 2*8:0x0000001b

waitkbdout:
  IN    AL, 0x64
  AND   AL, 0x02
  JNZ   waitkbdout
  RET

memcpy:
  MOV   EAX, [ESI]
  ADD   ESI, 4
  MOV   [EDI], EAX
  ADD   EDI, 4
  SUB   ECX, 1
  JNZ   memcpy
  RET

ALIGNB  16
GDT0:
  RESB  8               ; Null Selector

  ; GDT 1
  DW    0xFFFF          ; Limit 0-15bit 0xFFFF
  DW    0x0000          ; Base Address  0-15bit
  DB    0x00            ; Base address 16-23bit
  DB    0x92            ; 10010010
                        ; || ||  +--:A   : 0
                        ; || |+-----:TYPE: 001
                        ; || +------:S   : 1
                        ; |+--------:DPL : 00
                        ; +---------:P   : 1
  DB    0xCF            ; 11001111
                        ; ||||+-----:Limit 16-19bit: 0xF
                        ; |||+------:AVL :0
                        ; ||+-------:FIX :0
                        ; |+--------:D   :1 (32bit)
                        ; +---------:G   :1
  DB    0x00            ; Base Address 24-31 bit

  ; GDT 2
  DW    0xFFFF,0x0000,0x9a28,0x0047

GDTR0:
  DW    8*3-1
  DD    GDT0

ALIGNB  16

bootpack:
