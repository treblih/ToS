.equ	FILE_NAME_SIZE,	0x20	# only 32 bytes

#------------------------------------------------------------------ 
# struct node_t
#------------------------------------------------------------------ 
.equ	NODE_MASK,	0x0
.equ	NODE_UID,	0x4
.equ	NODE_GID,	0x8
.equ	NODE_FLAGS,	0xc
.equ	NODE_INODE,	0x10
.equ	NODE_LEN,	0x14
	# implementation-defined number
.equ	NODE_IMPL,	0x18
	# func pointers
.equ	NODE_READ,	0x1c
.equ	NODE_WRITE,	0x20
.equ	NODE_OPEN,	0x24
.equ	NODE_CLOSE,	0x28
.equ	NODE_READDIR,	0x2c
.equ	NODE_FINDDIR,	0x30
	# pointer to struct node_t
	# used by mountpoint & symbol link
.equ	NODE_NODE,	0x34
.equ	NODE_NAME,	0x38

#------------------------------------------------------------------ 
# flags, file type
#------------------------------------------------------------------ 
.equ	FILE,		0x01
.equ	DIRECTORY,	0x02
.equ	CHARDEVICE,	0x03
.equ	BLOCKDEVICE,	0x04
.equ	PIPE,		0x05
.equ	SYMLINK,	0x06
	# file is an active mountpoint
.equ	MOUNTPOINT,	0x08	

#------------------------------------------------------------------ 
# struct dirent
#------------------------------------------------------------------ 
.equ	DIRENT_INO,	0x0
.equ	DIRENT_NAME,	0x4
