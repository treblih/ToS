.include "pmode.h"

.globl	__pit_init


# void __idt_set(void *dst, void *offset, int attr, int slc)
__pit_init:
	pushl	$slc_krnl_rx
	pushl	$IDT_IGATE | DPL0
	pushl	$pit_handler
	pushl	$0x20		# 1st in PIC
	call	__idt_set
	ret

pit_handler:
	addl	$1, pit_cnt
	pushl	$0		# no.0
	call	__interrupt_done
	ret

pit_cnt:	.long 0
