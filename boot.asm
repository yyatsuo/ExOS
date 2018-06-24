USE16
ORG 0x7c00

; ***** Memory Map *****
; 0x07c00 ----------------------
;         | BOOT               |
; 0x08000 ----------------------
;         | BOOT               |
; 0x08020 ----------------------
;         | Empty Programs     |
; 0x34fff ----------------------

; TODO Write BPB
JMP entry;
NOP

NCYL  EQU 10    ; Num of Cyliders to be read

; Program Entry Point
entry:
  ;Init Register
  MOV   AX, 0
  MOV   SS, AX
  MOV   DS, AX
  MOV   SP, 0x7c00

  MOV   AX, 0x0820
  MOV   ES, AX
  MOV   CH, 0       ; Cylinder:0
  MOV   DH, 0       ; HEAD: 0
  MOV   CL, 2       ; Sector: 2

read:
  MOV   SI, 0;      ; Reset error counter
retry:
  MOV   AH, 0x02    ; Read Disk
  MOV   AL, 1       ; Sector
  MOV   BX, 0       ; Buffer Address
  MOV   DL, 0x00    ; Drive A(Floppy)
  ;MOV   DL, 0x80    ; HDD
  INT   0x13        ; Call BIOS
  JNC   next        ; Read next if no error
  ADD   SI, 1       ; error counter ++
  CMP   SI, 5       ; if error counter > 5
  JAE   error       ; goto error
  MOV   AH, 0x00    ; else Reset Drive
  MOV   DL, 0x00
  INT   0x13
  JMP   retry       ; retry
next:
  MOV   AX, ES      ; AX = ES
  ADD   AX, 0x0020  ; AX += 0x0020
  MOV   ES, AX      ; ES = AX = AX + 0x020
  ADD   CL, 1       ; Cylinder:CL++
  CMP   CL, 18      ; if CL <= 18 then
  JBE   read        ; goto read
  MOV   CL, 1       ; else CL = 1
  ADD   DH, 1       ; DH++
  CMP   DH, 2       ; if DH < 2 then
  JB    read        ; goto read
  MOV   DH, 0       ; else DH = 0
  ADD   CH, 1       ; CH++
  CMP   CH, NCYL    ; if CH < NCYL then
  JB    read        ; goto read
  JMP   0x8400


; Print Error Message
error:
  MOV SI, emsg
  JMP cput

cput:
  MOV   AL, [SI]
  ADD   SI, 1
  CMP   AL, 0
  JE    sleep
  MOV   AH, 0x0e
  MOV   BH, 0x00
  MOV   BL, 0x07
  MOV   BX, 15
  INT   0x10
  JMP   cput

sleep:
  HLT
  JMP   sleep

emsg:
  DB  0x0a,0x0a,"LOAD ERROR!",0x00

fill:
  times 510-($-$$) DB 0
  DB    0x55
  DB    0xAA
  times 512 DB 0

