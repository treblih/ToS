.text
.code32

.globl _start
_start:
	movl	$0x10, %eax
	movw	%ax, %ds
	movw	%ax, %es
	movl	$0x18, %eax
	movw	%ax, %gs

	xor	%eax, %eax
	movb	$'H', %al
	movb	$0xb, %ah
	mov	%ax, %gs:(20 * 2)
	jmp	.
