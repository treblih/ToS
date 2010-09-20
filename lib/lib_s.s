.section .text

.globl	__screen_clear
.globl	__asm_debug
.globl	__wait
.globl	__trans_idt
.globl	h2s
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
  .__wait_loop1:
  	pushl	%ecx
	movl	$0xfff, %ecx
    .__wait_loop2:
    	loop	.__wait_loop2
	popl	%ecx
  	loop 	.__wait_loop1

	popl	%ecx
	ret

#------------------------------------------------------------------ 
# convert a long hex to string
#------------------------------------------------------------------ 
	.type	h2s, @function
h2s:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	movl	8(%ebp), %eax
	xor	%ebx, %ebx
	xor	%edx, %edx
	movl	$8, %ecx		# not 4
	subl	$1, %esp	
	movb	$0, (%esp)		# nul

  .h2s_loop:
	movb	%al, %bl
	shrl	$4, %eax
	andb	$0x0f, %bl
	cmp	$0xa, %bl
	jl	.h2s_not_char
	subb	$0xa, %bl
	addb	$0x61, %bl
	jmp	.h2s_push
  .h2s_not_char:
	addb 	$0x30, %bl
  .h2s_push:
	subl	$1, %esp	
	movb	%bl, (%esp)		# nul
	loop	.h2s_loop
	subl	$2, %esp	
	movb	$'x', 1(%esp)		# nul
	movb	$'0', (%esp)		# nul
	pushl	%esp
	call	puts
	addl	$9, %esp		# 4 + 4 + 1
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	leave
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
