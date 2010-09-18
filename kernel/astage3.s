.text
.code32

/* .equ	__KRNL_3G,	$__kernel + KRNL_PM_BASE */

.globl	_start
.globl	__get_image_sectors

_start:
	# flush sregs
	movl	$0x10, %eax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %gs
	movw	%ax, %ss
	movl	$0x2ffff, %esp

	# %edx set by loader
	movl	%edx, IMAGE_SECTORS

	call	__screen_clear
	call	__puts_tos	# print the logo
	call	__wait		# seconds to see the logo
	call	__screen_clear

	pushl	$msg_pmode
	call	puts
	addl	$4, %esp

	/* call	__KRNL_3G */
	call	__kernel
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
