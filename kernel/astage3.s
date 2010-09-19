.include "mem.h"

.text
.code32

/* .equ	__KRNL_3G,	$__kernel + KRNL_PM_BASE */

.globl	_start
.globl	__get_image_sectors

_start:
	
	/* movl	$__kernel, %eax */
	/* addl	$KRNL_PM_BASE, %eax */
	/* call	%eax */
	/* call	__kernel */
	jmp	0xc00001b4
	cli
	hlt

__get_image_sectors:
	movl	IMAGE_SECTORS, %eax
	ret

# .data			
# don't add this, otherwise will add a 0x1000 to the label when in mem
# meanwhile will align them to the next 16-byte edge when in kernel.elf
IMAGE_SECTORS:	.long 0
msg_pmode:	.asciz "now in protect mode\n"
