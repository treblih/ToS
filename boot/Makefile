ASFLAGS	+=	-I../include/
OBJCOPY	:=	objcopy
OBJFLAGS:=	-R .pdr -R .comment -R .note -S -O binary

BIN	:=	boot.bin loader.bin
ELF	:=	boot.elf loader.elf

.PHONY	:	all clean

all	:	$(BIN)
$(BIN)	:	%.bin	:%.elf
	$(OBJCOPY) $(OBJFLAGS) $< $@
boot.elf:	boot.o
	$(LD) $(LDFLAGS) 0x7c00 $< -o $@
loader.elf:	loader.o
	$(LD) $(LDFLAGS) 0x500 $< -o $@

clean	:
	rm *.o *.elf *.bin
