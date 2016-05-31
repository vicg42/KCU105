/*
 *	file:		irq.c
 *	date:		18.09.2007
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "irq.h"

#include <asm/atomic.h>
#include <asm/signal.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/version.h>

#include "config.h"
#include "retcode.h"
#include "hwi.h"
#include "module.h"

// local types -----------------------------------------------------------------

typedef struct
{
	/** Subsystem "ready" flag: all "public" calls must take into it's value
	  * (if no <LM_NDEBUG> defined) */

	atomic_t		init;

	/** Number of subsystem (constant after <iosched_init> completed) */

	size_t			nsubsystems;

	/** Statistics counters. <irq_arr> has <nsubsystems> items */

	struct
	{	atomic_t		irq, unknown_irq;
		atomic_t *		irq_arr;
	}				s;

} local_data_t;

// local functions -------------------------------------------------------------

static int cleanup(int, int);

static irqreturn_t irq_handler
(	int
,	void *
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19)
,	struct pt_regs *
#endif
);

// local constants -------------------------------------------------------------

#define LM_SUBSYSTEM_NAME "irq"

// local variables -------------------------------------------------------------

static local_data_t l;

// implementation --------------------------------------------------------------

int irq_init(void)
{
	#ifndef LM_NDEBUG
	if (atomic_read(&l.init))
		return -EPERM;
	#endif

	int ccode = 0; // cleanup code

	// check external subsystems array (calculate number of subsystems)

	l.nsubsystems = 0;

	while (irq_subsystem_arr[l.nsubsystems].name)
	{
		if (!irq_subsystem_arr[l.nsubsystems].handler)
		{
			printk
				(	KERN_ERR "%s: Invalid subsystem (%s) definition\n"
				,	LM_NAME, irq_subsystem_arr[l.nsubsystems].name
				);

			return cleanup(ccode, -EINVAL);
		}

		++l.nsubsystems;
	}

	if (!l.nsubsystems)
	{
		printk(KERN_ERR "%s: No subsystems found\n", LM_NAME);
		return cleanup(ccode, -EINVAL);
	}

	// allocate statistics array

	if (!(l.s.irq_arr = kmalloc(sizeof(atomic_t) * l.nsubsystems, GFP_KERNEL)))
		return cleanup(ccode, -ENOMEM);

	ccode = 1;

	// reset statistics counters

	atomic_set(&l.s.irq, 0);
	atomic_set(&l.s.unknown_irq, 0);

	size_t i;
	for (i = 0; i < l.nsubsystems; ++i)
		atomic_set(&l.s.irq_arr[i], 0);

	// request irq line

	const int retcode = request_irq
		(	irq_number
		,	irq_handler
		#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,21)
		,	IRQF_SHARED
		#else
		,	SA_SHIRQ
		#endif
		,	LM_NAME
		,	(void *)THIS_MODULE
		);

	if (is_error(retcode))
		return cleanup(ccode, retcode);

	ccode = 2;

	// finish

	atomic_set(&l.init, 1);

	return 0;
}

void irq_release(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return print_error(-EPERM, __FUNCTION__);
	#endif

	#ifndef LM_NO_EXIT_INFO
	{
		printk
			(	KERN_INFO "%s/%s: Exit statistics: interrupts - %d (unknown - %d)\n"
			,	LM_NAME, LM_SUBSYSTEM_NAME, atomic_read(&l.s.irq), atomic_read(&l.s.unknown_irq)
			);

		if (atomic_read(&l.s.irq) != atomic_read(&l.s.unknown_irq))
		{
			printk
				(	KERN_INFO "%s/%s: Exit statistics (interrupts in detail):"
				,	LM_NAME, LM_SUBSYSTEM_NAME
				);
			size_t i;
			for (i = 0; i < l.nsubsystems; ++i)
			{
				if (i) printk(";");
				printk(" %s - %d", irq_subsystem_arr[i].name, atomic_read(&l.s.irq_arr[i]));
			}
			printk("\n");
		}
	}
	#endif

	cleanup(-1, 0);
}

static int cleanup(int ccode, int retcode)
{
	switch (ccode)
	{
	case -1:;
		// unbreaked
	case 2:
		free_irq(irq_number, (void *)THIS_MODULE);
		// unbreaked
	case 1:
		kfree(l.s.irq_arr);
		// unbreaked
	default:
		atomic_set(&l.init, 0);
		// unbreaked
	}

	return retcode;
}

static irqreturn_t irq_handler
(	int _1
,	void * _2
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19)
,	struct pt_regs * _3
#endif
)
{
	atomic_inc(&l.s.irq);

	size_t completes = 0, i;

	for (i = 0; i < l.nsubsystems; ++i)
	{
		if ((irq_subsystem_arr[i].handler)() == IRQ_HANDLED)
		{
			++completes;
			atomic_inc(&l.s.irq_arr[i]);
		}
	}

	if (!completes)
	{
		atomic_inc(&l.s.unknown_irq);
		return IRQ_NONE;
	}
	else{
	reg_locked_set(m.pci.reg.irq_ctrl, LSD_RICB_IRQCLR);
	}

	return IRQ_HANDLED;
}
