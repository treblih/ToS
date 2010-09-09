.text
.code32

.globl	__kernel

__kernel:
	call	__hal_init
	/* sti */
#int	$1
#movl	$10, %ecx
	/* call	__wait */
	/* mov	$0xfffff, %ecx */
 ppp:
 	/* nop */
	/* loop	ppp */
 	pushl	$msg_wa
	call	puts
	addl	$4, %esp
	
	jmp	.
	call	__get_pit_cnt
	pushl	%eax
	call	h2s
	addl	$4, %esp

msg_wa:	.asciz "wakakak\n"
