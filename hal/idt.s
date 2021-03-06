.include "pmode.inc"

.section .text

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
	.type	__x86_idt_init, @function
__x86_idt_init:
	pushl	%eax

	# set idt
	movl	$0, %eax		# vector starts from 0
	pushl	$__KERNEL_CS
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
	.type	__idt_set, @function
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

	.type	__divide_error, @function
__divide_error:
	pushl	$0xffffffff	# no err code
	pushl	$0x00		# vec_no	= 0
	jmp	exception
	.type	__single_step, @function
__single_step:
	pushl	$0xffffffff	# no err code
	pushl	$0x01		# vec_no	= 1
	jmp	exception
	.type	__nmi, @function
__nmi:
	pushl	$0xffffffff	# no err code
	pushl	$0x02		# vec_no	= 2
	jmp	exception
	.type	__breakpoint, @function
__breakpoint:
	pushl	$0xffffffff	# no err code
	pushl	$0x03		# vec_no	= 3
	jmp	exception
	.type	__overflow, @function
__overflow:
	pushl	$0xffffffff	# no err code
	pushl	$0x04		# vec_no	= 4
	jmp	exception
	.type	__bounds_check, @function
__bounds_check:
	pushl	$0xffffffff	# no err code
	pushl	$0x05		# vec_no	= 5
	jmp	exception
	.type	__inval_opcode, @function
__inval_opcode:
	pushl	$0xffffffff	# no err code
	pushl	$0x06		# vec_no	= 6
	jmp	exception
	.type	__copr_not_available, @function
__copr_not_available:
	pushl	$0xffffffff	# no err code
	pushl	$0x07		# vec_no	= 7
	jmp	exception
	.type	__double_fault, @function
__double_fault:
	pushl	$0x08		# vec_no	= 8
	jmp	exception
	.type	__copr_seg_overrun, @function
__copr_seg_overrun:
	pushl	$0xffffffff	# no err code
	pushl	$0x09		# vec_no	= 9
	jmp	exception
	.type	__inval_tss, @function
__inval_tss:
	pushl	$0x0a		# vec_no	= a
	jmp	exception
	.type	__segment_not_present, @function
__segment_not_present:
	pushl	$0x0b		# vec_no	= b
	jmp	exception
	.type	__stack_seg_fault, @function
__stack_seg_fault:
	pushl	$0x0c		# vec_no	= c
	jmp	exception
	.type	__general_protection, @function
__general_protection:
	pushl	$0x0d		# vec_no	= d
	jmp	exception
	.type	__page_fault, @function
__page_fault:
	pushl	$0x0e		# vec_no	= e
	jmp	exception
	.type	__fpu_fault, @function
__fpu_fault:                     # yes, it's right. 'cause INTEL has reserved 0xf
	pushl	$0xffffffff	# no err code
	pushl	$0x10		# vec_no	= 0x10
	jmp	exception
	.type	__align_fault, @function
__align_fault:
	pushl	$0x11		# vec_no	= 0x11
	jmp	exception
	.type	__machine_abort, @function
__machine_abort:
	pushl	$0x12
	jmp	exception
	.type	__simd_fault, @function
__simd_fault:
	pushl	$0xffffffff
	pushl	$0x13
	jmp	exception

	.type	exception, @function
exception:
	call	exception_handler
	addl	$8, %esp	# skip vec_no & error_code to eip - cs -eflags
	jmp	.
        /* hlt */

#------------------------------------------------------------------ 
# void exception_handler(int vec, int err, int eip, int cs, int eflags)
#------------------------------------------------------------------ 
	.type	exception_handler, @function
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

	# print error code, if has
	cmp	$0xffffffff, 12(%ebp)
	je	.no_errcode

	pushl	$msg_errcode
	call	puts
	addl	$4, %esp

	# i2s(char *str, int n, int div)
	subl	$0x10, %esp	# buf of str, alignment
	movl	%esp, %ebx
	pushl	$0x10
	pushl	12(%ebp)
	pushl	%ebx
	call	i2s
	/* addl	$8, %esp	# not 12, remain the div */
	pushl	%ebx
	call	puts
	addl	$4 + 8, %esp	# str str n, remain the div

  .no_errcode:
	# print eip / cs / eflags
	pushl	$msg_eip
	call	puts
	addl	$4, %esp
	pushl	16(%ebp)	# take advantage of remaining div
	pushl	%ebx
	call	i2s
	pushl	%ebx
	call	puts
	addl	$4 + 8, %esp

	pushl	$msg_cs
	call	puts
	addl	$4, %esp
	pushl	20(%ebp)
	pushl	%ebx
	call	i2s
	pushl	%ebx
	call	puts
	addl	$4 + 8, %esp

	pushl	$msg_eflags
	call	puts
	addl	$4, %esp
	pushl	24(%ebp)
	pushl	%ebx
	call	i2s
	pushl	%ebx
	call	puts
	addl	$4 + 8 + 4 + 0x10, %esp	# div, buf of str

	popl	%ebx
	popl	%eax
	leave
	ret
	
.section .data
# no ',' follows the last 1 in every line, otherwise as regrads it as a NULL pointer
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

msg_errcode:	.asciz "\nerror code: "
msg_eip:	.asciz "\neip: "
msg_cs:		.asciz "\ncs:"
msg_eflags:	.asciz "\neflags:"

/* .section .bss */
/* .lcomm __idtr,	6 */
__idtr:	.fill 6
