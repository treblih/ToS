.section .text

.globl	__screen_clear
.globl	__asm_debug
.globl	__wait
.globl	__trans_idt
.globl	strlen
.globl	memset
.globl	memcpy

	.type	__screen_clear, @function
__screen_clear:
	pushl	%eax
	pushl	%ecx
	pushl	%edi
	movl	$0, %eax
	movl	$0xb8000, %edi
	movl	$1000, %ecx	# 4 * 1000 = 80 * 25 * 2
	cld
	rep	stosl
	popl	%edi
	popl	%ecx
	popl	%eax
	ret

	.type	__asm_debug, @function
__asm_debug:
        push    %eax                 # reserve %eax, %esi
        push    %esi
        movl    $0x90000, %esi
        movl  	%ds:(%esi), %eax
        pushl 	%eax                 # reserve the data in 0x90000(%ds)
        movl  	$0xcb, %ds:(%esi)    # put ins "retf" in 0x90000(%ds)
        pushl 	%cs                  # push cs/ip, prepare for ret
        pushl   $back
        .byte 	0xea                 # 0xea = jmp far
        .long	0x90000
        .word	0x8
        back:
        popl 	%eax
        movl 	%eax, %ds:(%esi)
        pop     %esi
        pop     %eax
        ret             # now _bochs_debug is a func, so ret needed

	.type	__wait, @function
__wait:
	pushl	%ecx
	movl	$0xfff, %ecx
  .__wait_loop:
	nop
	nop
	nop
	nop
	nop
  	loop 	.__wait_loop
	popl	%ecx
	ret

#------------------------------------------------------------------ 
# int strlen(const char *);
#------------------------------------------------------------------ 
	.type	strlen, @function
strlen:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edi
	movw 	$0xffff, %cx
	movl 	$0, %eax		# compare with '\0'
	cld
	repne 	scasb
	jne 	.strlen_end		# %eax holds 0
	subw 	$0xffff, %cx
	neg 	%cx
	dec 	%cx
	movzx	%cx, %ecx
	movl	%ecx, %eax
  .strlen_end:
  	leave
	ret

#------------------------------------------------------------------ 
# void *memset(void *s, int c, size_t n);
#------------------------------------------------------------------ 
	.type	memset, @function
memset:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%ecx
	pushl	%edi

	movl	8(%ebp), %edi
	movl	12(%ebp), %eax
	movl	16(%ebp), %ecx
	cld
	rep	stosb

	popl	%edi
	popl	%ecx
	popl	%eax
	leave
	ret

#------------------------------------------------------------------ 
# void *memcpy(void *dest, const void *src, size_t n);
# arg:	edi destination
# 	esi source
#	ecx how many
#------------------------------------------------------------------ 
	.type	memcpy, @function
memcpy:
	pushl 	%ebp
	movl	%esp, %ebp
	pushl 	%esi
	pushl 	%edi
	pushl 	%ecx

	movl	8(%ebp), %edi
	movl	12(%ebp), %esi
	movl	16(%ebp), %ecx
	cld
	rep	movsb

	popl	%ecx
	popl	%edi
	popl	%esi
	leave
	ret
