.code16	

.equ	root_offset, 9728 	# 19 * 512
.equ	root_secs, 14
.equ	root_start, 19	# 1 + 8 * 2
.equ	data_start, 33	# 19 + 14
.equ	dir_clus_offset, 0x1a

	jmp	start

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
bs_VolumeLabel: 	.ascii "treblih zy  "
bs_FileSystem: 	        .ascii "FAT12   "

#------------------------------------------------------------------ 
# load sector(s) in 3 different situation
# 1. root secs
# 2. FAT secs
# 3. loader.bin
#------------------------------------------------------------------ 
start:
	cli			
	movw	$0x07c0, %ax
	movw    %ax, %ds
	movw    %ax, %es
	movw    %ax, %gs

	movw    $0, %ax				
	movw    %ax, %ss
	movw    %sp, $0xffff
	sti				

	movw    $msgLoading, %si
	call    print

	;----------------------------------------------------
	; Load root directory table
	;----------------------------------------------------

load_root:
	movw	$root_start, %ax
	movw	$root_secs, %cx
	movw    $0x200, %bx
	call    read_secs

	;----------------------------------------------------
	; Find stage 2
	;----------------------------------------------------

	; browse root directory for binary image
	mov     %cx,  [bpbRootEntries]             ; load loop counter
	mov     $0x0200, %di                            ; locate first root entry
  .LOOP:
	push    %cx
	mov     $0x000B, %cx                            ; eleven character name
	mov     %si, ImageName                         ; image name to find
	push    %di
	rep  cmpsb                                         ; test for entry match
	pop     %di
	je      LOAD_FAT
	pop     %cx
	add     $0x0020, %di                            ; queue next directory entry
	loop    .LOOP
	jmp     FAILURE

	;----------------------------------------------------
	; Load FAT
	;----------------------------------------------------

LOAD_FAT:

	; save starting cluster of boot image

	mov     %si, msgCRLF
	call    print
	mov     %dx,  [%di + $0x001A]
	mov      [cluster], %dx                  ; file's first cluster

	; compute size of FAT and store in "%cx"

	xor     %ax, %ax
	mov     %al,  [bpbNumberOfFATs]          ; number of FATs
	mul      [bpbSectorsPerFAT]             ; sectors used by FATs
	mov     %ax, %cx

	; compute location of FAT and store in "%ax"

	mov     %ax,  [bpbReservedSectors]       ; adjust for bootsector

	; read FAT into memory (7C00:0200)

	mov     $0x0200, %bx                          ; copy FAT above bootcode
	call    read_secs

	; read image file into memory (0050:0000)

	mov     %si, msgCRLF
	call    print
	mov     $0x0050, %ax
	mov     %ax, %es                              ; destination for image
	mov     $0x0000, %bx                          ; destination for image
	push    %bx

	;----------------------------------------------------
	; Load Stage 2
	;----------------------------------------------------

LOAD_IMAGE:

	mov     %ax,  [cluster]                  ; cluster to read
	pop     %bx                                  ; buffer to read into
	call    clus2lba                          ; convert cluster to LBA
	xor     %cx, %cx
	mov     %cl,  [bpbSectorsPerCluster]     ; sectors to read
	call    read_secs
	push    %bx

	; compute next cluster

	mov     %ax,  [cluster]                  ; identify current cluster
	mov     %ax, %cx                              ; copy current cluster
	mov     %ax, %dx                              ; copy current cluster
	shr     $0x0001, %dx                          ; divide by two
	add     %dx, %cx                              ; sum for (3/2)
	mov     $0x0200, %bx                          ; location of FAT in memory
	add     %cx, %bx                              ; index into FAT
	mov     %dx,  [%bx]                       ; read two bytes from FAT
	test    $0x0001, %ax
	jnz     .ODD_CLUSTER

  .EVEN_CLUSTER:

	and     %dx, 0000111111111111b               ; take low twelve bits
	jmp     .DONE

  .ODD_CLUSTER:

	shr     $0x0004, %dx                          ; take high twelve bits

  .DONE:

	mov      [cluster], %dx                  ; store new cluster
	cmp     $0x0FF0, %dx                          ; test for end of file
	jb      LOAD_IMAGE

DONE:

	mov     %si, msgCRLF
	call    print
	push     $0x0050
	push     $0x0000
	retf

FAILURE:

	mov     %si, msgFailure
	call    print
	mov     $0x00, %ah
	int     $0x16                                ; await keypress
	int     $0x19                                ; warm boot computer

#------------------------------------------------------------------ 
# 
#------------------------------------------------------------------ 
print:
	lodsb			
	or	%%al, %%al	
	jz	.print_end
	movb	$0xe, %%ah
	int	$0x10
	jmp	print
  .print_end:
	ret	

;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:BX=>Buffer to read to
;************************************************;

read_secs:
  .main
	mov     %di, $5                          ; five retries for error
  .sectorloop
	push    %ax
	push    %bx
	push    %cx
	call    lba2chs                              ; convert starting sector to CHS
	mov     $0x02, %ah                            ; BIOS read sector
	mov     $0x01, %al                            ; read one sector
	mov     %ch,  [cylinder]            ; track
	mov     %cl,  [sector]           ; sector
	mov     %dh,  [head]             ; head
	mov     %dl,  [bsDriveNumber]            ; drive
	int     $0x13                                ; invoke BIOS
	jnc     .success                            ; test for read error
	xor     %ax, %ax                              ; BIOS reset disk
	int     $0x13                                ; invoke BIOS
	dec     %di                                  ; decrement error counter
	pop     %cx
	pop     %bx
	pop     %ax
	jnz     .sectorloop                         ; attempt to read again
	int     $0x18
  .SUCCESS
	mov     %si, msgProgress
	call    print
	pop     %cx
	pop     %bx
	pop     %ax
	add     %bx,  [bpbBytesPerSector]        ; queue next buffer
	inc     %ax                                  ; queue next sector
	loop    .main                               ; read next sector
	ret

#------------------------------------------------------------------ 
# lba = cluster - 2 + 33
# arg:	ax
#------------------------------------------------------------------ 
clus2lba:
	subw    $2, %ax  
	add     $data_start %ax
	ret

#------------------------------------------------------------------ 
# cylinder  = (logical sector / sectors per track) >> 1
# head      = (logical sector / sectors per track) & 1
# sector    = (logical sector MOD sectors per track) + 1
# arg:	ax
#------------------------------------------------------------------ 
lba2chs:
	pushw	%cx
	div	bpb_SectorsPerTrack
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



	sector .byte 0x00
	head   .byte 0x00
	cylinder  .byte 0x00

	data_start  .word 0x0000
	cluster     .word 0x0000
	ImageName   .byte "KRNLDR  SYS"
	msgLoading  .byte 0x0D, 0x0A, "Loading Boot Image ", 0x0D, 0x0A, 0x00
	msgCRLF     .byte 0x0D, 0x0A, 0x00
	msgProgress .byte ".", 0x00
	msgFailure  .byte 0x0D, 0x0A, "ERROR : Press Any Key to Reboot", 0x0A, 0x00

	TIMES 510-($-$$) DB 0
	DW 0xAA55
