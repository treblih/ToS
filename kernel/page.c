/*
 * =====================================================================================
 *
 *       Filename:  page.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  08.03.10
 *       Revision:  
 *       Compiler:  GCC 4.4.3
 *
 *         Author:  Yang Zhang, imyeyeslove@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include	"string.h"
#include	"assert.h"
#include	<kheap.h>
#include	<omfc/Bitvec.h>
#include	<omfc/Heap.h>
#include	<omfc/List.h>

#define		PAGE_IMP
#include	<page.h>


#define		ALIGN(pa)                               \
do {                                                    \
    if (pa & 0x00000fff)                                \
    {                                                   \
        pa &= 0xfffff000;                               \
        pa += 0x1000;                                   \
    }                                                   \
} while (0)


PDE * ker_pdir;
PDE * cur_pdir;

/* to bit-vector */
$pri(Bitvec) p_frame;

/* to Heap descriptor start, not the heap start */
$pri(Heap) kheap;

$pri(List) klist;

static void switch_page_dir(PDE *);
static PTE *get_page(PDE *, uint32_t, int, int, int);

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  init_paging
 *  Description:  init PDE & PTE then switch paging on
 * =====================================================================================
 */
void __page_init()
{
        uint32_t mem = __get_pmem_size;		/* in kb */
        uint32_t nframe = mem >> 2;             /* need frames */
        uint32_t npde = PDE_IDX(nframe);                     /* need PDEs */
        p_frame = (PTR) gnew(Bitvec, nframe);           /* points to the bit-vector start */

	/*-----------------------------------------------------------------------------
	 *  fill bit-vector with 0
	 *  U32_NEED == sizeof(bit-vector)
	 *-----------------------------------------------------------------------------*/
        memset($do(p_frame, getter_bitvec), 0, U32_NEED(nframe));

	/*-----------------------------------------------------------------------------
	 *  allocate all PDE
	 *
	 *  a PDE, 4096 bytes
	 *  must be 4k aligned
	 *-----------------------------------------------------------------------------*/
	ker_pdir = (PDE *) kmalloc_align(4096, 1);
	memset(ker_pdir, 0, 4096);
	cur_pdir = ker_pdir;

        for (uint32_t pa = 0; pa < mem; pa += 0x1000) {
		get_page(ker_pdir, pa, 1, 1, 1);
	}
	for (uint32_t pa = KHEAP_START; pa < KHEAP_START + KHEAP_LEN; pa += 0x1000) {
		get_page(ker_pdir, pa, 1, 0, 0);
	}

	klist = (PTR) gnew(List);
    	kheap = (PTR) gnew(Heap, KHEAP_START, KHEAP_START + KHEAP_LEN, KHEAP_MAX, 0, 0);
	switch_page_dir(ker_pdir);                      /* ker_pdir -> CR3 */
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  switch_page_dir
 *  Description:  1. idx -> CR3
 *  		  2. CR0 PG
 * =====================================================================================
 */
static void switch_page_dir(PDE * dir)
{
	/*-----------------------------------------------------------------------------
	 *  global var cur_pdir, resign CR3 & CR0  
	 *-----------------------------------------------------------------------------*/
	cur_pdir = dir;
	__asm__ __volatile__("mov	%0,	%%cr3 \n\t"
			     "mov	%%cr0,	%0 \n\t"
			     "orl	$0x80000000, %0 \n\t"
			     "mov	%0,	%%cr0 \n\t"::"r"(dir));
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  get_page
 *  Description:  PA - frame-idx - pde-idx - pte
 * =====================================================================================
 */
static PTE *get_page(PDE * dir, uint32_t pa, 
		     int make, int is_wt, int is_usr)
{
	assert(dir);
	uint32_t fr = FRAME_IDX(pa);
	uint32_t pde = PDE_IDX(fr);                          /* pde = 1024 pte = 1024 fr */
	uint32_t offset = PTE_OFF(fr);
	PTE *pg = (PTE *) ((dir[pde].frame << 12) + (offset << 2)); /* no. * 4 bytes */

	/*-----------------------------------------------------------------------------
	 *  all pde have been allocated already, see in "init_paging()"
	 *  
	 *  pde does	exist --> init pte in the pde
	 *  pde doesn't exist --> yes, make --> alloc pte --> init pte in the pde
	 *-----------------------------------------------------------------------------*/
	if (*((uint32_t *) dir + pde)) {                     /* the target pde exists? */
		if (*(uint32_t *) pg) {                      /* if no, init the pte */
			return pg;
		}
	} else if (make) {                              /* not, so make it */
		/* allocate 1024 ptes for 1 pde, meanwhile init the pde */
		dir[pde].frame = kmalloc_align(4096, 1) >> 12;
		dir[pde].present = dir[pde].usr = dir[pde].rw = 1;
	} else {
		return NULL;                            /* no found no make */
	}

	/*-----------------------------------------------------------------------------
	 *  init pte
	 *-----------------------------------------------------------------------------*/
#define	 	PAGE_OFFSET		0xb8000
	if (pa >= 0xc0001000) {
		fr = fr - PAGE_OFFSET;
		pg->frame = fr;
	} else {
		pg->frame = fr;
	}
	pg->present = 1;
	pg->rw = is_wt;
	pg->usr = is_usr;

	/*-----------------------------------------------------------------------------
	 *  init frame bit vector
	 *-----------------------------------------------------------------------------*/
	$do(p_frame, set, $arg(fr));
	return pg;
}
