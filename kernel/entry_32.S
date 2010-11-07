/*
 * Stack layout in 'syscall_exit':
 * 	ptrace needs to have all regs on the stack.
 *	if the order here is changed, it needs to be
 *	updated in fork.c:copy_process, signal.c:do_signal,
 *	ptrace.c and ptrace.h
 *
 *	 0(%esp) - %ebx
 *	 4(%esp) - %ecx
 *	 8(%esp) - %edx
 *       C(%esp) - %esi
 *	10(%esp) - %edi
 *	14(%esp) - %ebp
 *	18(%esp) - %eax
 *	1C(%esp) - %ds
 *	20(%esp) - %es
 *	24(%esp) - %fs
 *	28(%esp) - %gs / function address
 *	2C(%esp) - orig_eax / error code
 *	30(%esp) - %eip
 *	34(%esp) - %cs
 *	38(%esp) - %eflags
 *	3C(%esp) - %oldesp
 *	40(%esp) - %oldss
 *
 * "current" is in register %ebx during any slow entries.
 */

#include <linkage.h>
#include <desc.h>

/* offset */
#define	PT_GS		0x28
#define	PT_ORIG_EAX	0x2c

ENTRY(divide_error)
	pushl	$0			# no error code
	pushl	$do_divide_error
	jmp	error_code
END(divide_error)

ENTRY(debug)
END(debug)

ENTRY(page_fault)
	pushl	$do_page_fault
	ALIGN
error_code:
	/* the function address is in %gs's slot on the stack */
	pushl	%fs
	pushl	%es
	pushl	%ds
	pushl	%eax
	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%edx
	pushl	%ecx
	pushl	%ebx
	cld
	movl	PT_GS(%esp), %edi	# get the function address
	movl	PT_ORIG_EAX(%esp), %edx	# get the error code
	movl	$-1, PT_ORIG_EAX(%esp)	# no syscall to restart
	movl	$__USER_DS, %ecx
	movl	%ecx, %ds
	movl	%ecx, %es
	call 	trace_hardirqs_off_thunk;
	movl	%esp, %eax		# pt_regs pointer
	call	*%edi			# eax/edx hold the args
	jmp	ret_from_exception
	
END(page_fault)
