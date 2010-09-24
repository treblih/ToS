.include "vfs.inc"

.section .text

.globl	read
.globl	write
.globl	open
.globl	close
.globl	readdir
.globl	finddir

	.type	read, @function
read:
	movl	NODE_READ(%esp), %eax
	test	%eax, %eax
	je	.read_no_call
	call	*eax
	jmp	.read_end
  .read_no_call:
  	movl	$0, %eax
  .read_end:
	ret

	.type	write, @function
write:
	movl	NODE_WRITE(%esp), %eax
	test	%eax, %eax
	je	.write_no_call
	call	*eax
	jmp	.write_end
  .write_no_call:
  	movl	$0, %eax
  .write_end:
	ret

	.type	open, @function
open:
	call	*NODE_OPEN(%esp)
	ret

	.type	close, @function
close:
	call	*NODE_CLOSE(%esp)
	ret

	.type	readdir, @function
readdir:
	movl	NODE_FLAGS(%esp), %eax
	andl	$0x7, %eax
	cmp	$DIRECTORY, %eax
	jne	.readdir_end
	call	*NODE_READDIR(%esp)
  .readdir_end:
	ret

	.type	finddir, @function
finddir:
	movl	NODE_FLAGS(%esp), %eax
	andl	$0x7, %eax
	cmp	$DIRECTORY, %eax
	jne	.finddir_end
	call	*NODE_FINDDIR(%esp)
  .finddir_end:
	ret
