.globl	__hal_init


__hal_init:
	call	__x86_cpu_init
	call	__pit_init
	ret
