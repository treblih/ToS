.include "mem.h"

.text
.code32

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
	/* call	__page_init */
	
	jmp	.
	/* sti */
	call	__get_pit_cnt
	pushl	%eax
	call	h2s
	addl	$4, %esp

msg_pmode:	.asciz "now in protect mode\n"
