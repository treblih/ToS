/*
 * =====================================================================================
 *
 *       Filename:  hash.h
 *
 *    Description:  
 *
 *        Created:  24.09.10 14:05
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef HASH_H
#define HASH_H

/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
#define GOLDEN_RATIO_PRIME_32	0x9e370001UL
#define GOLDEN_RATIO_PRIME	GOLDEN_RATIO_PRIME_32
#define hash_long((val), (bits))	hash_32((val), (bits))

static inline u32 hash_32(u32 val, unsigned int bits)
{
	/* On some cpus multiply is faster, on others gcc will do shifts */
	u32 hash = val * GOLDEN_RATIO_PRIME_32;

	/* High bits are more random, so use them. */
	return hash >> (32 - bits);
}

static inline unsigned long hash_ptr(void *ptr, unsigned int bits)
{
	return hash_long((unsigned long)ptr, bits);
}

switch_to
PAGE_OFFSET
init_task
start_kernel

#endif /* end of include guard: HASH_H */
