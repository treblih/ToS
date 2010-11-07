/*
 * =====================================================================================
 *
 *       Filename:  traps.c
 *
 *    Description:  
 *
 *        Created:  24.09.10
 *       Revision:  
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include <desc.h>
#include <linkage.h>
#include <irq_vectors.h>

void __init trap_init(void)
{
	set_intr_gate(0, &divide_error);
	set_intr_gate_ist(2, &nmi, NMI_STACK);
	/* int4 can be called from all */
	set_system_intr_gate(4, &overflow);
	set_intr_gate(5, &bounds);
	set_intr_gate(6, &invalid_op);
	set_intr_gate(7, &device_not_available);
#ifdef CONFIG_X86_32
	set_task_gate(8, GDT_ENTRY_DOUBLEFAULT_TSS);
#else
	set_intr_gate_ist(8, &double_fault, DOUBLEFAULT_STACK);
#endif
	set_intr_gate(9, &coprocessor_segment_overrun);
	set_intr_gate(10, &invalid_TSS);
	set_intr_gate(11, &segment_not_present);
	set_intr_gate_ist(12, &stack_segment, STACKFAULT_STACK);
	set_intr_gate(13, &general_protection);
	set_intr_gate(15, &spurious_interrupt_bug);
	set_intr_gate(16, &coprocessor_error);
	set_intr_gate(17, &alignment_check);
	set_intr_gate(19, &simd_coprocessor_error);
	set_system_trap_gate(SYSCALL_VECTOR, &system_call);
}
