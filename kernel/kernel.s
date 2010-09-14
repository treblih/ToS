.include "mem.h"

.text
.code32

.globl	__kernel

#------------------------------------------------------------------ 
# void __kernel(struct mem_map_entry *, struct boot_info *);
#------------------------------------------------------------------ 
__kernel:
	call	__hal_init
	call	__pmem_init
	call	__print_pmem_map
	
	jmp	.
	/* sti */
	call	__get_pit_cnt
	pushl	%eax
	call	h2s
	addl	$4, %esp
