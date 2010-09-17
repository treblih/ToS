/*
 * =====================================================================================
 *
 *       Filename:  bitvec.c
 *
 *    Description:  regard 32 bits(unsigned int) as a unit
 *
 * 		    the reason why use ssize_t instead of size_t
 * 		    see 
 * 		    bitvec_first_set() & bitvec_first_unset()
 *
 *        Version:  1.0
 *        Created:  10.03.10
 *       Revision:  
 *       Compiler:  GCC 4.4.3
 *
 *         Author:  Yang Zhang, imyeyeslove@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include <stdlib.h>
#include <stdint.h>
#include <bitvec.h>

/* persistent, for pmem */
static bitvec_t bit_pem;

bitvec_t *get_bitvec_pmem()
{
	return &bit_pmem;
}

bitvec_t *bitvec_create(is_pmem)
{
	if (is_pmem) {
		return &bit_pmem;
	}
	return kmalloc(sizeof(bitvec_t));
}
/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  bitvec_create
 *  Description:  num is bits count, not bytes
 * =====================================================================================
 */
bitvec_t *bitvec_init(bitvec_t *bitvec, ssize_t num)
{
	/* init the one for pmem */
	bitvec->cnt = num;
	bitvec->addr = kmalloc_align(BYTES_NEED(num));
	return bitvec;
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  bitvec_free
 *  Description:  free a pointer which points to the unsigned array
 * =====================================================================================
 */
void bitvec_free(bitvec_t *bitvec)
{
	/* FREE(bitvec); */
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  bitvec_first_set
 *  Description:  find the first set bit in the queue
 *
 *  		  NOTICE:
 *  		  return 0 ~ (end - 1), not 1 ~ end
 *  		  i.e. return the idx in the wanted array, not the NO.
 * =====================================================================================
 */
ssize_t bitvec_find_first(bitvec_t *bitvec, int set)
{
	unsigned char test;
	unsigned bit = bitvec->addr;
	int len = BYTES_NEED(bitvec->cnt);
	for (int i = 0; i < len; i++) {
		/* 8 bits are all 0, next loop */
		if (set && (!(test = bit[i]))) {
			continue;
		}
		for (int j = 0; j < 8; ++j) {
			/* test % 2 == 1 -> set */
			if (test % 2 == set) {
				return (i << 3) + j;	/* the idx */
			}
		}
	}
	/* that's why use ssize_t instead of size_t */
	return -1;
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  bitvec_ctrl
 *  Description:  set/unset a certain bit
 *
 *  		  NOTICE:
 *  		  parameter idx is 0 ~ (end - 1), not 1 ~ end
 *  		  i.e. the idx in the wanted array, not the NO.
 * =====================================================================================
 */
void bitvec_ctrl(bitvec_t *bitvec, ssize_t idx, int set)
{
	(bitvec->addr)[BIT_INDEX(idx)] = set ?
	(bitvec->addr)[BIT_INDEX(idx)] | (1 << BIT_OFFSET(idx)):
	(bitvec->addr)[BIT_INDEX(idx)] & (0 << BIT_OFFSET(idx));
}
