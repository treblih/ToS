.equ	MM_ENTRY_SIZE,	20
.equ	SMAP,		0x534d4150


.macro mem_map_entry
	.quad
	.quad
	.long
	.long
.endm
