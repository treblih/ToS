/*
 * =====================================================================================
 *
 *       Filename:  bitvec.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  10.03.10 21:48
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Yang Zhang (), imyeyeslove@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef		BITVEC_H
#define		BITVEC_H

/*-----------------------------------------------------------------------------
 *  NOTICE:
 *  unit is u32, not byte
 *-----------------------------------------------------------------------------*/
#define		BYTES_NEED(n)		(((n) - 1 + 8) >> 3) 
#define		BIT_INDEX(n)		((n) >> 5)
#define		BIT_OFFSET(n)		((n) % 32)
#define		BIT_SET			1
#define		BIT_UNSET		0

typedef struct {
	int cnt;		/* bits cnt, not bytes */
	unsigned *addr;
} bitvec_t;

extern bitvec_t *get_bitvec_pmem(void);
extern bitvec_t *bitvec_create(int);
extern bitvec_t *bitvec_init(bitvec_t *, ssize_t);
extern void bitvec_free(bitvec_t *);
extern ssize_t bitvec_find_first(bitvec_t *, int);
extern void bitvec_ctrl(bitvec_t *, ssize_t, int);

#endif
