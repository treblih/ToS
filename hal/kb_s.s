.include "kb.inc"

.text
.code32

.globl	__kb_init
.globl	__kb_read_buf
.globl	__get_kb_buf_cnt

__kb_init:
	call led_init
	# enable the IRQ
	pushl	$IRQ_KEYBOARD
	call	__irq_enable
	addl	$4, %esp
	ret

led_init:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%edx
	subl	$4, %esp

	movb	scroll_lock, %eax
	movb	num_lock, %edx
	shlb	$1, %edx
	addl	%edx, %eax
	movb	caps_lock, %edx
	shlb	$2, %edx
	addl	%edx, %eax
	movb	%eax, -4(%ebp)

	call	clear_8042
	# send func
	movb	$SET_LED, %eax
	outb	REG_8048
	# wait response
  .wait_response_loop:
	inb	REG_8048
	cmp	$ACK, %eax
	jne	.wait_response_loop
	# send led status
	movb	-4(%ebp), %eax
	outb	REG_8048

	addl	$4, %esp
	popl	%edx
	popl	%eax
	leave
	ret

# make sure 0x8042 is empty, by test bit 1
clear_8042:
	pushl	%eax
  .clear_8042_loop:
	inb	REG_8042
	andl	$2, %eax
	test	%eax, %eax
	jne	.clear_8042_loop
	popl	%eax
	ret

__kb_buf_read:
	pushl	%ebp
	movl	%esp, %ebp

	cli
	cmp	$buf + KB_BUF_LEN, tail
	movl	$buf, tail
	jl 	tail_no_rollback
  .tail_no_rollback:
  	movl	tail, %edi
	movb	(%edi), %eax
	decl	cnt
	incl	tail
	sti
	leave
	ret

__get_kb_buf_cnt:
	movl	cnt, %eax
	ret
	

alt_l:		.byte 0
alt_r:		.byte 0
ctrl_l:		.byte 0
ctrl_r:		.byte 0
shift_l:	.byte 0
shift_r:	.byte 0
caps_lock:	.byte 0
num_lock:	.byte 1
scroll_lock:	.byte 0

cnt:		.long 0
head:		.long $buf
tail:		.long $buf
buf:		.fill KB_BUF_LEN
