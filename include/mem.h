.equ	MEM_MAP_ENTRY_ADDR,	0x1000
.equ	BOOT_INFO_ADDR,		0x1100

.equ	MM_ENTRY_SIZE,	20

# offset of elements in struct mem_map_entry
.equ	START_LOW,	0
.equ	START_HIGH,	4
.equ	SIZE_LOW,	8
.equ	SIZE_HIGH,	12
.equ	TYPE,		16

.equ	SMAP,		0x534d4150
# offset of elements in struct boot_info
.equ	MEM_LOW,	4
.equ	MEM_HIGH,	8

.equ	PMEM_BITVEC_ADDR,	0x30000
