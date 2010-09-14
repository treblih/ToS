.include "mem.h"

.text
.code32

.globl	__pmem_init
.globl	__get_pmem_size
.globl	__print_pmem_map

__pmem_init:
	pushl	$msg_pmem_init
	call	puts
	addl	$4, %esp

	call	__get_pmem_size
	call	print_pmem_size
	shrl	$2, %eax		# xk / 4k, blocks wanted
	movl	%eax, PMEM_BLOCK_MAX
	shrl	$5, %eax		# / 32,    bytes wanted
	pushl	%eax
	pushl	$0
	pushl	$PMEM_BITVEC_ADDR
	call	memset
	add	$12, %esp
	ret

#------------------------------------------------------------------ 
# unsigned __get_pmem_size();
# ret:	%eax	memory size in kb
#------------------------------------------------------------------ 
__get_pmem_size:
	cmp	$0, PMEM_SIZE
	jg	.__get_pmem_size_end	# P_MEM_SIZE has been inited

	pushl	%ebx
	pushl	%edi
	# (low + 1024 + high * 64)
	movl	$BOOT_INFO_ADDR, %edi
	movl	MEM_LOW(%edi), %eax
	addl	$1024, %eax
	movl	MEM_HIGH(%edi), %ebx
	shll	$6, %ebx
	addl	%ebx, %eax
	# in kb, not mb
	# shrl	$10, %eax
	movl	%eax, PMEM_SIZE
  	popl	%edi
	popl	%ebx
  .__get_pmem_size_end:
  	movl	PMEM_SIZE, %eax
	ret

print_pmem_size:
  	movl	PMEM_SIZE, %eax
	shrl	$10, %eax		# kb / 1024 = mb
	pushl	%eax
	pushl	$msg_pmem_size
	call	printf
	addl	$8, %esp
	ret

#------------------------------------------------------------------ 
# void __print_pmem_map(void *callback);
#------------------------------------------------------------------ 
__print_pmem_map:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	$0, -4(%ebp)		# int i = 0;

	movl	$MEM_MAP_ENTRY_ADDR, %edi
  .__print_pmem_map_loop:
	cmp	$0, -4(%ebp)
	jle	.__print_pmem_map_item
	cmp	$0, START_LOW(%edi)
	jne	.__print_pmem_map_item
	jmp	.__print_pmem_map_end
  .__print_pmem_map_item:
  	movl	TYPE(%edi), %eax
	cmp	$4, %eax		# if (type > 4) type = 2;
	jle	.__print_pmem_map_process
	movl	$2, %eax
  .__print_pmem_map_process:
  	decl	%eax			# 0 - 3
	pushl	msg_pmem_type_str(, %eax, 4)
	incl	%eax			# 1 - 4
	cmp	$1, %eax
	jne	.__print_pmem_map_print
	/* call	8(%ebp) */
  .__print_pmem_map_print:
  	pushl	%eax
	movl	SIZE_HIGH(%edi), %eax
	shll	$16, %eax
	movl	SIZE_LOW(%edi), %eax
	pushl	%eax
	movl	START_HIGH(%edi), %eax
	shll	$16, %eax
	movl	START_LOW(%edi), %eax
	pushl	%eax
	pushl	-4(%ebp)
	pushl	$msg_pmem_map
	call	printf
	addl	$24, %esp
	
  	incl	-4(%ebp)
	addl	$MM_ENTRY_SIZE, %edi
  	jmp	.__print_pmem_map_loop

  .__print_pmem_map_end:
	addl	$8, %esp
	leave
	ret


PMEM_SIZE:	.long	0
PMEM_BLOCK_MAX:	.long	0
PMEM_BLOCK_USED:.long	0
PMEM_BITVEC:	.long	0

# no ',' follows the last 1 in every line, otherwise as regrads it as a NULL pointer
msg_pmem_type_str:
.long	msg_pmem_map_type1, msg_pmem_map_type2
.long	msg_pmem_map_type3, msg_pmem_map_type4

msg_pmem_map_type1:	.asciz "available"
msg_pmem_map_type2:	.asciz "reserved"
msg_pmem_map_type3:	.asciz "acpi reclaim"
msg_pmem_map_type4:	.asciz "acpi nvs memory"

msg_pmem_init:	.asciz "initializing physical memory structure ...\n"
msg_pmem_size:	.asciz "your computer has %d mb physical memory\n"
msg_pmem_map:	.asciz "area: %d, start: 0x%8x, length: 0x%8x, type: %d(%s)\n"
