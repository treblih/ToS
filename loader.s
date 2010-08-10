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

.equ	GDT_32, 0x4000
.equ	GDT_GRANULARITY_4K, 0x8000
.equ	GDT_DPL0, 0
.equ	GDT_DPL1, 0x20
.equ	GDT_DPL2, 0x40
.equ	GDT_DPL3, 0x60
.equ	GDT_RW, 0x92
.equ	GDT_X, 0x98
.equ	GDT_RX, 0x9a

#------------------------------------------------------------------ 
# jump from boot sector to here
#------------------------------------------------------------------ 
	# clear screen
	movw	$0x600, %ax
 	movw	$0xa00, %bx
 	xor	%cx, %cx
 	movw	$0x184f, %dx
 	int	$0x10

	movb	$0xb, %ah
	movb	$1, %bh
	int	$0x10

	# set cursor position, func 2
	movb	$2, %ah
	movb	$0, %bh		# page 0
	movw	$0, %dx		# 0 row 0 column
	int	$0x10
	
	movw	$msg_search_kernel, %si
	call	print

	# find "KERNEL  ELF" in root entries
	movw 	$bpb_RootEntries, %cx
	movw 	%cx, rootent_loop
	movw 	$mem_root, %di	# 0x7e00
find_kernel:
	movw 	$11, %cx	# max name 11 bytes
	movw 	$kernel_name, %si
	cld
	repe 	cmpsb
	je 	kernel_found
	andw	$0xfff0, %di	# clear least significant bits of di
	addw 	$0x20, %di	# + 32, point to the next entry
	subw 	$1, rootent_loop # not 'dec', as checking CF
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
	movw	$0x2000, %bx	# es:bx 2000:0
	movw	%bx, %es
	movw	$0, %bx
	call    read_secs
	movw	$msg_load_done, %si
	call	print
	# shut down floppy LED
	call	kill_flp_motor

	#----------------------------------------------------------
	# prepare for PMODE
	#----------------------------------------------------------
	lgdt	gdtr
	cli
	inb	$0x92, %al
	or	$0b10, %al
	outb	%al, $0x92
	movl	%cr0, %eax
	or	$0b1, %eax
	movl	%eax, %cr0

	ljmpl	$8, $0x20100


#------------------------------------------------------------------ 
# int 0x10, func 0xe
# arg:	si the string
# 	al hold the char
#------------------------------------------------------------------ 
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

sector: 		.byte 0
head:   		.byte 0
cylinder:  		.byte 0
rootent_loop:		.byte 0		# from 224 to 0
kernel_start_clus:     	.word 0
bpb_SectorsPerTrack:	.word 18

kernel_name:		.ascii "KERNEL  ELF"

msg_search_kernel:  	.asciz "\r\nSearching Kernel\r\n"
msg_kernel_found:	.asciz "Kernel Found\r\n"
msg_load_done:		.asciz "Load Done\r\n"
msg_no_kernel:		.asciz "Kernel Not Found\r\n"
msg_reboot:		.asciz "Press Any Key to Reboot\r\n"

.macro gdt base limit attr
	.word	\limit & 0xffff
	.word	\base & 0xffff
	.byte 	(\base >> 16) & 0xff
	.word	((\limit >> 8) & 0x0f00) | (\attr & 0xf0ff)
	.byte	(\base >> 24) & 0xff
.endm

gdt:
gdt_dummy:		.quad 0
__KERNEL_CS: gdt 0, 0xfffff, GDT_X | GDT_32 | GDT_GRANULARITY_4K
__KERNEL_DS: gdt 0, 0xfffff, GDT_RW | GDT_32 | GDT_GRANULARITY_4K
__KERNEL_VD: gdt 0xb8000, 0xffff, GDT_RW | GDT_DPL3

gdtr:			.word gdtr - gdt - 1
			.long gdt
