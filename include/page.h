/*
 * =====================================================================================
 *
 *       Filename:  page.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  08.03.10 14:47
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Yang Zhang (), imyeyeslove@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */
#ifndef		PAGE_H
#define		PAGE_H

#include	"type.h"

#define		FRAME_IDX(pa)		((pa) >> 12)    /* PA / 4096 */
#define		PDE_IDX(fr)		((fr) >> 10)    /* nframe / 1024 */
#define		PTE_OFF(fr)		((fr) % 1024)   /* nframe % 1024 */

#define		PDE_SIZE		sizeof(PDE)
#define		PTE_SIZE		sizeof(PTE)

#define		PG_P		0x1
#define		PG_RW		0x2
#define		PG_USR		0x4


/*-----------------------------------------------------------------------------
 *  4 bytes
 *-----------------------------------------------------------------------------*/
typedef struct {
        u32 present:1;                       /* Page present in memory */
        u32 rw:1;                            /* Read-only if clear, readwrite if set */
        u32 usr:1;                          /* Supervisor level only if clear */
	u32 pwt:1;
	u32 pcd:1;
        u32 accessed:1;                      /* Has the page been accessed since last refresh? */
        u32 dirty:1;                         /* Has the page been written to since last refresh? */
	u32 pat:1;
	u32 global:1;
	u32 avail:3;
        u32 frame:20;                        /* Frame address (shifted right 12 bits) */
} PTE;

typedef struct {
        u32 present:1;                       /* Page present in memory */
        u32 rw:1;                            /* Read-only if clear, readwrite if set */
        u32 usr:1;                          /* Supervisor level only if clear */
	u32 pwt:1;
	u32 pcd:1;
        u32 accessed:1;                      /* Has the page been accessed since last refresh? */
	u32 reserved:1;                                         /* set to 0 */
	u32 ps:1;
	u32 global:1;
	u32 avail:3;
        u32 frame:20;                        /* Frame address (shifted right 12 bits) */
} PDE;

/*-----------------------------------------------------------------------------
 *  4k bytes
 *-----------------------------------------------------------------------------*/
//struct page_table {
//	page_t page[1024];
//};
//typedef struct page_table pte_t;

/* struct page_dir { */
	/*-----------------------------------------------------------------------------
	 *  array of pointers to page tables.
	 *-----------------------------------------------------------------------------*/
	/* pte_t *table_va[1024]; */

	/*-----------------------------------------------------------------------------
         *  array of pointers to the page tables above, but gives their *physical*
         *  location, for loading into the CR3 register.
	 *-----------------------------------------------------------------------------*/
	/* u32 table_pa[1024]; */

	/*-----------------------------------------------------------------------------
         *  the physical address of table_pa[1024]. 
	 *  this comes into play when we get our kernel heap allocated and the directory
         *  may be in a different location in virtual memory.
	 *-----------------------------------------------------------------------------*/
	/* u32 pa; */
/* }; */
/* typedef struct page_dir pde_t; */

extern void init_paging(void);
#endif
