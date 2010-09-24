.include "mem.inc"

.equ	BIT_SET,	1
.equ	BIT_PMEM,	1

.section .text

.globl	__pmem_init
.globl	__get_pmem_size
.globl	__get_pmem_bitvec_addr

#------------------------------------------------------------------ 
# unsigned __pmem_init();
# get bit vectors for physical memory by kmalloc_align
# then init the bit vectors
#------------------------------------------------------------------ 
	.type	__pmem_init, @function
__pmem_init:
	pushl	%ebp
	movl	%esp, %ebp

	pushl	$msg_pmem_init
	call	puts
	addl	$4, %esp

	movl	$0, PMEM_SIZE
	call	__get_pmem_size
	call	print_pmem_size
	shrl	$2, %eax		# xk / 4k, blocks wanted
	movl	%eax, PMEM_BLOCK_MAX

	# __set_heap_addr(unsigned char *);
	pushl	$0xc0100000		# 2m in pmem
	call	__set_heap_addr
	addl	$4, %esp

	# bitvec_create(int);
	pushl	$BIT_PMEM
	call	bitvec_create
	addl	$4, %esp
	movl	%eax, PMEM_BITVEC_ADDR

	# bitvec_init(bitvec_t *, int);
	pushl	PMEM_BLOCK_MAX
	pushl	%eax
	call	bitvec_init
	addl	$8, %esp

	# set 0 - 1m used
	# bitvec_ctrl(bitvec_t *, ssize_t, ssize_t, int);
	pushl	$BIT_SET
	pushl	$0x100			# 0x100000 / 0x1000, 1m / 4k
	pushl	$0
	pushl	PMEM_BITVEC_ADDR
	call	bitvec_ctrl
	addl	$16, %esp

	call	print_pmem_map

	leave
	ret

#------------------------------------------------------------------ 
# unsigned __get_pmem_size();
# ret:	%eax	memory size in kb
#------------------------------------------------------------------ 
	.type	__get_pmem_size, @function
__get_pmem_size:
	cmp	$0, PMEM_SIZE
	jg	.__get_pmem_size_end	# P_MEM_SIZE has been inited

	pushl	%ebx
	pushl	%edi

#----------------------------------------------------
# MEM_LOW / MEM_HIGH in BOOT_INFO if diff from MEM_MAP_ENTRY
# in kb
# 	(low + 1024 + high * 64)
	movl	$BOOT_INFO_ADDR, %edi
#----------------------------------------------------
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

	.type	print_pmem_size, @function
print_pmem_size:
	pushl	%eax
  	movl	PMEM_SIZE, %eax
	shrl	$10, %eax		# kb / 1024 = mb
	pushl	%eax
	pushl	$msg_pmem_size
	call	printf
	addl	$8, %esp
	popl	%eax
	ret

#------------------------------------------------------------------ 
# void print_pmem_map();
#------------------------------------------------------------------ 
	.type	print_pmem_map, @function
print_pmem_map:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	$0, -4(%ebp)		# int i = 0;

#----------------------------------------------------
# START_LOW / START_HIGH in MEM_MAP_ENTRY if diff from BOOT_INFO
# in bytes
	movl	$MEM_MAP_ENTRY_ADDR, %edi
#----------------------------------------------------
  .print_pmem_map_loop:
	cmp	$0, -4(%ebp)
	jle	.print_pmem_map_item
	cmp	$0, START_LOW(%edi)
	jne	.print_pmem_map_item
	jmp	.print_pmem_map_end
  .print_pmem_map_item:
  	movl	TYPE(%edi), %eax
	cmp	$4, %eax		# if (type > 4) type = 2;
	jle	.print_pmem_map_process
	movl	$2, %eax
  .print_pmem_map_process:
  	decl	%eax			# 0 - 3
	pushl	msg_pmem_type_str(, %eax, 4)
	incl	%eax			# 1 - 4
	cmp	$1, %eax
	pushl	%eax
	je	.print_pmem_map_print

	# if type != 1, set the corresponding pmem bits to 1, namely, used
	# bitvec_ctrl(bitvec_t *, ssize_t, ssize_t, int);
	pushl	$BIT_SET
	movl	SIZE_HIGH(%edi), %eax
	shll	$16, %eax
	addl	SIZE_LOW(%edi), %eax
	shrl	$12, %eax		# / 4k == block count
	pushl	%eax
	movl	START_HIGH(%edi), %eax
	shll	$16, %eax
	addl	START_LOW(%edi), %eax
	# see the last in the memory map entry, u'll know
	cmp	$0, %eax
	je	.print_pmem_map_print
	shrl	$12, %eax		# / 4k == block start
	pushl	%eax
	pushl	PMEM_BITVEC_ADDR
	call	bitvec_ctrl
	addl	$16, %esp

  .print_pmem_map_print:
  	popl	%eax
  	pushl	%eax
	movl	SIZE_HIGH(%edi), %eax
	shll	$16, %eax
	addl	SIZE_LOW(%edi), %eax
	pushl	%eax
	movl	START_HIGH(%edi), %eax
	shll	$16, %eax
	addl	START_LOW(%edi), %eax
	pushl	%eax
	pushl	-4(%ebp)
	pushl	$msg_pmem_map
	call	printf
	addl	$24, %esp
	
  	incl	-4(%ebp)
	addl	$MM_ENTRY_SIZE, %edi
  	jmp	.print_pmem_map_loop

  .print_pmem_map_end:
	addl	$8, %esp
	leave
	ret


.section .data
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

.section .bss
.lcomm PMEM_SIZE, 	4
.lcomm PMEM_BLOCK_MAX,	4
.lcomm PMEM_BLOCK_USED, 4
.lcomm PMEM_BITVEC_ADDR,4
