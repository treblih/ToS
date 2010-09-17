/*
 * =====================================================================================
 *
 *       Filename:  stdlib.h
 *
 *    Description:  
 *
 *        Created:  10.09.10 06:57
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef		STDLIB_H
#define		STDLIB_H

#include	<stdint.h>

#define		NULL	(void *)0

/* libs.s */

/* libc.c */
extern	int i2s(char *, int, int);

/* kmalloc.c */
extern void *__get_kheap_start();
extern void *__set_heap_addr(unsigned char *);
extern void *kmalloc_align_pa(size_t, int, unsigned char **);
extern void *kmalloc_align(size_t);
extern void *kmalloc_pa(size_t, unsigned char **);
extern void *kmalloc(size_t);

#endif
