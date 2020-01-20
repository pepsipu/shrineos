all: setup bootloader kernel image

GAME_LIBS=$(wildcard src/games/*.a)

BUILD_DIR=build
OS_IMG=xinos.img

setup:
	mkdir -p ./$(BUILD_DIR)
	mkdir -p ./$(BUILD_DIR)/bootloader
	mkdir -p ./$(BUILD_DIR)/kernel

bootloader:
	# compile bootloader as raw machine code
	nasm -f elf32 -g3 -F dwarf src/boot/bootloader.asm -o $(BUILD_DIR)/bootloader/bootloader.o
	ld -Ttext=0x7c00 -melf_i386 $(BUILD_DIR)/bootloader/bootloader.o -o $(BUILD_DIR)/bootloader/bootloader.elf
	objcopy -O binary $(BUILD_DIR)/bootloader/bootloader.elf $(BUILD_DIR)/bootloader/bootloader.bin
kernel:
	# compile an object file of the kernel assuming a standard library won't be available
	gcc -ffreestanding -c src/kernel/kernel.c -I src -o $(BUILD_DIR)/kernel/kernel.o -m32 -fno-pic -no-pie -g -mgeneral-regs-only -mno-red-zone -fno-stack-protector -Os
	# link the kernel relative to 0x7f00 (we will load it at this address) as an elf, for debugging
	ld -o $(BUILD_DIR)/kernel/kernel.elf -T src/kernel/kernel.lds $(BUILD_DIR)/kernel/kernel.o $(GAME_LIBS) -melf_i386
	# create raw binary file of kernel
	objcopy -O binary $(BUILD_DIR)/kernel/kernel.elf $(BUILD_DIR)/kernel/kernel.bin
	echo kernel is `wc -c < $(BUILD_DIR)/kernel/kernel.bin` bytes

image:
	# create a blank image 512kb large
	dd if=/dev/zero of=$(BUILD_DIR)/$(OS_IMG) bs=1024 count=512
	# write bootloader and it's strings/data to first 1024 bytes (1kb)
	dd conv=notrunc if=$(BUILD_DIR)/bootloader/bootloader.bin of=$(BUILD_DIR)/$(OS_IMG) bs=512 count=2 seek=0
	# write kernel to the rest of image (arb size)
	dd conv=notrunc if=$(BUILD_DIR)/kernel/kernel.bin of=$(BUILD_DIR)/$(OS_IMG) bs=512 seek=2

clean:
	rm -r build