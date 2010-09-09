.include "pmode.h"

.globl	__x86_idt_init
.globl	__idt_set

.globl	__divide_error
.globl	__single_step
.globl	__nmi
.globl	__breakpoint
.globl	__overflow
.globl	__bounds_check
.globl	__inval_opcode
.globl	__copr_not_available
.globl	__double_fault
.globl	__copr_seg_overrun
.globl	__inval_tss
.globl	__segment_not_present
.globl	__stack_seg_fault
.globl	__general_protection
.globl	__page_fault
.globl	__fpu_fault
.globl	__align_fault
.globl	__machine_abort
.globl	__simd_fault


#-----------------------------------------------------------------------------
#  should have follow the sequence
#  INTEL occupied 0x08 - 0x0f, in real mode they're reserved for IRQ
#
#  cpu generated exceptions(trap/fault/abort):
#  err_code - eip - cs - eflags
#-----------------------------------------------------------------------------
__x86_idt_init:
	pushl	%eax

	# set idt
	movl	$0, %eax		# vector starts from 0
	pushl	$slc_krnl_rx
	pushl	$IDT_IGATE | DPL0
	pushl	$__divide_error
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		# not 16, remains slc & attr

	pushl	$__single_step
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__nmi
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$12, %esp		

	pushl	$IDT_IGATE | DPL3
	pushl	$__breakpoint
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		
	
	pushl	$__overflow
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$12, %esp		

	pushl	$IDT_IGATE | DPL0
	pushl	$__bounds_check
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__inval_opcode
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__copr_not_available
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__double_fault
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__copr_seg_overrun
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__inval_tss
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__segment_not_present
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__stack_seg_fault
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__general_protection
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__page_fault
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	# INTEL reserved no.15

	pushl	$__fpu_fault
	addl	$2, %eax	# add 2, not inc
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__align_fault
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__machine_abort
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$8, %esp		

	pushl	$__simd_fault
	inc	%eax
	pushl	%eax
	call	__idt_set
	addl	$16, %esp

	# set idtr
	movw	$0x7ff, __idtr
	movl	$idt_dst, __idtr + 2

	lidt	__idtr

	popl	%eax
	ret

#------------------------------------------------------------------ 
# void __idt_set(int vector, void *offset, int attr, int slc)
#------------------------------------------------------------------ 
__idt_set:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%ebx
	pushl	%edi

	movl	8(%ebp), %eax		# vector
	movw	$8, %bx
	mulw	%bx
	movl	%eax, %edi
	addl	$idt_dst, %edi		# 0x500 + n * 8

	movl	12(%ebp), %ebx		# offset
	movw	%bx, (%edi)
	addl	$2, %edi
	movl	20(%ebp), %eax		# slc
	movw	%ax, (%edi)
	addl	$2, %edi
	movb	$0, (%edi)
	addl	$1, %edi
	movl	16(%ebp), %eax		# attr
	movb	%al, (%edi)
	addl	$1, %edi
	shrl	$16, %ebx
	movw	%bx, (%edi)

	popl	%edi
	popl	%ebx
	popl	%eax
	leave
	ret

__divide_error:
	pushl	$0xffffffff	# no err code
	pushl	$0x00		# vec_no	= 0
	jmp	exception
__single_step:
	pushl	$0xffffffff	# no err code
	pushl	$0x01		# vec_no	= 1
	jmp	exception
__nmi:
	pushl	$0xffffffff	# no err code
	pushl	$0x02		# vec_no	= 2
	jmp	exception
__breakpoint:
	pushl	$0xffffffff	# no err code
	pushl	$0x03		# vec_no	= 3
	jmp	exception
__overflow:
	pushl	$0xffffffff	# no err code
	pushl	$0x04		# vec_no	= 4
	jmp	exception
__bounds_check:
	pushl	$0xffffffff	# no err code
	pushl	$0x05		# vec_no	= 5
	jmp	exception
__inval_opcode:
	pushl	$0xffffffff	# no err code
	pushl	$0x06		# vec_no	= 6
	jmp	exception
__copr_not_available:
	pushl	$0xffffffff	# no err code
	pushl	$0x07		# vec_no	= 7
	jmp	exception
__double_fault:
	pushl	$0x08		# vec_no	= 8
	jmp	exception
__copr_seg_overrun:
	pushl	$0xffffffff	# no err code
	pushl	$0x09		# vec_no	= 9
	jmp	exception
__inval_tss:
	pushl	$0x0a		# vec_no	= a
	jmp	exception
__segment_not_present:
	pushl	$0x0b		# vec_no	= b
	jmp	exception
__stack_seg_fault:
	pushl	$0x0c		# vec_no	= c
	jmp	exception
__general_protection:
	pushl	$0x0d		# vec_no	= d
	jmp	exception
__page_fault:
	pushl	$0x0e		# vec_no	= e
	jmp	exception
__fpu_fault:                     # yes, it's right. 'cause INTEL has reserved 0xf
	pushl	$0xffffffff	# no err code
	pushl	$0x10		# vec_no	= 0x10
	jmp	exception
__align_fault:
	pushl	$0x11		# vec_no	= 0x11
	jmp	exception
__machine_abort:
	pushl	$0x12
	jmp	exception
__simd_fault:
	pushl	$0xffffffff
	pushl	$0x13
	jmp	exception

exception:
	call	exception_handler
	addl	$8, %esp	# skip vec_no & error_code to eip - cs -eflags
        hlt

#------------------------------------------------------------------ 
# void exception_handler(int vec, int err, int eip, int cs, int eflags)
#------------------------------------------------------------------ 
exception_handler:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%ebx

	# print the error string
	movl	8(%ebp), %eax
	movw	$4, %bx
	mulw	%bx
	addl	$msg_ex_str, %eax
	pushl	(%eax)
	call	puts
	addl	$4, %esp

	# print eip / cs / eflags
	pushl	$msg_eip
	call	puts
	addl	$4, %esp
	pushl	16(%ebp)
	call	h2s
	addl	$4, %esp
	pushl	$msg_cs
	call	puts
	addl	$4, %esp
	pushl	20(%ebp)
	call	h2s
	addl	$4, %esp
	pushl	$msg_eflags
	call	puts
	addl	$4, %esp
	pushl	24(%ebp)
	call	h2s
	addl	$4, %esp

	popl	%ebx
	popl	%eax
	leave
	ret
	

msg_ex_str:
.long msg_ex00, msg_ex01, msg_ex02, msg_ex03, msg_ex04
.long msg_ex05, msg_ex06, msg_ex07, msg_ex08, msg_ex09
.long msg_ex0a, msg_ex0b, msg_ex0c, msg_ex0d, msg_ex0e
.long msg_ex0f, msg_ex10, msg_ex11, msg_ex12, msg_ex13

msg_ex00:	.asciz "#DE Divide Error"
msg_ex01:	.asciz "#DB RESERVED"
msg_ex02:	.asciz "—-- NMI Interrupt"
msg_ex03:	.asciz "#BP Breakpoint"
msg_ex04:	.asciz "#OF Overflow"
msg_ex05:	.asciz "#BR BOUND Range Exceeded"
msg_ex06:	.asciz "#UD Invalid Opcode (Undefined Opcode)"
msg_ex07:	.asciz "#NM Device Not Available (No Math Coprocessor)"
msg_ex08:	.asciz "#DF Double Fault"
msg_ex09:	.asciz "    Coprocessor Segment Overrun (reserved)"
msg_ex0a:	.asciz "#TS Invalid TSS"
msg_ex0b:	.asciz "#NP Segment Not Present"
msg_ex0c:	.asciz "#SS Stack-Segment Fault"
msg_ex0d:	.asciz "#GP General Protection"
msg_ex0e:	.asciz "#PF Page Fault"
msg_ex0f:	.asciz "—-- (Intel reserved. Do not use.)"
msg_ex10:	.asciz "#MF x87 FPU Floating-Point Error (Math Fault)"
msg_ex11:	.asciz "#AC Alignment Check"
msg_ex12:	.asciz "#MC Machine Check"
msg_ex13:	.asciz "#XF SIMD Floating-Point Exception"
msg_ex14:	.asciz "    Luck Dude Thank to Default Handler"

msg_eip:	.asciz "\neip: "
msg_cs:		.asciz "\ncs:"
msg_eflags:	.asciz "\neflags:"

__idtr:		.fill 6
