/*
 * =====================================================================================
 *
 *       Filename:  desc.h
 *
 *    Description:  
 *
 *        Created:  25.09.10 12:25
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef DESC_H
#define DESC_H

#include <stdint.h>
#include <bug.h>

#define GDT_ENTRY_DOUBLEFAULT_TSS	0x1f

#define STACKFAULT_STACK 0
#define DOUBLEFAULT_STACK 1

#define GDT_32	0x4000
#define GDT_4K	0x8000
#define GDT_RW	0x92
#define GDT_X	0x98
#define GDT_RX	0x9a

#define DPL0	0
#define DPL1	0x20
#define DPL2	0x40
#define DPL3	0x60

#define __KERNEL_CS	0x60
#define __KERNEL_DS	0x68
#define	__USER_CS	0x73
#define	__USER_DS	0x7b

/* User mode is privilege level 3 */
#define USER_RPL	0x3

/* 0x500 - 0xeff */
#define idt_dst	0x500
#define gdt_dst	0xd00


.macro gdt base limit attr
	.word	\limit & 0xffff
	.word	\base & 0xffff
	.byte 	(\base >> 16) & 0xff
	.word	((\limit >> 8) & 0x0f00) | (\attr & 0xf0ff)
	.byte	(\base >> 24) & 0xff
.endm

.macro idt slc offset attr
	.word	\offset & 0xffff
	.word	\slc
	.byte	0
	.byte	\attr
	.word	(\offset >> 16) & 0xffff
.endm

/* 8 byte segment descriptor */
struct desc_struct {
	union {
		struct {
			unsigned a;
			unsigned b;
		};
		struct {
			u16 limit0;
			u16 base0;
			unsigned base1: 8, type: 4, s: 1, dpl: 2, p: 1;
			unsigned limit: 4, avl: 1, l: 1, d: 1, g: 1, base2: 8;
		};
	};
} __attribute__((packed));

enum {
	GATE_TASK = 0x5,
	GATE_CALL = 0xC,
	GATE_INTERRUPT = 0xE,
	GATE_TRAP
};

static inline void _set_gate(int gate, unsigned type, void *addr,
			     unsigned dpl, unsigned ist, unsigned seg)
{
	gate_desc s;
	pack_gate(&s, type, (unsigned long)addr, dpl, ist, seg);
	/*
	 * does not need to be atomic because it is only done once at
	 * setup time
	 */
	write_idt_entry(idt_table, gate, &s);
}

static inline void set_intr_gate(unsigned int n, void *addr)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
}

extern int first_system_vector;
/* used_vectors is BITMAP for irq is not managed by percpu vector_irq */
extern unsigned long used_vectors[];

static inline void alloc_system_vector(int vector)
{
	if (!test_bit(vector, used_vectors)) {
		set_bit(vector, used_vectors);
		if (first_system_vector > vector)
			first_system_vector = vector;
	} else
		BUG();
}

static inline void alloc_intr_gate(unsigned int n, void *addr)
{
	alloc_system_vector(n);
	set_intr_gate(n, addr);
}

/*
 * This routine sets up an interrupt gate at directory privilege level 3.
 */
static inline void set_system_intr_gate(unsigned int n, void *addr)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_INTERRUPT, addr, 0x3, 0, __KERNEL_CS);
}

static inline void set_system_trap_gate(unsigned int n, void *addr)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_TRAP, addr, 0x3, 0, __KERNEL_CS);
}

static inline void set_trap_gate(unsigned int n, void *addr)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_TRAP, addr, 0, 0, __KERNEL_CS);
}

static inline void set_task_gate(unsigned int n, unsigned int gdt_entry)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_TASK, (void *)0, 0, 0, (gdt_entry<<3));
}

static inline void set_intr_gate_ist(int n, void *addr, unsigned ist)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_INTERRUPT, addr, 0, ist, __KERNEL_CS);
}

static inline void set_system_intr_gate_ist(int n, void *addr, unsigned ist)
{
	BUG_ON((unsigned)n > 0xFF);
	_set_gate(n, GATE_INTERRUPT, addr, 0x3, ist, __KERNEL_CS);
}

#endif /* end of include guard: DESC_H */
