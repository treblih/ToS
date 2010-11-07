/*
 * =====================================================================================
 *
 *       Filename:  stdint.h
 *
 *    Description:  
 *
 *        Created:  15.09.10 04:16
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef STDINT_H
#define STDINT_H

/* signed */
typedef signed char		int8_t;
typedef short int		int16_t;
typedef int			int32_t;

/* unsigned.  */
typedef unsigned char		uint8_t;
typedef unsigned char		u8;
typedef unsigned short int	uint16_t;
typedef unsigned short int	u16;
typedef unsigned int		uint32_t;
typedef unsigned int		u32;

typedef unsigned int 		size_t;
typedef int 			ssize_t;

#endif /* end of include guard: STDINT_H */
