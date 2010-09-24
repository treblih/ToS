.include "vfs.inc"
.include "initrd.inc"

.section .text

.globl	__initrd_init

	.type	read, @function
read:
	call	*READ(%esp)
	ret

	.type	write, @function
write:
	call	*WRITE(%esp)
	ret

	.type	open, @function
open:
	call	*OPEN(%esp)
	ret

	.type	close, @function
close:
	call	*CLOSE(%esp)
	ret

	.type	readdir, @function
readdir:
	movl	FLAG(%esp), %eax
	andl	$0x7, %eax
	cmp	$DIRECTORY, %eax
	jne	.readdir_end
	call	*READDIR(%esp)
  .readdir_end:
	ret

	.type	finddir, @function
finddir:
	movl	FLAG(%esp), %eax
	andl	$0x7, %eax
	cmp	$DIRECTORY, %eax
	jne	.finddir_end
	call	*FINDDIR(%esp)
  .finddir_end:
	ret

	.type	__initrd_init, @function
__initrd_init:
	ret
