#define GDT_32	0x4000
#define GDT_4K	0x8000
#define GDT_RW	0x92
#define GDT_X	0x98
#define GDT_RX	0x9a

#define DPL0	0
#define DPL1	0x20
#define DPL2	0x40
#define DPL3	0x60

#define __KERNEL_CS	0x08
#define __KERNEL_DS	0x10
#define	__USER_CS	0x73
#define	__USER_DS	0x7b

/* 0x500 - 0xeff */
#define idt_dst	0x500
#define gdt_dst	0xd00


.macro gdt base limit attr
	.word	\limit & 0xffff
	.word	\base & 0xffff
	.byte 	(\base >> 16) & 0xff
	.word	((\limit >> 8) & 0x0f00) | (\attr & 0xf0ff)
	.byte	(\base >> 24) & 0xff
.endm

.macro idt slc offset attr
	.word	\offset & 0xffff
	.word	\slc
	.byte	0
	.byte	\attr
	.word	(\offset >> 16) & 0xffff
.endm
