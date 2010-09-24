ASFLAGS	+=	-I../include/ -gstabs+
OBJS	:=	gdt.o idt.o pic.o hal.o cpu.o pmem.o pit.o kb_s.o kb_c.o
#OBJS	:=	gdt.o idt.o pit.o pic.o hal.o cpu.o

.PHONY	:	all clean

all	:$(OBJS)
clean	:
	-rm *.o -f
