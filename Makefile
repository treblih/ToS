LDFLAGS	:=	-Ttext
MAKE	:= 	make
export

DIRS	:=	boot/ kernel/ hal/ lib/
KRNL	:=	kernel.elf
IMG	:=	a.img
FLOPPY	:=	/media/floppy


.PHONY	:	all cascading install clean

all	:	cascading $(KRNL) install

# essential ';'	-- 
# make -C boot/; make -C kernel/; make -C hal/; make -C lib/
# dir spans within the foreach
cascading:
	$(foreach dir, $(DIRS), $(MAKE) -C $(dir);)

# after cascading, *.o appear in respective dir
# kernel.o must be the 1st to link into kernel.elf
$(KRNL)	:	OBJS = $(wildcard  kernel/*.o) $(wildcard  lib/*.o) $(wildcard hal/*.o)
$(KRNL)	:
	$(LD) $(LDFLAGS) 0x20100 $(OBJS) -o $(@)
install	:
	@/usr/local/bin/bximage
	@dd if=boot/boot.bin of=$(IMG) bs=512 count=1 conv=notrunc 
	@sudo mount -o loop $(IMG) $(FLOPPY)
	@sudo cp boot/loader.bin $(FLOPPY) -fv 
	@sudo cp $(KRNL) $(FLOPPY) -fv 
	@sudo umount $(FLOPPY) 

clean	:	MAKE += clean
clean	:
	$(foreach dir, $(DIRS), $(MAKE) -C $(dir);)
	-rm $(KRNL) $(IMG)