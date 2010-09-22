.include "kb.inc"
.include "pic.inc"

.section .text

.globl	__kb_init
.globl	__led_init
.globl	__kb_buf_read
.globl	__get_kb_buf_cnt
.globl	__get_lock_key
.globl	__reverse_lock_key

	.type	__kb_init, @function
__kb_init:
	call 	__led_init
	# enable the IRQ
	pushl	$kb_buf_write
	pushl	$IRQ_KEYBOARD
	call	__irq_enable
	addl	$8, %esp
	ret

	.type	led_init, @function
__led_init:
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
# uint32_t __kb_buf_read();
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

#------------------------------------------------------------------ 
# ssize_t __get_kb_buf_cnt();
#------------------------------------------------------------------ 
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

#------------------------------------------------------------------ 
# uint8_t __get_lock_key(int which);
#------------------------------------------------------------------ 
	.type	__get_lock_key, @function
__get_lock_key:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	subl	$0x10e, %eax	# see in kb.h
	movzbl	caps_lock(, %eax, 1), %eax
	leave
	ret

#------------------------------------------------------------------ 
# void __reverse_lock_key(int which);
#------------------------------------------------------------------ 
	.type	__reverse_lock_key, @function
__reverse_lock_key:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	subl	$0x10e, %eax	# see in kb.h
	cmpb	$0, caps_lock(, %eax, 1)
	je	.0to1
	movb	$0, caps_lock(, %eax, 1);
	jmp	.__reverse_lock_key_end
  .0to1:
  	movb	$1, caps_lock(, %eax, 1);
  .__reverse_lock_key_end:
	leave
	ret
	

.section .data
caps_lock:	.byte	0
num_lock:	.byte	1
scroll_lock:	.byte	0

head:	.long	buf 
tail:	.long 	buf
cnt:	.long	0
buf:	.fill	KB_BUF_LEN
