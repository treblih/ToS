.include "mem.h"

.text
.code32

/* .equ	__KRNL_3G,	$__kernel + KRNL_PM_BASE */

.globl	_start
.globl	__get_image_sectors

_start:
	# %edx set by loader
	movl	%edx, IMAGE_SECTORS

	call	__screen_clear
	call	__puts_tos	# print the logo
	call	__wait		# seconds to see the logo
	call	__screen_clear

	pushl	$msg_pmode
	call	puts
	addl	$4, %esp

	# set up paging
	# 0 - 4m
	pushl	$0 | PRESENT | RW
	pushl	$PT_0
	call	__pt_init
	addl	$8, %esp
	# 3g
	pushl	$0x100000 | PRESENT | RW
	pushl	$PT_768
	call	__pt_init
	addl	$8, %esp

	movl	$PDE, %edi
	movl	$PT_0 | PRESENT | RW, (%edi)
	movl	$768, %eax
	movl	$PT_768 | PRESENT | RW, (%edi, %eax, 4)

	# copy kernel image from 0x20000 to 0xc0000000
	xor	%edx, %edx
	call	__get_image_sectors
	shll	$7, %eax		# %eax * 512 / 4
	movl	%eax, %ecx
	movl	$KRNL_RM_BASE, %esi
	movl	$0x100000, %edi
	cld
	rep	movsl

	# enable paging
	movl	$PDE, %eax
	movl	%eax, %cr3
	movl	%cr0, %eax
	orl	$0x80000000, %eax
	movl	%eax, %cr0
	
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
