/*
 * =====================================================================================
 *
 *       Filename:  thread_info.h
 *
 *    Description:  
 *
 *        Created:  23.09.10 23:58
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef THREAD_INFO_H
#define THREAD_INFO_H

#include <stdint.h>
#include <page.h>	/* PAGE_SIZE */

struct thread_info {
	struct task_struct	*task;		/* main task structure */
	struct exec_domain	*exec_domain;	/* execution domain */
	unsigned long		flags;		/* low level flags */
	int			preempt_count;	/* 0 => preemptable, <0 => BUG */
	uint32_t		tls;		/* TLS for this thread */

	mm_segment_t		addr_limit;	/* thread address space:
					 	   0-0xBFFFFFFF for user-thead
						   0-0xFFFFFFFF for kernel-thread
						*/
	struct restart_block    restart_block;
	uint8_t			supervisor_stack[0];
};

#define THREAD_SIZE (2 * PAGE_SIZE)

/* thread information allocation */
#define alloc_thread_info(tsk)	((struct thread_info *) __get_free_pages(GFP_KERNEL,1))
#define free_thread_info(ti)	free_pages((unsigned long) (ti), 1)


#endif /* end of include guard: THREAD_INFO_H */
