.section .text
.code16	

.equ	mem_root, 0x7e00 # 0x7c00 + 0x200
.equ	mem_fat, 0x9a00	# 0x7e00 + 14 * 0x200 .equ	root_secs, 14
.equ	root_secs, 14
.equ	fat_start, 1
.equ	root_start, 19	# 1 + 8 * 2
.equ	data_start, 33	# 19 + 14
.equ	dir_clus_offset, 0x1a

	jmp	start
	nop

bs_OEMName:		.ascii "treblih "
bpb_BytesPerSector:	.word 512
bpb_SectorsPerCluster: 	.byte 1		# used
bpb_ReservedSectors: 	.word 1
bpb_NumberOfFATs: 	.byte 2
bpb_RootEntries: 	.word 224	# used
bpb_TotalSectors: 	.word 2880
bpb_Media: 	        .byte 0xf0
bpb_SectorsPerFAT: 	.word 9
bpb_SectorsPerTrack: 	.word 18
bpb_HeadsPerCylinder: 	.word 2
bpb_HiddenSectors: 	.long 0
bpb_TotalSectorsBig:    .long 0
bs_DriveNumber: 	.byte 0
bs_Unused: 	        .byte 0
bs_ExtBootSignatur:	.byte 0x29
bs_SerialNumber:	.long 0xa0a1a2a3
bs_VolumeLabel: 	.ascii "treblih zy "
bs_FileSystem: 	        .ascii "FAT12   "


#------------------------------------------------------------------ 
# load sector(s) in 3 different situation
# 1. root secs
# 2. FAT secs
# 3. loader.bin
#------------------------------------------------------------------ 
start:
	cli			
	movw	%cs, %ax
	movw    %ax, %ds
	movw    %ax, %es
	movw    %ax, %fs
	movw    %ax, %gs

	#----------------------------------------------------------
	# stack set to 0x9fc00,
	# can't be 0x9fc0:0, sp != 0
	# Extend BIOS Data Area - EBDA
	# 0x9fc00 - 0xa0000
	#----------------------------------------------------------
	movw	$0x9000, %ax
	movw    %ax, %ss
	movw    $0xfbff, %sp	
	sti				

	movw    $msg_search_loader, %si
	call    print

	# load 14 root secs to 0x7e00
	movw	$root_start, %ax
	movw	$root_secs, %cx
	movw	$mem_root, %bx	
	call	read_secs

	# find "LOADER  BIN" in root entries
	movw 	bpb_RootEntries, %cx
	movw 	%cx, rootent_loop
	movw 	$mem_root, %di	# 0x7e00
find_loader:
	movw 	$11, %cx	# max name 11 bytes
	movw 	$loader_name, %si
	cld
	repe 	cmpsb
	je 	loader_found
	andw	$0xfff0, %di	# clear least significant bits of di
	addw 	$0x20, %di	# + 32, point to the next entry
	subw 	$1, rootent_loop # not 'dec', as checking CF
	jnz 	find_loader
	jmp 	no_loader

loader_found:
	movw	$msg_loader_found, %si
	call	print

	subw	$11, %di	# get to the entry start
	addw	$dir_clus_offset, %di
	movw	(%di), %cx
	movw	%cx, loader_start_clus

	# load 8 FATs to 0x9a00
	movw	$fat_start, %ax
	movw	$9, %cx
	movw    $mem_fat, %bx                          
	call    read_secs

	# load loader.bin to 0050:0000
	movw    loader_start_clus, %ax	# for next_cluster
	xor	%dx, %dx
cluster_sequence:
	inc	%dx
	call	next_cluster
	andb	$0x0f, %ah	# make sure ax only has 12 bits
	cmp	$0xff7, %ax
	jl	cluster_sequence

	movw    loader_start_clus, %ax
	call    clus2lba                       
	movw	%dx, %cx	# how many
	movw	$0x500, %bx	# es:bx 0:500
	call    read_secs
	movw	$msg_load_done, %si
	call	print

	jmp	$0, $0x500

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
# lba = loader_start_clus - 2 + 33
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

no_loader:
	movw 	$msg_no_loader, %si
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
loader_start_clus:     	.word 0

	# asciz rather than ascii,
	# we use int 0x13 func 0xe, 
	# or %al, %al
loader_name:		.ascii "LOADER  BIN"

msg_search_loader:  	.asciz "\r\nSearching Loader\r\n"
msg_loader_found:	.asciz "Loader Found\r\n"
msg_load_done:		.asciz "Load Done\r\n"
msg_no_loader:		.asciz "Loader Not Found\r\n"
msg_reboot:		.asciz "Press Any Key to Reboot\r\n"

.org	510
.byte	0x55
.byte	0xaa
