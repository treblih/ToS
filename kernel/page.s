.include "mem.inc"

.text

.globl	__pt_init

#------------------------------------------------------------------ 
# __pt_init(unsigned *, unsigned);
#------------------------------------------------------------------ 
	.type	__pt_init, @function
__pt_init:
	pushl	%ebp
	movl	%esp, %ebp

	movl	8(%ebp), %eax
	movl	12(%ebp), %ebx
	movl	$1024, %ecx
  .__pt_init_loop:
  	movl	%ebx, (%eax)
	addl	$4, %eax
	addl	$4096, %ebx
  	loop	.__pt_init_loop

	leave
	ret
