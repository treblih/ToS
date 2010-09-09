.globl	__x86_cpu_init

__x86_cpu_init:
	call	get_cpu_vendor
	call	__x86_gdt_init
	call	__x86_idt_init
	call	__x86_pic_init
	# master pic is inside cpu
	# call	__x86_tss_init
	ret


get_cpu_vendor:
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

msg_cpu_vendor:	.fill 14	# 12 + \n + nul
