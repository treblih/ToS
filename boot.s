.code16
.text
.equ root_offset, 9728 	# 19 * 512
.equ root_secs, 14
.equ root_start, 19	# 1 + 8 * 2
.equ data_start, 33	# 19 + 14
.equ dir_clus_offset, 0x1a

    jmp main

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

cylinder:	.byte 0
head:		.byte 0
sector:		.byte 0
rootent_loop:	.byte 0	# from 224 to 0
sec_num:	.word 0
fat_ent:	.word 0
loader_name:	.ascii "LOADER  BIN"
no_loader_str:	.ascii "Loader not found! Panic!"


main:
    movw $0x7c00, %ax
    movw %ax, %cs
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0xffff, %sp

reset_floppy:
    xor %ah, %ah	# func 0 is reset
    xor %dl, %dl	# drive 0 is floppy disk
    int $0x13
    jc reset_floppy	# error happens when CF set, try again

    movw bpb_RootEntries, %cx
    movw %cx, rootent_loop
    movw $root_offset, %di
find_loader:
    movw $11, %cx	# max name 11 bytes
    movw $loader_name, %si
    cld
    repe cmpsb
    je loader_found
    addw $32, %di
    subw $1, rootent_loop # not 'dec', as checking CF
    jnz find_loader
    jmp no_loader

loader_found:
    subw $11, %di	# get to the entry start
    addw $dir_clus_offset, %di
    movw (%di), %cx	# LBA
    movw $0, %ax	# sectors wanted at 1 time
    movw $0x200, fat_ent # fat is in the 2nd sector
find_sequence:
    inc %al
    call get_fat
    cmp $0xff7, %cx
    jl find_sequence
    call lba2chs
    movb $2, %ah
    movb $0, %dl
    movw $0x200, %bx	# follow the boot sector
    int $0x13
    jmp $0x7c00, $0x300

get_fat:		# cx arg/retval
    pushw %ax
    pushw %bx
    pushw %dx
    movw %cx, %ax
    subw $2, %ax	# sector offset
    movw $3, %bx
    mulw %bx
    movw $2, %bx
    div %bx		# least significant bit to CF
    cmp $0, %dx		# remainder
    addw $fat_sec, %ax
    movw (%cx), %dx
    jnz odd
    andw 0x0fff, %dx	# even, 0-11
    movw %dx, %cx
    jmp end_get_fat
odd:
    andw 0xfff0, %dx	# odd, 12-23
    movw %dx, %cx
end_get_fat:
    popw %dx
    popw %bx
    popw %ax
    ret

lba2chs:
    pushb %al
    movw (%di), %ax
    call clus2lba
    xor %bx, %bx
    movb $18, %bl
    div %bl
    movb %al, %ch	
    movb %al, %dh
    movb %ah, %cl	
    shrb %ch		# C
    andb $1, %dh	# H
    inc %cl		# S
    popb %al
    ret

clus2lba:		# ax arg/retval
    subw $2, %ax
    addw $19, %ax
    ret

no_loader:
    movw $no_loader_str, %ax
    movw %ax, %bp
    movw $24, %cx	# 24 chars
    movw $0x1301, %ax
    movw $0xc, %bx
    movb $0, %dl
    int  $0x10
    jmp .

.org 510
.word 0xaa55
