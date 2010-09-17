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

/*-----------------------------------------------------------------------------
 *  extern from link.ld
 *  there's a global unsigned int var named "end"
 *  it's value is 0, and it's addr is the end of the image
 *-----------------------------------------------------------------------------*/
/* extern uint32_t end; */
/* uint32_t place_addr = (uint32_t) &end; */
static uint32_t place_addr = 0x200000;                              /* 2m */

uint32_t __get_heap_addr()
{
	return place_addr;
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  kmalloc
 *  Description:  
 * =====================================================================================
 */
uint32_t kmalloc_align_pa(size_t size, int is_align, uint32_t *pa)
{
	/*-----------------------------------------------------------------------------
	 *  align request && non-aligned indeed
	 *  if just use "if (is_align)", meanwhile it has been aligned,
	 *  += 0x1000 added also
	 *-----------------------------------------------------------------------------*/
	if (is_align && (place_addr & 0x00000fff)) {
		place_addr &= 0xfffff000;
		place_addr += 0x1000;
	}
	if (pa) {
		*pa = place_addr;
	}

	memset(place_addr, 0, size);
	uint32_t tmp = place_addr;
	place_addr += size;
	return tmp;
}

uint32_t kmalloc_align(size_t size)
{
	return kmalloc_align_pa(size, 1, 0);
}

uint32_t kmalloc_pa(size_t size, uint32_t *pa)
{
	return kmalloc_align_pa(size, 0, pa);
}

uint32_t kmalloc(size_t size)
{
	return kmalloc_align_pa(size, 0, 0);
}
