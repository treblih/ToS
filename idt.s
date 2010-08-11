.include "pmode.h"

.globl	__trans_idt

__trans_idt:
	pushl	%eax
	movw	__idtr, %ax
	movzx	%ax, %eax
	pushl	%eax		# how many
	pushl	$idt_dst
	pushl	$__idt
	call	strcpy
	addl	$12, %esp

	# update __idtr
	movl	$idt_dst, %eax
	movl	%eax, __idtr + 2
	lidt	__idtr

	popl	%eax
	ret

#-----------------------------------------------------------------------------
#  should have follow the sequence
#  INTEL occupied 0x08 - 0x0f, in real mode they're reserved for IRQ
#
#  cpu generated exceptions(trap/fault/abort):
#  err_code - eip - cs - eflags
#-----------------------------------------------------------------------------
__idt:
idt	slc_krnl_rx, __divide_error		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __single_step_exception	, IDT_IGATE | DPL0
idt	slc_krnl_rx, __nmi			, IDT_IGATE | DPL0
	# user
idt	slc_krnl_rx, __breakpoint_exception	, IDT_IGATE | DPL3 
	# user unique ins -- INTO
idt	slc_krnl_rx, __overflow		  	, IDT_IGATE | DPL3 
idt	slc_krnl_rx, __bounds_check		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __inval_opcode		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __copr_not_available	, IDT_IGATE | DPL0
idt	slc_krnl_rx, __double_fault		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __copr_seg_overrun		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __inval_tss		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __segment_not_present	, IDT_IGATE | DPL0
idt	slc_krnl_rx, __stack_exception		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __general_protection	, IDT_IGATE | DPL0
idt	slc_krnl_rx, __page_fault		, IDT_IGATE | DPL0
	# 0x0f INTEL reserved
idt	slc_krnl_rx, __copr_error		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __fpu_fault		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __align_fault		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __machine_abort		, IDT_IGATE | DPL0
idt	slc_krnl_rx, __simd_fault		, IDT_IGATE | DPL0

__idtr:		.word __idtr - __idt - 1
		.long __idt
