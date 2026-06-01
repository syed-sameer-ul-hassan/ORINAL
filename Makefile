NASM ?= nasm
QEMU ?= qemu-system-x86_64
TARGET := build/boot.bin
DISK := build/disk.img
SRC := src/boot.asm

.PHONY: all clean run

all: $(DISK)

$(TARGET): $(SRC)
	@mkdir -p $(dir $@)
	$(NASM) -f bin $< -o $@

$(DISK): $(TARGET)
	@mkdir -p $(dir $@)
	dd if=/dev/zero of=$(DISK) bs=512 count=20480 status=none
	dd if=$(TARGET) of=$(DISK) bs=512 count=1 conv=notrunc status=none

run: $(DISK)
	$(QEMU) -machine pc -m 64 -boot c -drive format=raw,if=ide,file=$(DISK) -nographic -serial mon:stdio

clean:
	rm -rf build
