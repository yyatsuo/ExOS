IMG := ExOS.img
OS_SYS := os.sys

IPL_SRC := ipl.asm
IPL_BIN := ipl.img

PREBOOT_SRC := preboot.asm
PREBOOT_BIN := preboot.img

BOOTPACK_SRC := bootpack.c
BOOTPACK_OBJ := bootpack.o
BOOTPACK_BIN := bootpack.bin

FUNC_SRC := func.asm
FUNC_OBJ := func.o

ASM := nasm
ASM_OP := -f bin

GCC := gcc
GCC_OP := -c -m32 -fno-pic

LD := ld
LD_OP := -m elf_i386 -e OSMain

BIN  += $(IPL_BIN) $(PREBOOT_BIN) $(BOOTPACK_BIN) $(BOOTPACK_OBJ) $(FUNC_BIN) $(FUNC_OBJ) $(OS_SYS) $(IMG)

default: $(IMG)


$(IMG): $(IPL_BIN) $(OS_SYS)
	cat $(IPL_BIN) $(OS_SYS) > $(IMG)

$(OS_SYS): $(PREBOOT_BIN) $(BOOTPACK_BIN)
	cat $(PREBOOT_BIN) $(BOOTPACK_BIN) > $(OS_SYS)

$(IPL_BIN): $(IPL_SRC)
	$(ASM) $(ASM_OP) $(IPL_SRC) -o $(IPL_BIN)

$(PREBOOT_BIN): $(PREBOOT_SRC)
	$(ASM) $(ASM_OP) $(PREBOOT_SRC) -o $(PREBOOT_BIN)

$(BOOTPACK_BIN): $(BOOTPACK_OBJ) $(FUNC_OBJ)
	$(LD) $(LD_OP) -o $(BOOTPACK_BIN) -Tos.S $(BOOTPACK_OBJ) $(FUNC_OBJ)

$(BOOTPACK_OBJ): $(BOOTPACK_SRC)
	$(GCC) $(GCC_OP) -o $(BOOTPACK_OBJ) $(BOOTPACK_SRC)

$(FUNC_OBJ): $(FUNC_SRC)
	$(ASM) -f elf32 $(FUNC_SRC) -o $(FUNC_OBJ)

run: $(IMG)
	qemu-system-i386 -fda $(IMG)

debug: $(IMG)
	qemu-system-i386 -fda $(IMG) -gdb tcp::10000 -S &

clean-all:
	rm -rf $(BIN) $(IMG)

clean:
	rm -rf $(BIN)
