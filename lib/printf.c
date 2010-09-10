/*
 * =====================================================================================
 *
 *       Filename:  printf.c
 *
 *    Description:  
 *
 *        Created:  10.09.10
 *       Revision:  
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include	<stdio.h>
#include	<stdlib.h>

#define		DEC	10
#define		HEX	16

int printf(const char* fmt, ...)
{
	char buf[256] = { 0 };
	va_list ap;
	va_start(ap, fmt);
	int buf_len = vsprintf(buf, fmt, ap);
	//disp_int(buf_len);

	//write(buf, buf_len);

	if (buf_len) {
		puts(buf);
	}
	va_end(ap);
	return buf_len;
}

int vsprintf(char* buf, const char* fmt, va_list argv)
{
	char    fill;
	char    count  = 0;
	char    align  = 0;
	char*   p      = buf;
	va_list string = argv;

	/* in the WHILE below, we must use p instead of buf */
	while (*fmt) {
		if (*fmt != '%') {
			*p++ = *fmt++;
			continue;
		}
		/*-----------------------------------------------------------------------------
		 *                      \n \t \b... 
		 * \ and the char followed are one, so no need to case '\'
		 *-----------------------------------------------------------------------------*/
		++fmt;
		if (*fmt == '%') {
			*p++ = *fmt++;
			continue;
		}
		else if (*fmt == '0') {
			fill = '0';
			fmt++;
		}
		else {
			fill = ' ';
		}

		while (*fmt >= '0' && *fmt <= '9') {
			align *= 10;
			align += (*fmt - '0');
			fmt++;
		}

		switch (*fmt) {
			case 'x':
				count = i2s(p, *(int*)argv, HEX);
				p += count;
				__asm__ __volatile__("jmp 1f");
			case 'd':
				count = i2s(p, *(int*)argv, DEC);
				p += count;
				__asm__ __volatile__("1:");
				if (align) {
					if (align < count)
						return -1;
					char i = count;
					char j = align - count;
					for ( ; i; i--) {
						p--;
						*(p + j) = *p;
					}
					for ( ; j; j--) {
						*p++ = fill;
					}
					p += count;
					*p = 0;
					align = 0;
				}
				break;
			case 'c':
				*p++ = *argv;
				break;
			case 's':
				string = (char*)*(int*)argv;
				while (*string) {
					*p++ = *string++;
				}
				break;
			default:
				break;
		}
		fmt++;
		argv += 4;
	}
	return (p - buf);
}
