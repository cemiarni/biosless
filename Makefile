
all:
	yasm -fbin code.asm
	dd if=/dev/zero of=rom bs=65536 count=1
	dd if=code of=rom conv=notrunc

