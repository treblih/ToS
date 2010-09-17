/*
 * =====================================================================================
 *
 *       Filename:  heap.h
 *
 *    Description:  
 *
 *        Created:  15.09.10 18:46
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef HEAP_H
#define HEAP_H

#define 	HEAP_MAGIC        	0x19881014
#define	 	HEADER_SIZE		sizeof(struct header_t)
#define	 	FOOTER_SIZE		sizeof(struct footer_t)
#define		HEAP_SIZE		HEADER_SIZE + FOOTER_SIZE

#define		HEAP_RW			0
#define		HEAP_RO			1
#define		HEAP_SPR_USR		0
#define		HEAP_USR		1

typedef struct header_t {
	u32 magic;   /* magic number, used for error checking and identification */
	BOOL free;   /* 1 if this is a hole. 0 if this is a block */
	size_t size;    /* size of the block, including the end footer */
} * header_t;

typedef struct footer_t {
	u32 magic;     /* magic number, same as in header_t */
	header_t * header; /* pointer to the block header */
} * footer_t;

typedef struct heap_t {
	bintree_t tree;
	PTR start;
	PTR end;
	PTR max;
	int spr;	/* super user */
	int ro;		/* read only */
} * heap_t;

extern heap_t * heap_create(void);
extern void * heap_init(heat_t *heap, bintree_t *, PTR, PTR, PTR, int, int);
extern PTR heap_get_end(heat_t *);

#endif /* end of include guard: HEAP_H */
