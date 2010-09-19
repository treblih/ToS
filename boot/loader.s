.include "pmode.h"
.include "mem.h"

.text
.code16

.equ	bpb_RootEntries, 224
.equ	mem_root, 0x7e00 # 0x7c00 + 0x200
.equ	mem_fat, 0x9a00	# 0x7e00 + 14 * 0x200
.equ	root_secs, 14
.equ	fat_start, 1
.equ	root_start, 19	# 1 + 8 * 2
.equ	data_start, 33	# 19 + 14
.equ	dir_clus_offset, 0x1a

#------------------------------------------------------------------ 
# jump from boot sector to here
# 0:500
#------------------------------------------------------------------ 
	# func 0, al == 2, 80 * 25, 16 colors
	movw	$0x002, %ax
	int 	$0x10

	# clear screen
	# movw	$0x600, %ax	# func 6, al == 0 => clear
 	# movb	$7, %bh
 	# xor	%cx, %cx
 	# movw	$0x1950, %dx
 	# int	$0x10

	# set background color, func 0xb
	movb	$0xb, %ah
	movw	$0x003, %bx	# bh == 0, background
	int	$0x10

	# set cursor position, func 2
	# movb	$2, %ah
	# movb	$0, %bh		# page 0
	# movw	$0, %dx		# 0 row 0 column
	# int	$0x10

	call	get_mem_map
	pushw	%ax
	pushw	%bx
	xor	%eax, %eax
	xor	%ebx, %ebx
	movw	$BOOT_INFO_ADDR, %di
	call	get_mem_size
	movl	%eax, MEM_LOW(%di)
	movl	%ebx, MEM_HIGH(%di)
	popw	%bx
	popw	%ax

	movw	$msg_loader_welcome, %si
	call	print
	movw	$msg_search_kernel, %si
	call	print

	# find "KERNEL  ELF" in root entries
	movw 	$bpb_RootEntries, %cx
	movb 	%cl, rootent_loop
	movw 	$mem_root, %di	# 0x7e00
find_kernel:
	movw 	$11, %cx	# max name 11 bytes
	movw 	$kernel_name, %si
	cld
	repe 	cmpsb
	je 	kernel_found
	andw	$0xfff0, %di	# clear least significant bits of di
	addw 	$0x20, %di	# + 32, point to the next entry
	subb 	$1, rootent_loop # not 'dec', as checking CF
	jnz 	find_kernel
	jmp 	no_kernel

kernel_found:
	movw	$msg_kernel_found, %si
	call	print

	subw	$11, %di	# get to the entry start
	addw	$dir_clus_offset, %di
	movw	(%di), %cx
	movw	%cx, kernel_start_clus

	# load kernel.bin to 0x20000
	movw    kernel_start_clus, %ax	# for next_cluster
	xor	%dx, %dx
cluster_sequence:
	inc	%dx
	call	next_cluster
	andb	$0x0f, %ah	# make sure ax only has 12 bits
	cmp	$0xff7, %ax
	jl	cluster_sequence

	movw    kernel_start_clus, %ax
	call    clus2lba                       
	movw	%dx, %cx	# how many
	movw	%dx, IMAGE_SECTORS
	movw	$0x2000, %bx	# es:bx 2000:0
	movw	%bx, %es
	movw	$0, %bx
	call    read_secs
	movw	$msg_load_done, %si
	call	print
	movw	$msg_key_to_jmp, %si
	call	print
	# int 0x16, func 0, await a input char
	movb    $0, %ah
	int     $0x16                             
	# shut down floppy LED
	call	kill_flp_motor

	jmp	prepare_pmode


#------------------------------------------------------------------ 
# int 0x10, func 0xe
# arg:	bp es:bp string start
# 	cx string length
#	dh start row
#	dl start column
#------------------------------------------------------------------ 
	#movb	$0x13, %ah
	#movb	$0, %bh		# page 0
	#movb	$1, %al		# write mode
	#int	$0x10
	#ret	
print:
	lodsb			
	or	%al, %al	
	jz	.print_end
	movb	$0xe, %ah
	int	$0x10
	jmp	print
  .print_end:
	ret	
#------------------------------------------------------------------ 
# int 0x13, func 0x2
# arg:	ax starting sector
#	cx how many at 1 time
# 	bx load to es:bx
#------------------------------------------------------------------ 
read_secs:
	movw	$5, %di  	# five retries for error
  .sectorloop:
  	pushw	%ax
	pushw	%bx
	pushw	%cx
  	# use ax
	call    lba2chs                              
	movw	%cx, %ax
	movb    $0x02, %ah 	# func 2, now al hold the numbers
	movb    cylinder, %ch
	movb    sector, %cl
	movb    head, %dh
	movb    $0, %dl		# drive number
	int     $0x13            
	jnc     .success        # test for read error
	dec     %di             
	popw    %cx
	popw    %bx
	popw    %ax
	jnz     .sectorloop     # read again
	int     $0x18		# execute Cassette BASIC
  .success:
	popw    %cx
	popw    %bx
	popw    %ax
	ret

#------------------------------------------------------------------ 
# lba = kernel_start_clus - 2 + 33
# arg:	ax
#------------------------------------------------------------------ 
clus2lba:
	subw    $2, %ax  
	addw    $data_start, %ax
	ret

#------------------------------------------------------------------ 
# cylinder  = (logical sector / sectors per track) >> 1
# head      = (logical sector / sectors per track) & 1
# sector    = (logical sector MOD sectors per track) + 1
# arg:	ax LBA
#------------------------------------------------------------------ 
lba2chs:
	pushw	%cx
	divb	bpb_SectorsPerTrack
	movb 	%al, %ch	
	shrb 	%ch		# C
	movb	%ch, cylinder
	movb 	%al, %ch
	andb	$1, %ch		# H
	movb	%ch, head
	movb	%ah, %cl	
	inc 	%cl		# S
	movb	%cl, sector
	popw	%cx
	ret

#------------------------------------------------------------------ 
# search in FAT and find the sequent clusters
# arg:	ax current cluster
# ret:	ax the next cluster
#------------------------------------------------------------------ 
next_cluster:
	pushw	%bx
	pushw	%dx
	movw	$3, %bx
	mulw	%bx
	movw	$2, %bx
	div	%bx		# least significant bit to CF
	addw	$mem_fat, %ax	# 0x7c00 + 0x200 + ax
	movw	%ax, %bx
	movw	%es:(%bx), %ax	# 2 bytes

	cmp	$0, %dx		# remainder
	jz	.end_next_cluster
	shrw	$4, %ax
#	jmp	.end_next_cluster
#  .even:
#	andb	0x0f, %ah	# even, 0-11
  .end_next_cluster:
	popw	%dx
	popw	%bx
    	ret

kill_flp_motor:
	pushw	%dx
	movw	$0x3f2, %dx
	movb	$0, %al
	outb	%al, %dx
	popw	%dx
	ret

no_kernel:
	movw 	$msg_no_kernel, %si
	call	print
	movw	$msg_reboot, %si
	call	print
	# int 0x16, func 0, await a input char
	movb    $0, %ah
	int     $0x16                             
	# warm reboot
	int     $0x19                            

#---------------------------------------------
# get memory map from bios
# arg:	es:di	destination buffer for entries
# ret:	bp	entry count
#---------------------------------------------
get_mem_map:
	push	%bp
	xor	%ebp, %ebp
	mov	%sp, %bp
	sub	$2, %sp
	movw	$0, -2(%bp)
	pusha

	xor	%eax, %eax
	xor	%ebx, %ebx
	xor	%ecx, %ecx
	movl	$MEM_MAP_ENTRY_ADDR, %edi
  .get_mem_map_loop:
	movl	$SMAP, %edx
	mov	$0xe820, %ax
	mov	$MM_ENTRY_SIZE, %cx
	int	$0x15			
	jc	.get_mem_map_error	
	cmp	$SMAP, %eax 		# bios returns SMAP in eax
	jne	.get_mem_map_error
	test	%bx, %bx		# if ebx=0 then list is one entry long
	je	.get_mem_map_error

	add	$MM_ENTRY_SIZE, %edi
	incw	-2(%bp)
	cmp	$0, %bx
	jne	.get_mem_map_loop
	jmp	.get_mem_map_end
  .get_mem_map_error:
	movw	$0, -2(%bp)
  .get_mem_map_end:
  	popa
  	add	$2, %sp
	leave
  	ret

#----------------------------------------------------------
# arg:
# ret:	eax	extended memory between 1MB and 16MB in KB
#	ebx	extended memory above 16MB, in 64KB blocks
#----------------------------------------------------------
get_mem_size:
	pushw	%cx
	pushw	%dx

	movw	$0xe801, %ax
	int	$0x15
	jc	.get_mem_size_error
	cmp	$0x86, %ah		# unsupported function
	je	.get_mem_size_error
	cmp	$0x80, %ah		# invalid command
	je	.get_mem_size_error
	jcxz	.get_mem_size_use_ax	# bios may have stored it in ax/bx or cx/dx
	movw	%cx, %ax
	movw	%dx, %bx
	jmp	.get_mem_size_use_ax
  .get_mem_size_error:
  	movw	$-1, %ax
	movw	$0, %bx
  .get_mem_size_use_ax:
	popw	%dx
	popw	%cx
	ret

#----------------------------------------------------------
# prepare for PMODE
#----------------------------------------------------------
prepare_pmode:
	movl	IMAGE_SECTORS, %edx
	lgdt	__gdtr
	cli
	inb	$0x92, %al
	or	$0b10, %al
	outb	%al, $0x92
	movl	%cr0, %eax
	or	$0b1, %eax
	movl	%eax, %cr0

	# long jump, 0x66
	/* ljmpl	$slc_krnl_rx, $KRNL_RM_BASE + 0x100 */
	ljmpl	$slc_krnl_rx, $pm_start

.text
.code32
pm_start:
	# flush sregs
	movl	$0x10, %eax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %gs
	movw	%ax, %ss
	movl	$0x2ffff, %esp

	# copy kernel image from 0x20000 to 1m
	movl	IMAGE_SECTORS, %ecx
	shll	$7, %ecx		# %ecx * 512 / 4
	movl	$KRNL_RM_BASE, %esi
	movl	$0x100000, %edi
	cld
	rep	movsl
	
	# set up paging
	# 0 - 4m
	pushl	$0 | PRESENT | RW
	pushl	$PT_0
	call	__pt_init
	addl	$8, %esp
	# 3g
	pushl	$0x100000 | PRESENT | RW
	pushl	$PT_768
	call	__pt_init
	addl	$8, %esp

	movl	$PDE, %edi
	movl	$PT_0 | PRESENT | RW, (%edi)
	movl	$768, %eax
	movl	$PT_768 | PRESENT | RW, (%edi, %eax, 4)

	# enable paging
	movl	$PDE, %eax
	movl	%eax, %cr3
	movl	%cr0, %eax
	orl	$0x80000000, %eax
	movl	%eax, %cr0

	/* call	__KRNL_3G */
	/* movl	$__kernel, %eax */
	/* addl	$KRNL_PM_BASE, %eax */
	/* call	%eax */
	jmp	0xc0000100
	cli
	hlt

#------------------------------------------------------------------ 
# __pt_init(unsigned *, unsigned);
#------------------------------------------------------------------ 
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

.data
sector: 		.byte 0
head:   		.byte 0
cylinder:  		.byte 0
rootent_loop:		.byte 0		# from 224 to 0
kernel_start_clus:     	.word 0
bpb_SectorsPerTrack:	.word 18
IMAGE_SECTORS:		.long 0

kernel_name:		.ascii "KERNEL  ELF"

msg_loader_welcome:	.asciz "Welcome to Loader Stage 2\r\n"	# 25
msg_search_kernel:  	.asciz "Searching Kernel\r\n"		# 16
msg_kernel_found:	.asciz "Kernel Found, Loading..\r\n"	# 23
msg_load_done:		.asciz "Load Done\r\n"			# 9
msg_key_to_jmp:		.asciz "Any Key to Involve into Protect Mode & Kernel\r\n"	# 23
msg_no_kernel:		.asciz "Kernel Not Found\r\n"		# 16
msg_reboot:		.asciz "Press Any Key to Reboot\r\n"	# 23
msg_pmode:		.asciz "now in protect mode\n"

__gdt:
__dummy:	.quad 0
__kerneL_cs: gdt 0, 0xfffff, GDT_RX | GDT_32 | GDT_4K
__kerneL_ds: gdt 0, 0xfffff, GDT_RW | GDT_32 | GDT_4K

__gdtr:		.word __gdtr - __gdt - 1
		.long __gdt
