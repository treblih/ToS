.include "mem.inc"

.section .text

.globl	_start

#------------------------------------------------------------------ 
# void __kernel(struct mem_map_entry *, struct boot_info *);
#------------------------------------------------------------------ 
_start:
	/* call	__screen_clear */
	/* call	__puts_tos	# print the logo */
	/* call	__wait		# seconds to see the logo */
	call	__screen_clear

	pushl	$msg_pmode
	call	puts
	addl	$4, %esp

	call	__hal_init
	call	__pmem_init
	
	sti
	movl	$0x40, %ecx
aaa:
	pushl	%ecx
	call	__wait
	call	__get_pit_cnt
	subl	$0x10, %esp	# 8 + '\0'
	movl	%esp, %ebx
	pushl	$0x10
	pushl	%eax
	pushl	%ebx
	/* leal	-9(%ebp), %eax */
	/* pushl	%eax */
	call	i2s
	addl	$12, %esp
	pushl	%ebx
	call	puts
	addl	$4, %esp
	addl	$0x10, %esp
	popl	%ecx
	loop	aaa
	jmp	.

.section .data
msg_pmode:	.asciz "now in protect mode\n"
