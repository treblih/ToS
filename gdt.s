.include "pmode.h"

.globl	__trans_gdt

__trans_gdt:
	pushl	%eax
	movw	__gdtr, %ax
	movzx	%ax, %eax
	pushl	%eax		# how many
	pushl	$gdt_dst
	pushl	$__gdt
	call	strcpy
	addl	$12, %esp

	# update __gdtr
	movl	$gdt_dst, %eax
	movl	%eax, __gdtr + 2
	lgdt	__gdtr
	call	flush_sreg

	popl	%eax
	ret

flush_sreg:
	jmp	$slc_krnl_rx, $.flush_sreg  # flush cs
  .flush_sreg:
	xor	%eax,	%eax
	movw	$slc_krnl_rw, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss
	ret

__gdt:
__dummy:	.quad 0
__kerneL_cs: gdt 0, 0xfffff, GDT_RX | GDT_32 | GDT_4K
__kerneL_ds: gdt 0, 0xfffff, GDT_RW | GDT_32 | GDT_4K
__user_cs:   gdt 0, 0xfffff, GDT_RX | GDT_32 | GDT_4K | DPL3
__user_ds:   gdt 0, 0xfffff, GDT_RW | GDT_32 | GDT_4K | DPL3

__gdtr:		.word __gdtr - __gdt - 1
		.long __gdt
