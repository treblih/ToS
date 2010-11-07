/*
 * =====================================================================================
 *
 *       Filename:  irq_vectors.h
 *
 *    Description:  
 *
 *        Created:  25.09.10 11:49
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef IRQ_VECTORS_H
#define IRQ_VECTORS_H

/*
 * IDT vectors usable for external interrupt sources start at 0x20.
 * (0x80 is the syscall vector, 0x30-0x3f are for ISA)
 */
#define FIRST_EXTERNAL_VECTOR		0x20
#define SYSCALL_VECTOR			0x80


#endif /* end of include guard: IRQ_VECTORS_H */
