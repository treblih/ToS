# master
.equ	REG_COMMAND,	0x20
.equ	REG_STATUS,	0x20
.equ	REG_IMR,	0x21
.equ	REG_DATA,	0x21
 
# slave
.equ	REG_COMMAND_S,	0xa0	
.equ	REG_STATUS_S,	0xa0
.equ	REG_IMR_S,	0xa1
.equ	REG_DATA_S,	0xa1

# master
.equ	IRQ_TIMER,	0
.equ	IRQ_KEYBOARD,	1
.equ	IRQ_SERIAL2,	3
.equ	IRQ_SERIAL1,	4
.equ	IRQ_PARALLEL2,	5
.equ	IRQ_DISKETTE,	6
.equ	IRQ_PARALLEL1,	7

# slave
.equ	IRQ_CMOSTIMER,	0
.equ	IRQ_CGARETRACE,	1
.equ	IRQ_AUXILIARY,	4
.equ	IRQ_FPU,		5
.equ	IRQ_HDC,		6

# OCW2
.equ	OCW2_MASK_L1,		1	# 00000001	Level 1 interrupt level
.equ	OCW2_MASK_L2,		2	# 00000010	Level 2 interrupt level
.equ	OCW2_MASK_L3,		4	# 00000100	Level 3 interrupt level
.equ	OCW2_MASK_EOI,		0x20	# 00100000	End of Interrupt command
.equ	OCW2_MASK_SL,		0x40	# 01000000	Select command
.equ	OCW2_MASK_ROTATE,	0x80	# 10000000	Rotation command

# OCW3
.equ	OCW3_MASK_RIS,		1	# 00000001
.equ	OCW3_MASK_RIR,		2	# 00000010
.equ	OCW3_MASK_MODE,		4	# 00000100
.equ	OCW3_MASK_SMM,		0x20	# 00100000
.equ	OCW3_MASK_ESMM,		0x40	# 01000000
.equ	OCW3_MASK_D7,		0x80	# 10000000
