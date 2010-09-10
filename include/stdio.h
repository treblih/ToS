/*
 * =====================================================================================
 *
 *       Filename:  stdio.h
 *
 *    Description:  
 *
 *        Created:  10.09.10 05:06
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef		STDIO_H
#define		STDIO_H

#include	<stdarg.h>

extern	void puts(const char *);
extern	int printf(const char *, ...);
extern	int vsprintf(char*, const char*, va_list);

#define		print(fmt, ...)		printf(fmt, __VA_ARGS__)

#endif
