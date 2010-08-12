.globl	__x86_cpu_init

__x86_cpu_init:
	call	__x86_gdt_init
	call	__x86_idt_init
	# call	__x86_tss_init
	# call	__x86_8259a_init
	ret
