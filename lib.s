.text
.code32
.globl	__screen_clear
.globl	__asm_debug
.globl	__wait
.globl	__trans_idt
.globl	strcpy

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
# like the one in stdlib.h
# arg:	esi source
#	edi destination
#	ecx how many
#------------------------------------------------------------------ 
strcpy:
	pushl 	%ebp
	movl	%esp, %ebp
	pushl 	%esi
	pushl 	%edi
	pushl 	%ecx
	movl	8(%ebp), %esi
	movl	12(%ebp), %edi
	movl	16(%ebp), %ecx
	cld
	rep	movsb
	popl	%ecx
	popl	%edi
	popl	%esi
	leave
	ret
