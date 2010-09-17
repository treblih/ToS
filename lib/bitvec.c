/*
 * =====================================================================================
 *
 *       Filename:  bitvec.c
 *
 *    Description:  all args are bits, not bytes not u32
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
static bitvec_t bit_pmem;

bitvec_t *get_bitvec_pmem()
{
	return &bit_pmem;
}

bitvec_t *bitvec_create(int is_pmem)
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
bitvec_t *bitvec_init(bitvec_t *bitvec, ssize_t bits)
{
	/* init the one for pmem */
	bitvec->cnt = bits;
	bitvec->addr = kmalloc_align(BYTES_NEED(bits));
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
	unsigned char *bit = bitvec->addr;
	int len = BYTES_NEED(bitvec->cnt);
	for (int i = 0; i < len; ++i) {
		/* 8 bits are all 0, next loop */
		if ((!(test = bit[i])) && set) {
			continue;
		}
		for (int j = 0; j < 8; ++j) {
			/* set   -> test % 2 == 1 */
			/* unset -> test % 2 == 0 */
			if (test % 2 == set) {
				return (i << 3) + j;	/* the idx */
			}
			/* feeling in haskell... */
			test >>= 1;
		}
	}
	/* that's why use ssize_t instead of size_t */
	return -1;
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  bitvec_ctrl
 *  Description:  set/unset a range of bits
 *
 *  		  NOTICE:
 *  		  parameter idx is 0 ~ (end - 1), not 1 ~ end
 * =====================================================================================
 */
void *bitvec_ctrl(bitvec_t *bitvec, ssize_t idx, ssize_t range, int set)
{
	unsigned char *addr = bitvec->addr + BYTES_IDX(idx);
	int i;
	int offset = BIT_OFFSET(idx);
	int complement = 8 - offset;
	int bytes = (range - complement) >> 3;
	int range_offset = (range - complement) % 8;

	if (!range) {
		return NULL;
	}

	if (set) {
		/* 3 steps */
		/* 1st, deal with all bits in the first bytes */
		if (complement >= range) {
			for (i = 0; i < range; ++i) {
				*addr |= 1 << (offset + i);
			}
			return NULL;
		} else {
			for (i = 0; i < complement; ++i) {
				*addr |= 1 << (offset + i);
			}
		}
		addr += 1;
		/* 2nd, deal with every 8 bits as bytes */
		for (i = 0; i < bytes; ++i) {
			*addr++ = 0xff;
		}
		/* 3rd, deal with following bits */
		for (i = 0; i < range_offset; ++i) {
			*addr |= 1 << i;
		}
	} else {
		if (complement >= range) {
			for (i = 0; i < range; ++i) {
				*addr &= ~(1 << (offset + i));
			}
			return NULL;
		} else {
			for (i = 0; i < complement; ++i) {
				*addr &= ~(1 << (offset + i));
			}
		}
		addr += 1;
		for (i = 0; i < bytes; ++i) {
			*addr++ = 0;
		}
		for (i = 0; i < range_offset; ++i) {
			*addr &= ~(1 << i);
		}
	}
	return NULL;
}
