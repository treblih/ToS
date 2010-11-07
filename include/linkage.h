/*
 * =====================================================================================
 *
 *       Filename:  linkage.h
 *
 *    Description:  
 *
 *        Created:  25.09.10 15:36
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef LINKAGE_H
#define LINKAGE_H

/* Simple shorthand for a section definition */
# define __section(S) __attribute__ ((__section__(#S)))

#define __init		__section(.init.text)
#define __initdata	__section(.init.data)
#define __initconst	__section(.init.rodata)
#define __exitdata	__section(.exit.data)
#define __exit_call	__section(.exitcall.exit)

#define ENTRY(name) \
  .globl name; \
  ALIGN; \
  name:

#define END(name) \
  .size name, .-name

#endif /* end of include guard: LINKAGE_H */
