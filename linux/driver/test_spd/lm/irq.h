/**
 *	file:		irq.h
 *	date:		18.09.2007
 *	authors:	Topolsky
 *	format:		tab4
 *	descript.:	Modular module (driver) interrupt handler. External definition
 *				of <irq_number> variable and <irq_subsystem_arr> array is
 *				required. Note that <irq_number> variable must be initialized
 *				before <irq_init> execution. All handlers of registered
 *				subsystems (array items) will be executed during interrupt
 *				processing, their return codes will be used to determine the
 *				main interrupt handler result reported to O/S (IRQ_HANDLED or
 *				IRQ_NONE), subsystm handler must clear own interrupt request.
 */

#ifndef __LM_IRQ_H
#define __LM_IRQ_H

#include <linux/interrupt.h>

/** <modinit> subsystem entries */

int irq_init(void);
void irq_release(void);

/** Shared type: subsystem description consist of callback and name. Both
  * members can't be zero */

struct irq_subsystem_t
{	irqreturn_t (* handler)(void);
	const char * name;
};

/** External requirements */

extern unsigned int irq_number;
extern const struct irq_subsystem_t irq_subsystem_arr[];

#endif // __LM_IRQ_H
