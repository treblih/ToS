.include "pmode.inc"
.include "pic.inc"

.section .text

.globl	__pit_init
.globl	__get_pit_cnt

.equ	TC0,	0x40
.equ	TMCR,	0x43
.equ	RATE_GENERATOR,	0x34

# void __idt_set(void *dst, void *offset, int attr, int slc)
	.type	__pit_init, @function
__pit_init:
	pushl	%eax

	# set ratio
	# 0x2e9b == 11931 == 1193182 / 100
	mov	$RATE_GENERATOR, %eax
	outb	$TMCR
	movb	$0x9b, %al
	outb	$TC0
	movb	$0x2e, %al
	outb	$TC0

	# awake in IDT
	pushl	$slc_krnl_rx
	pushl	$IDT_IGATE | DPL0
	pushl	$pit_handler
	pushl	$0x20		# 1st in PIC
	call	__idt_set
	addl	$16, %esp

	# enable the IRQ
	pushl	$IRQ_TIMER
	call	__irq_enable
	addl	$4, %esp

	popl	%eax
	ret

	.type	__get_pit_cnt, @function
__get_pit_cnt:
	movl	pit_cnt, %eax
	ret

	.type	pit_handler, @function
pit_handler:
	cli
	addl	$1, pit_cnt
	pushl	$0		# no.0
	call	__interrupt_done
	addl	$4, %esp
	sti
	ret

.section .bss
.lcomm pit_cnt, 4
