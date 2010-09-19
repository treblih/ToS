ASFLAGS	+=	-I../include/ -gstabs+
#CFLAGS	+=	-fPIC
OBJS	:=	libs.o libc.o puts.o printf.o kmalloc.o bitvec.o

.PHONY	:	all clean

all	:	$(OBJS)
clean	:
	-rm *.o
