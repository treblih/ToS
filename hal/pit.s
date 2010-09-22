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

	# enable the IRQ
	pushl	$pit_handler
	pushl	$0
	call	__irq_enable
	addl	$8, %esp

	popl	%eax
	ret

	.type	__get_pit_cnt, @function
__get_pit_cnt:
	movl	jiffies, %eax
	ret

	.type	pit_handler, @function
pit_handler:
	addl	$1, jiffies
	ret

.section .data
jiffies: .long 0
