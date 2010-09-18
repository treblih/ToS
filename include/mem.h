.equ	MEM_MAP_ENTRY_ADDR,	0x1000
.equ	BOOT_INFO_ADDR,		0x1100
.equ	KRNL_RM_BASE,		0x20000
.equ	KRNL_PM_BASE,		0xc0000000

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

# virtual memroy
.equ	PDE,		0x40000
.equ	PT_0,		0x41000
.equ	PT_768,		0x42000

.equ	PRESENT,	0x1
.equ	RW,		0x10
.equ	USER,		0x100
