.include "pic.inc"

.section .text

.globl	__x86_pic_init
.globl	__interrupt_done
.globl	__irq_enable

	.type	__x86_pic_init, @function
__x86_pic_init:
	pushl	%eax

	# ICW1, need ICW4/ cascading/ initializing
	movb	$0x11, %al
	outb	$REG_COMMAND
	outb	$REG_COMMAND_S

	# ICW2, from IRQ 0x20 - 0x2f
	movb	$0x20, %al
	outb	$REG_DATA
	movb	$0x28, %al
	outb	$REG_DATA_S

	# ICW3
	movb	$0x4, %al
	outb	$REG_DATA
	movb	$0x2, %al
	outb	$REG_DATA_S

	# ICW4, mode 80x86/ normal EOI
	movb	$0x1, %al
	outb	$REG_DATA
	outb	$REG_DATA_S

	# OCW1, disable all interrupts
	movb	$0xff, %al
	outb	$REG_IMR
	outb	$REG_IMR_S

	popl	%eax
	ret

#------------------------------------------------------------------ 
# void __interrupt_done(int vec);
#
# send EOI to PIC
#------------------------------------------------------------------ 
	.type	__interrupt_done, @function
__interrupt_done:
	pushl	%ebp
	movl	%esp, %ebp

	movl	8(%ebp), %eax
	cmp	$15, %eax
	jg	.__interrupt_done_end
	cmp	$7, %eax
	jg	.__interrupt_done_master

  	# OCW2, EOI
  	movb	$OCW2_MASK_EOI, %al	
	outb	$REG_COMMAND_S	# cmd-reg, not 0xa1
  .__interrupt_done_master:
  	movb	$OCW2_MASK_EOI, %al	
	outb	$REG_COMMAND	# cmd-reg, not 0x21
  .__interrupt_done_end:
	leave
	ret

#------------------------------------------------------------------ 
# void __irq_enable(int vec);
#
# enable an IRQ
#------------------------------------------------------------------ 
	.type	__irq_enable, @function
__irq_enable:
	pushl	%ebp
	movl	%esp, %ebp
	pushf                                            
	pusha
	xor	%eax, %eax
	movl	8(%ebp), %ecx
	movb	$~1, %dl                               
	rol	%cl, %dl                                
	# IRQ 0-7 or IRQ 8-15
	cmp	$8, %cl                               
	jae	.__irq_enable_slave
	# IRQ 0-7  -- 0x21 OCW1
	inb	$REG_IMR                                      
	andb	%dl, %al                               
	outb  	$REG_IMR
	jmp   	.__irq_enable_end                                         
	# IRQ 8-15 -- 0xa1 OCW1
  .__irq_enable_slave:
	inb   	$REG_IMR_S
	andb  	%dl, %al                               
	outb   	$REG_IMR_S
  .__irq_enable_end:
  	popa
	popf                                             
	leave
	ret
