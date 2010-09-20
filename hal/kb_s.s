.include "kb.inc"
.include "pic.inc"

.section .text

.globl	__kb_init
.globl	__kb_buf_read
.globl	__get_kb_buf_cnt

	.type	__kb_init, @function
__kb_init:
	movl	$0, cnt
	movl	$buf, head
	movl	$buf, tail
	movb	$1, num_lock
	call 	led_init
	# enable the IRQ
	pushl	$kb_buf_write
	pushl	$IRQ_KEYBOARD
	call	__irq_enable
	addl	$8, %esp
	ret

	.type	led_init, @function
led_init:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%edx
	subl	$4, %esp

	xor	%eax, %eax
	xor	%edx, %edx
	movb	scroll_lock, %al
	movb	num_lock, %dl
	shlb	$1, %dl
	addl	%edx, %eax
	movb	caps_lock, %dl
	shlb	$2, %dl
	addl	%edx, %eax
	movb	%al, -4(%ebp)

	call	clear_8042
	# send func
	movb	$SET_LED, %al
	outb	$REG_8048
	# wait response
  .wait_response_loop:
	inb	$REG_8048
	cmp	$ACK, %eax
	jne	.wait_response_loop
	# send led status
	movb	-4(%ebp), %al
	outb	$REG_8048

	addl	$4, %esp
	popl	%edx
	popl	%eax
	leave
	ret

# make sure 0x8042 is empty, by test bit 1
	.type	clear_8042, @function
clear_8042:
	pushl	%eax
  .clear_8042_loop:
	inb	$REG_8042
	andl	$2, %eax
	test	%eax, %eax
	jne	.clear_8042_loop
	popl	%eax
	ret

#------------------------------------------------------------------ 
# get a scan code from kb software buffer
#------------------------------------------------------------------ 
	.type	__kb_buf_read, @function
__kb_buf_read:
	pushl	%ebp
	movl	%esp, %ebp

	cli
	cmpl	$buf + KB_BUF_LEN, tail
	jl 	.tail_no_rollback
	movl	$buf, tail
  .tail_no_rollback:
  	movl	tail, %edi
	movzbl	(%edi), %eax
	decl	cnt
	incl	tail
	sti
	leave
	ret

	.type	__get_kb_buf_cnt, @function
__get_kb_buf_cnt:
	movl	cnt, %eax
	ret

#------------------------------------------------------------------ 
# get a scan code from 0x8048 to kb software buffer
# the default kb interrupt handler
# 
# execute during the int handler, no need to cli/sti, doesn't like 
# what we do in it's brother __kb_buf_read
# see in pic.h, the .macro irq
#------------------------------------------------------------------ 
	.type	kb_buf_write, @function
kb_buf_write:
	inb	$REG_8048
	cmpl	$buf + KB_BUF_LEN, head
	jl 	.head_no_rollback
	movl	$buf, head
  .head_no_rollback:
  	movl	head, %edi
	movb	%al, (%edi)
	incl	cnt
	incl	head
	ret
	

.section .bss
.lcomm alt_l,	 	1
.lcomm alt_r,	 	1
.lcomm ctrl_l,	 	1
.lcomm ctrl_r,	 	1
.lcomm shift_l,	 	1
.lcomm shift_r,	 	1
.lcomm caps_lock,	1
.lcomm num_lock,	1
.lcomm scroll_lock,	1

.lcomm head,	 	4
.lcomm tail,		4 
.lcomm cnt, 		4
.lcomm buf,		KB_BUF_LEN
