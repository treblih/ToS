#CFLAGS	:=	-I../include/ -strip -fno-builtin -std=gnu99
CFLAGS	:=	-I../include/ -gstabs+ -fno-builtin -std=gnu99
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
	@$(foreach dir, $(DIRS), $(MAKE) -C $(dir);)

# after cascading, *.o appear in respective dir
# kernel.o must be the 1st to link into kernel.elf
$(KRNL)	:	OBJS = $(wildcard  kernel/*.o lib/*.o hal/*.o)
#$(KRNL)	:	OBJS = $(wildcard  kernel/*.o lib/*.o hal/*.o)
$(KRNL)	:
	$(LD) $(LDSCRIPT) $(OBJS) -o $(@)
install	:
	@/usr/local/bin/bximage
	@dd if=boot/boot.bin of=$(IMG) bs=512 count=1 conv=notrunc 
	#@dd if=$(KRNL) of=a.elf skip=1
	#@objcopy -R .pdr -R .comment -R .note -S -O binary $(KRNL) a.elf
	#@mv a.elf $(KRNL) -f
	@sudo mount -o loop $(IMG) $(FLOPPY)
	@sudo cp boot/loader.bin $(FLOPPY) -fv 
	@sudo cp $(KRNL) $(FLOPPY) -fv 
	@sudo umount $(FLOPPY) 

clean	:	MAKE += clean
clean	:
	$(foreach dir, $(DIRS), $(MAKE) -C $(dir);)
	-rm $(KRNL) $(IMG)
