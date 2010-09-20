.section .text

.globl	__x86_cpu_init
	.type	__x86_cpu_init, @function
__x86_cpu_init:
	call	get_cpu_vendor
	call	__x86_gdt_init
	call	__x86_idt_init
	call	__x86_pic_init
	# master pic is inside cpu
	# call	__x86_tss_init
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

.section .data
msg_cpu_vendor:	.fill 14	# 12 + \n + nul
msg_cpuid:	.asciz "your cpu id: "
