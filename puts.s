.globl	puts
.globl	puts_dst
.globl	puts_tos

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
# ret:	edi the new dst_addr
#
# print string core func
#------------------------------------------------------------------------------------------------ 
puts_base:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%eax
	pushl	%esi
	movl	8(%ebp), %esi
	movl	12(%ebp), %edi
	cld
  .puts_base_loop:
	lodsb			
	or	%al, %al	
	jz	.puts_base_end
	stosb
	movb	$4, (%edi)			# 1 char, 1 property
	inc	%edi
	jmp	.puts_base_loop
  .puts_base_end:
	popl	%esi
	popl	%eax
	leave
	ret

puts_tos:
	pusha

	movl	$15, %ecx

	movl	$13, %eax	# always the case
	pushl	%eax
	movl	$4, %ebx
	leal	msg_tos0, %eax

  .puts_tos_loop:
	pushl	%ebx
	pushl	%eax
	call	puts_dst
	popl	%eax		# so no need to pop the column arg
	popl	%ebx
	inc	%ebx
	addl	$53, %eax	# 52 + 1
	loop	.puts_tos_loop

	addl	$4, %esp	# exclude the column here

	popa
	ret


cur_pos:	.long 0xb8000

# 52 chars + NULL
msg_tos0:	.asciz "TTTTTTTTTTTTTTTTTTTTT                SSSSSSSSSSSS   "
msg_tos1:	.asciz "TTTTTTTTTTTTTTTTTTTTT              SSSSS      SSSSS "
msg_tos3:	.asciz "       TTTTTT                     SSS            SSS"
msg_tos4:	.asciz "       TTTTTT          ooooooo    SSS            SSS"
msg_tos5:	.asciz "       TTTTTT         ooooooooo     SSS             "
msg_tos6:	.asciz "       TTTTTT        o W       o       SSS          "
msg_tos7:	.asciz "       TTTTTT        o  E      o           SSS      "
msg_tos8:	.asciz "       TTTTTT        o   L     o            SSS     "
msg_tos9:	.asciz "       TTTTTT        o    C    o               SSS  "
msg_tosa:	.asciz "       TTTTTT        o     O   o                 SSS"
msg_tosb:	.asciz "       TTTTTT        o      M  o  SSS            SSS"
msg_tosc:	.asciz "       TTTTTT        o       E o  SSS            SSS"
msg_tosd:	.asciz "       TTTTTT         ooooooooo    SSSSS     SSSSS  "
msg_tose:	.asciz "       TTTTTT          ooooooo       SSSSSSSSSSS    "