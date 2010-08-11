.text
.code32

.globl	_start


_start:
	movl	$0x10, %eax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %gs
	movw	%ax, %ss
	movl	$0x2ffff, %esp

	call	screen_clear
	call	puts_tos
	call	wait

	pushl	$33
	pushl	$20
	pushl	$msg_pmode
	call	puts_dst
	addl	$12, %esp
	jmp 	.


screen_clear:
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

_asm_debug:
        push    %eax                            # reserve %eax, %esi
        push    %esi
        movl       $0x90000,       %esi
        movl  %ds : (%esi),   %eax
        pushl %eax                              # reserve the data in 0x90000(%ds)
        movl  $0xcb,  %ds : (%esi)              # put ins "retf" in 0x90000(%ds)
        pushl %cs                               # push cs/ip, make preparation for "retf"
        pushl $back
        .byte 0xea                              # 0xea = jmp far
        .long 0x90000
        .word 0x8
        back:
        popl  %eax
        movl  %eax,   %ds : (%esi)
        pop     %esi
        pop     %eax
        ret             # now _bochs_debug is a func, so ret needed


wait:
	pushl	%ecx
	movl	$0xfff, %ecx
  .wait_loop1:
  	pushl	%ecx
	movl	$0xfff, %ecx
    .wait_loop2:
    	loop	.wait_loop2
	popl	%ecx
  	loop 	.wait_loop1
	popl	%ecx
	ret
	
# .data			
# don't add this, otherwise will add a 0x1000 to the label when in mem
# meanwhile will align them to the next 16-byte edge when in kernel.elf
msg_pmode:	.asciz "Be in Protect Mode"
