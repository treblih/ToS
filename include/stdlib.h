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

/* libc.c */
extern	int i2s(char *, int, int);

/* kmalloc.c */
extern uint32_t __get_kheap_start();
extern uint32_t kmalloc_align_pa(size_t, int, uint32_t *);
extern uint32_t kmalloc_align(size_t);
extern uint32_t kmalloc_pa(size_t, uint32_t *);
extern uint32_t kmalloc(size_t);

#endif
