.text
.code32

.globl	_start


_start:
	movl	$0x10, %eax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %gs
	movw	%ax, %ss
	movl	$0x2ffff, %esp

	call	__screen_clear
	call	__puts_tos
	call	__wait
	call	__screen_clear

	pushl	$msg_pmode
	call	puts
	addl	$12, %esp

	call	__hal_init
	sti
	int	$0

# .data			
# don't add this, otherwise will add a 0x1000 to the label when in mem
# meanwhile will align them to the next 16-byte edge when in kernel.elf
msg_pmode:	.asciz "Be in Protect Mode"
