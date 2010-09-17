/*
 * =====================================================================================
 *
 *       Filename:  kmalloc.c
 *
 *    Description:  
 *
 *        Created:  15.09.10
 *       Revision:  
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include <stdlib.h>
#include <string.h>

/*-----------------------------------------------------------------------------
 *  extern from link.ld
 *  there's a global unsigned int var named "end"
 *  it's value is 0, and it's addr is the end of the image
 *-----------------------------------------------------------------------------*/
/* extern unsigned char *end; */
/* unsigned char *place_addr = (uint32_t) &end; */
/* static unsigned char *place_addr = (unsigned char *)0x50000; */
static unsigned char *place_addr; 

unsigned char *__get_heap_addr()
{
	return place_addr;
}

void *__set_heap_addr(unsigned char *p)
{
	place_addr = p;
	return NULL;
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  kmalloc
 *  Description:  
 * =====================================================================================
 */
void *kmalloc_align_pa(size_t size, int is_align, unsigned char **pa)
{
	/*-----------------------------------------------------------------------------
	 *  align request && non-aligned indeed
	 *  if just use "if (is_align)", meanwhile it has been aligned,
	 *  += 0x1000 added also
	 *-----------------------------------------------------------------------------*/
	if (is_align && ((uint32_t)place_addr & 0x00000fff)) {
		place_addr = (unsigned char *)((uint32_t)place_addr & 0xfffff000);
		place_addr += 0x1000;
	}
	if (pa) {
		*pa = place_addr;
	}

	memset((unsigned char *)place_addr, 0, size);
	unsigned char *tmp = place_addr;
	place_addr += size;
	return (void *)tmp;
}

void *kmalloc_align(size_t size)
{
	return kmalloc_align_pa(size, 1, 0);
}

void *kmalloc_pa(size_t size, unsigned char **pa)
{
	return kmalloc_align_pa(size, 0, pa);
}

void *kmalloc(size_t size)
{
	return kmalloc_align_pa(size, 0, 0);
}
