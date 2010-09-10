/*
 * =====================================================================================
 *
 *       Filename:  stdarg.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  10.04.10 23:00
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Yang Zhang (), imyeyeslove@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef		STDARG_H
#define		STDARG_H

#define		va_list			char *
#define		va_start(ap, arg)	(ap = (va_list)&arg + sizeof(arg))
#define		va_arg(ap ,t)		(*(t *) ((ap += sizeof(t)) - sizeof(t)))
#define		va_end(ap)		(ap = (va_list)0)

#endif
