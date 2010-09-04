.equ	GDT_32, 0x4000
.equ	GDT_4K, 0x8000
.equ	GDT_RW, 0x92
.equ	GDT_X, 0x98
.equ	GDT_RX, 0x9a

.equ	IDT_IGATE, 0x8e

.equ	DPL0, 0
.equ	DPL1, 0x20
.equ	DPL2, 0x40
.equ	DPL3, 0x60

.equ	slc_krnl_rx, 0x08
.equ	slc_krnl_rw, 0x10

.equ	idt_dst, 0x500		# 0x500 - 0xeff
.equ	gdt_dst, 0xd00


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
