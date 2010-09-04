CFLAGS	+=	-I../include/ -gstabs+ -fno-builtin -c
OBJS	:=	lib.o puts.o

.PHONY	:	all clean

all	:	$(OBJS)
$(OBJS) :	%.o	:%.s
	$(CC) $(CFLAGS) $< -o $@
clean	:
	-rm *.o
