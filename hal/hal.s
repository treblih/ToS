.globl	__hal_init


__hal_init:
	pushl	$msg_hal
	call	puts
	addl	$4, %esp
	
	call	__x86_cpu_init
	call	__pit_init
	ret

msg_hal:	.asciz "initing hal...\n"
