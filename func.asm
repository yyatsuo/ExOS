USE32

global  io_hlt
global  write_mem8

section .text

io_hlt:
  HLT
  RET

