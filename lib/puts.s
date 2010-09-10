.include "mem.h"


.globl	puts
.globl	puts_dst
.globl	__puts_tos
.globl	__print_mem_size
.globl	__print_mem_map

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

__print_mem_size:
	# (low + 1024 + high * 64) / 1024
	movl	$BOOT_INFO_ADDR, %edi
	movl	MEM_LOW(%edi), %eax
	addl	$1024, %eax
	movl	MEM_HIGH(%edi), %ebx
	shll	$6, %ebx
	addl	%ebx, %eax
	shrl	$10, %eax

	pushl	%eax
	pushl	$msg_mem_size
	call	printf
	addl	$8, %esp
	ret

__print_mem_map:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	$0, -4(%ebp)		# int i = 0;

	movl	$MEM_MAP_ENTRY_ADDR, %edi
  .__print_mem_map_loop:
	cmp	$0, -4(%ebp)
	jle	.__print_mem_map_item
	cmp	$0, START_LOW(%edi)
	jne	.__print_mem_map_item
	jmp	.__print_mem_map_end
  .__print_mem_map_item:
  	movl	TYPE(%edi), %eax
	cmp	$4, %eax		# if (type > 4) type = 2;
	jle	.__print_mem_map_print
	movl	$2, %eax
  .__print_mem_map_print:
  	decl	%eax			# 0 - 3
	pushl	msg_mem_type_str(, %eax, 4)
	incl	%eax			# 1 - 4
  	pushl	%eax
	pushl	SIZE_LOW(%edi)
	pushl	SIZE_HIGH(%edi)
	pushl	START_LOW(%edi)
	pushl	START_HIGH(%edi)
	pushl	-4(%ebp)
	pushl	$msg_mem_map
	call	printf
	addl	$32, %esp
	
  	incl	-4(%ebp)
	addl	$MM_ENTRY_SIZE, %edi
  	jmp	.__print_mem_map_loop

  .__print_mem_map_end:
	addl	$8, %esp
	leave
	ret


cur_pos:	.long 0xb8000
msg_mem_size:	.asciz "your computer has %d mb physical memory\n"
msg_mem_map:	.asciz "area: %d, start: 0x%x%x, length: 0x%x%x, type: %d(%s)\n"

# no ',' follows the last 1 in every line, otherwise as regrads it as a NULL pointer
msg_mem_type_str:
.long	msg_mem_map_type1, msg_mem_map_type2
.long	msg_mem_map_type3, msg_mem_map_type4

msg_mem_map_type1:	.asciz "available"
msg_mem_map_type2:	.asciz "reserved"
msg_mem_map_type3:	.asciz "acpi reclaim"
msg_mem_map_type4:	.asciz "acpi nvs memory"

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
