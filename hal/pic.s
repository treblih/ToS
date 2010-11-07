.include "pmode.inc"
.include "pic.inc"

.section .text

.globl	__pic_init
.globl	__interrupt_done
.globl	__irq_enable
.globl	__get_irq_handler

	.type	__pic_init, @function
__pic_init:
	pushl	%eax
	pushl	%edx

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

	popl	%edx
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
# void __irq_enable(int vec, void *handler);
#------------------------------------------------------------------ 
	.type	__irq_enable, @function
__irq_enable:
	pushl	%ebp
	movl	%esp, %ebp
	pushf                                            
	pusha
	xor	%eax, %eax
	# %ecx always holds the int vec
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
	jmp   	.__irq_enable_set_idt
	# IRQ 8-15 -- 0xa1 OCW1
  .__irq_enable_slave:
	inb   	$REG_IMR_S
	andb  	%dl, %al 
	outb   	$REG_IMR_S
  .__irq_enable_set_idt:
	pushl	$__KERNEL_CS
	pushl	$IDT_IGATE | DPL0
	movl	irq_in_idt(, %ecx, 4), %eax
	pushl	%eax
	movl	%ecx, %edx
	addl	$0x20, %edx	# irq starts from 0x20
	pushl	%edx
	/* call	__idt_set */
	addl	$16, %esp

	# set in irq_handler_table
	movl	12(%ebp), %eax	# func pointer
	movl	%eax, irq_handler_table(, %ecx, 4);

  	popa
	popf                                             
	leave
	ret 


	.type	__irq0, @function
__irq0: irq_m	0	
	.type	__irq1, @function
__irq1: irq_m	1	
	.type	__irq2, @function
__irq2: irq_m	2	
	.type	__irq3, @function
__irq3: irq_m	3
	.type	__irq4, @function
__irq4: irq_m	4	
	.type	__irq5, @function
__irq5: irq_m 	5
	.type	__irq6, @function
__irq6: irq_m	6
	.type	__irq7, @function
__irq7: irq_m	7

	.type	__irq8, @function
__irq8: irq_s	0	
	.type	__irq9, @function
__irq9: irq_s	1	
	.type	__irqa, @function
__irqa: irq_s	2	
	.type	__irqb, @function
__irqb: irq_s	3
	.type	__irqc, @function
__irqc: irq_s	4	
	.type	__irqd, @function
__irqd: irq_s 	5
	.type	__irqe, @function
__irqe: irq_s	6
	.type	__irqf, @function
__irqf: irq_s	7

#------------------------------------------------------------------ 
# void *__get_irq_handler(int);
#------------------------------------------------------------------ 
	.type	__get_irq_handler, @function
__get_irq_handler:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	irq_handler_table(, %eax, 4), %eax
	leave
	ret

.section .data
irq_in_idt:
.long	__irq0, __irq1, __irq2, __irq3	
.long	__irq4, __irq5, __irq6, __irq7	
.long	__irq8, __irq9, __irqa, __irqb	
.long	__irqc, __irqd, __irqe, __irqf	

.section .bss
.lcomm irq_handler_table, 4 * 0x10
