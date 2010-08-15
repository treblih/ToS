.globl	__x86_pic_init
.globl	__interrupt_done

__x86_pic_init:
	pushl	%eax

	# ICW1, need ICW4/ cascading/ initializing
	movb	$0x11, %al
	outb	%al, $0x20
	outb	%al, $0xa0

	# ICW2, from IRQ 0x20 - 0x2f
	movb	$0x20, %al
	outb	%al, $0x21
	movb	$0x28, %al
	outb	%al, $0xa1

	# ICW3
	movb	$0x4, %al
	outb	%al, $0x21
	movb	$0x2, %al
	outb	%al, $0xa1

	# ICW4, mode 80x86/ normal EOI
	movb	$0x1, %al
	outb	%al, $0x21
	outb	%al, $0xa1

	# OCW1, disable all interrupts
	movb	$0xff, %al
	outb	%al, $0x21
	outb	%al, $0xa1

	popl	%eax
	ret

#------------------------------------------------------------------ 
# void __interrupt_done(int vec);
#
# send EOI to PIC
#------------------------------------------------------------------ 
__interrupt_done:
	pushl	%ebp
	movl	%esp, %ebp

	movl	8(%ebp), %eax
	cmp	$15, %eax
	jg	.__interrupt_done_end
	cmp	$7, %eax
	jg	.__interrupt_done_master

  	# OCW2, EOI
  	movb	$0x20, %al	
	out	%al, $0xa0	# cmd-reg, not 0xa1
  .__interrupt_done_master:
  	movb	$0x20, %al	
	out	%al, $0x20	# cmd-reg, not 0x21

  .__interrupt_done_end:
	leave
	ret
