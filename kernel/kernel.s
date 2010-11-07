.include "mem.inc"

.section .text

.globl	_start

#------------------------------------------------------------------ 
# void __kernel(struct mem_map_entry *, struct boot_info *);
#------------------------------------------------------------------ 
_start:
	call	__screen_clear
	call	__puts_tos	# print the logo
	call	__wait		# seconds to see the logo
	call	__screen_clear

	pushl	$msg_pmode
	call	puts
	addl	$4, %esp

	call	__hal_init
	call	__pmem_init
	/* call	__initrd_init */
	
	/* sti */
	jmp	.

.section .data
msg_pmode:	.asciz "now in protect mode\n"

__init
