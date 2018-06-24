IMG := ExOS.img
BOOT_BIN  := boot.img
KERNEL_BIN := kernel.img
BOOT_SRC := boot.asm
KERNEL_SRC := kernel.asm
ASM := nasm
ASM_OP := -f bin

BIN  += $(BOOT_BIN) $(KERNEL_BIN) $(IMG)

default: image

image: boot kernel
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMG)

boot: $(BOOT_SRC)
	$(ASM) $(ASM_OP) $(BOOT_SRC) -o $(BOOT_BIN)

kernel: $(KERNEL_SRC)
	$(ASM) $(ASM_OP) $(KERNEL_SRC) -o $(KERNEL_BIN)

run: $(IMG)
	qemu-system-x86_64 -fda $(IMG)

clean-all:
	rm -rf $(BIN)
clean: $(BIN)
	rm $(BIN)
