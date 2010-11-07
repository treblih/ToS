.include "pmode.inc"

.section .text

.globl	__cpu_init
	.type	__cpu_init, @function
__cpu_init:
	call	get_cpu_vendor
	call	gdt_init
	/* call	trap_init */
	call	__pic_init
	# master pic is inside cpu
	# call	__tss_init
	ret

	.type	get_cpu_vendor, @function
get_cpu_vendor:
	pushl	$msg_cpuid
	call	puts
	addl	$4, %esp
	movl	$0, %eax
	cpuid
	movl	%ebx, msg_cpu_vendor
	movl	%edx, msg_cpu_vendor + 4
	movl	%ecx, msg_cpu_vendor + 8
	movb	$'\n', msg_cpu_vendor + 12
	movb	$0, msg_cpu_vendor + 13
	pushl	$msg_cpu_vendor
	call	puts
	addl	$4, %esp
	ret

.globl	gdt_init
	.type	gdt_init, @function
gdt_init:
	call	trans_gdt
	pushl	$msg_trans_gdt
	call	puts
	addl	$4, %esp
	ret

	.type	trans_gdt, @function
trans_gdt:
	pushl	%eax
	xor	%eax, %eax
	movw	__gdtr, %ax
	inc	%ax		# essential last byte
	movzx	%ax, %eax
	pushl	%eax		# how many
	pushl	$__gdt
	pushl	$gdt_dst
	call	memcpy
	addl	$12, %esp

	# update __gdtr
	movl	$gdt_dst, %eax
	movl	%eax, __gdtr + 2
	lgdt	__gdtr
	call	flush_sreg

	popl	%eax
	ret

	.type	flush_sreg, @function
flush_sreg:
	jmp	$__KERNEL_CS, $.flush_sreg  # flush cs
  .flush_sreg:
	xor	%eax,	%eax
	movw	$slc_krnl_rw, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss
	ret


.section .data
msg_cpu_vendor:	.fill 14	# 12 + \n + nul
msg_cpuid:	.asciz "your cpu id: "
msg_trans_gdt:	.asciz "transfered gdt to 0xd00\n"	# following IDT

__gdt:
__dummy:	.quad 0
__kerneL_cs: gdt 0, 0xfffff, GDT_RX | GDT_32 | GDT_4K
__kerneL_ds: gdt 0, 0xfffff, GDT_RW | GDT_32 | GDT_4K
__user_cs:   gdt 0, 0xfffff, GDT_RX | GDT_32 | GDT_4K | DPL3
__user_ds:   gdt 0, 0xfffff, GDT_RW | GDT_32 | GDT_4K | DPL3

__gdtr:		.word __gdtr - __gdt - 1
		.long __gdt
