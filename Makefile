CFLAGS	:=	-I../include/ -fno-builtin -nostdlib -nostdinc -std=gnu99
LDFLAGS	:=	-Ttext
LDSCRIPT:=	-Tlink.ld
MAKE	:= 	make
export

DIRS	:=	boot/ kernel/ hal/ lib/
KRNL	:=	kernel.elf
IMG	:=	a.img
FLOPPY	:=	/media/floppy


.PHONY	:	all cascading install clean

all	:	clean cascading $(KRNL) install

# essential ';'	-- 
# make -C boot/; make -C kernel/; make -C hal/; make -C lib/
# dir spans within the foreach
cascading:
	$(foreach dir, $(DIRS), $(MAKE) -C $(dir);)

# after cascading, *.o appear in respective dir
# kernel.o must be the 1st to link into kernel.elf
$(KRNL)	:	OBJS = $(wildcard kernel/*.o lib/*.o hal/*.o)
#$(KRNL)	:	OBJS = $(wildcard  kernel/*.o lib/*.o hal/*.o)
$(KRNL)	:
	#$(LD) $(LDFLAGS) 0x100100 $(OBJS) -o $(@)
	$(LD) $(LDSCRIPT) $(OBJS) -o $(@)
install	:
	@/usr/local/bin/bximage
	@dd if=boot/boot.bin of=$(IMG) bs=512 count=1 conv=notrunc
	#@dd if=boot/grub/stage1 of=$(IMG) bs=512 count=1 conv=notrunc 
	#@dd if=boot/grub/stage2 of=$(IMG) bs=512 seek=1 conv=notrunc
	#@dd if=$(KRNL) of=a.elf skip=1
	#@objcopy -R .pdr -R .comment -R .note -S -O binary $(KRNL) a.elf
	#@mv a.elf $(KRNL) -f
	@sudo mount -o loop $(IMG) $(FLOPPY)
	#@sudo cp boot/ $(FLOPPY) -rfv
	@sudo cp boot/loader.bin $(FLOPPY) -fv 
	@sudo cp $(KRNL) $(FLOPPY) -fv 
	#@sudo cp initrd.img $(FLOPPY) -fv
	@sudo umount $(FLOPPY) 

clean	:	MAKE += clean
clean	:
	$(foreach dir, $(DIRS), $(MAKE) -C $(dir);)
	-rm $(KRNL) $(IMG) -f
