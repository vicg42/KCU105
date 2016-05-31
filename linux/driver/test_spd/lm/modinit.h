/**
 *	file:		modinit.h
 *	date:		28.08.2007/14.10.2011
 *	authors:	Topolsky
 *	format:		tab4
 *	descript.:	Modular module (driver) loading/unloading helper. External
 *				definition of <module_subsystem_arr> array is required. Each
 *				<init> member of <module_subsystem_arr> array items will be
 *				executed during module loading, each non-zero <release> member
 *				will be executed during module unloading (in reverse order). If
 *				one of <init> calls fails with negative (error code) result
 *				loading interrupted and unloading started (only successfully
 *				initialized subsystems will be released).
 */

#ifndef __LM_MODINIT_H
#define __LM_MODINIT_H

/** Shared type: subsystem description consist of callbacks and name. <init> and
  * <name> members can't be zero */

struct module_subsystem_t
{	int (* init)(void);
	void (* release)(void);
	const char * name;
};

/** External requirements */

extern const struct module_subsystem_t module_subsystem_arr[];

#endif // __LM_MODINIT_H
