ASFLAGS	+=	-I../include/ -gstabs+
OBJS	:=	gdt.o idt.o pit.o pic.o hal.o cpu.o pmem.o kb_s.o
#OBJS	:=	gdt.o idt.o pit.o pic.o hal.o cpu.o

.PHONY	:	all clean

all	:$(OBJS)
clean	:
	-rm *.o
