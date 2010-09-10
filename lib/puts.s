.globl	puts
.globl	puts_dst
.globl	__puts_tos

#------------------------------------------------------------------------------------------------ 
# void puts(char *str);
# 
# print the string according to the sys cursor position & update it
# base off puts
#------------------------------------------------------------------------------------------------ 
puts:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	movl	cur_pos, %eax
	pushl	%eax
	movl	8(%ebp), %eax	# eax -> eip -> str
	pushl	%eax
	call	puts_base
	addl	$8, %esp
	movl	%edi, cur_pos	# update
	popl	%eax
	leave
	ret

#------------------------------------------------------------------------------------------------ 
# void puts_dst(char *str, int x, int y);
# 
# print the string according to the specified (x, y)
# base off puts
#------------------------------------------------------------------------------------------------ 
puts_dst:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%ebx
	movl	12(%ebp), %eax	# x
	movw	$80, %bx	
	mulw	%bx		# x * 80
	movl	16(%ebp), %ebx	# y
	addl	%ebx, %eax
	movw	$2, %bx
	mulw	%bx		# (x * 80 + y) * 2
	addl	$0xb8000, %eax
	pushl	%eax
	movl	8(%ebp), %eax	# str
	pushl	%eax
	call	puts_base
	addl	$8, %esp
	popl	%ebx
	popl	%eax
	leave
	ret
	

#------------------------------------------------------------------------------------------------ 
# int puts_base(char *str, int dst_addr);	need 0xb8xxx
# ret:	edi	the new dst_addr
#
# print string core func, if meet with '\n', cr + lf, like Linux
#------------------------------------------------------------------------------------------------ 
puts_base:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%edx
	pushl	%esi
	movl	8(%ebp), %esi
	movl	12(%ebp), %edi
	cld

  .puts_base_loop:
	lodsb			
	cmp	$'\n', %al
	jne	.puts_putchar
  	call	__asm_debug
	movl	%edi,	%eax
	subl	$0xb8000, %eax
	movl	$160, %edx	# 80 * 2
	div	%dl		
	shrw	$8, %ax		# ah holds the remainder
	subw	%ax, %di	
	addl	$160, %edi	# to the next new line
	jmp	.puts_base_loop

  .puts_putchar:
	or	%al, %al	
	jz	.puts_base_end
	stosb
	movb	$0x0e, (%edi)			# 1 char, 1 property
	inc	%edi
	jmp	.puts_base_loop
  .puts_base_end:
	popl	%esi
	popl	%edx
	popl	%eax
	leave
	ret

__puts_tos:
	pusha
	movl	$14, %ecx	# logo height, 14

	movl	$13, %eax	# always the case
	pushl	%eax
	movl	$4, %ebx
	leal	msg_tos, %eax
  .__puts_tos_loop:
	pushl	%ebx
	pushl	%eax
	call	puts_dst
	popl	%eax		# so no need to pop the column arg
	popl	%ebx
	inc	%ebx
	addl	$53, %eax	# 52 + 1
	loop	.__puts_tos_loop
	addl	$4, %esp	# exclude the column here
	popa
	ret


cur_pos:	.long 0xb8000

# 52 chars + NULL
msg_tos:
.asciz "TTTTTTTTTTTTTTTTTTTTT                SSSSSSSSSSSS   "
.asciz "TTTTTTTTTTTTTTTTTTTTT              SSSSS      SSSSS "
.asciz "       TTTTTT                     SSS            SSS"
.asciz "       TTTTTT          ooooooo    SSS            SSS"
.asciz "       TTTTTT         ooooooooo     SSS             "
.asciz "       TTTTTT        o W       o       SSS          "
.asciz "       TTTTTT        o  E      o           SSS      "
.asciz "       TTTTTT        o   L     o            SSS     "
.asciz "       TTTTTT        o    C    o               SSS  "
.asciz "       TTTTTT        o     O   o                 SSS"
.asciz "       TTTTTT        o      M  o  SSS            SSS"
.asciz "       TTTTTT        o       E o  SSS            SSS"
.asciz "       TTTTTT         ooooooooo    SSSSS     SSSSS  "
.asciz "       TTTTTT          ooooooo       SSSSSSSSSSS    "
