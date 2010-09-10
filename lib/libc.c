/*
 * =====================================================================================
 *
 *       Filename:  lib.c
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

#include	<string.h>
#include	<stdlib.h>

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  i2s
 *  Description:  convert an integer(dec/hex/oct/bin) to string
 *  		  return the string letters
 * =====================================================================================
 */
int i2s(char *str, int n, int div)
{
	int rem;
	char buf[50] = { 0 };
	char *p = buf;

	while (1) {
		rem = n % div;
		*p++ = (rem < 10) ? (rem + '0') : (rem - 10 + 'a');
		if (!(n /= div)) {
			break;
		}
	}
	int len = strlen(buf);
	for (int i = 0; i < len; ++i) {
		*str++ = *--p;
	}
	/* essential */
	*str = '\0';	
	return len;
}
