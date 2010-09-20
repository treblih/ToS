.section .text

.globl	__hal_init

	.type	__hal_init, @function
__hal_init:
	pushl	$msg_hal
	call	puts
	addl	$4, %esp
	
	call	__x86_cpu_init
	call	__pit_init
	/* call	__kb_init */
	ret

.section .data
msg_hal:	.asciz "initializing hal...\n"
