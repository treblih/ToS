.include "mem.h"

.text
.code32

.globl	__kernel

#------------------------------------------------------------------ 
# void __kernel(struct mem_map_entry *, struct boot_info *);
#------------------------------------------------------------------ 
__kernel:
	pushl	%ebp
	movl	%esp, %ebp
	movl	12(%ebp), %edi

	call	__hal_init
	/* sti */

	movl	MEM_LOW(%edi), %eax
	addl	$1024, %eax
	movl	MEM_HIGH(%edi), %ebx
	shll	$6, %ebx
	addl	%ebx, %eax

	pushl	%eax
	pushl	$msg_mem_size
	call	printf
	addl	$8, %esp
	
	jmp	.
	call	__get_pit_cnt
	pushl	%eax
	call	h2s
	addl	$4, %esp

msg_mem_size:	.asciz "your computer has %d kb physical memory\n"
