/*
 * =====================================================================================
 *
 *       Filename:  string.h
 *
 *    Description:  
 *
 *        Created:  10.09.10 06:33
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef		STRING_H
#define		STRING_H

#include <stdint.h>

/* libs.s */
extern size_t strlen(const char *);
extern void *memset(void *, int, size_t);
extern void *memcpy(void * restrict , const void * restrict , size_t);

#endif
