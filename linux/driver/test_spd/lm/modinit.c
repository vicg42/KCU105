/*
 *	file:		modinit.c
 *	date:		28.08.2007/14.10.2011
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "modinit.h"

#include <linux/module.h>

#include "config.h"
#include "retcode.h"

// local functions -------------------------------------------------------------

static int __init module_start(void);
static void cleanup(void);
static void __exit module_stop(void);

// kernel routine (bind functions) ---------------------------------------------

module_init(module_start);
module_exit(module_stop);

// local variables -------------------------------------------------------------

static int nsubsystems = 0; // number of successfully initialized systems

// implementation --------------------------------------------------------------

static int __init module_start(void)
{
	#ifndef LM_NDEBUG
	if (nsubsystems)
		return -EPERM;
	#endif

	int i = 0;

	// check subsystem list

	while (module_subsystem_arr[i].name)
	{
		if (!module_subsystem_arr[i].init)
		{
			printk
				(	KERN_ERR "%s: Invalid subsystem (%s) definition\n"
				,	LM_NAME, module_subsystem_arr[i].name
				);

			return -EINVAL;
		}

		++i;
	}

	if (!i)
	{
		printk(KERN_ERR "%s: No subsystems found\n", LM_NAME);
		return -EINVAL;
	}

	// init subsystems

	int retcode;

	while (module_subsystem_arr[nsubsystems].name)
	{
		if (is_error(retcode = module_subsystem_arr[nsubsystems].init()))
		{
			printk
				(	KERN_ERR "%s: Subsystem loading (%d:%s) error: %d\n"
				,	LM_NAME, nsubsystems, module_subsystem_arr[nsubsystems].name, retcode
				);

			cleanup();

			return retcode;
		}

		++nsubsystems;
	}

	return 0;
}

static void cleanup(void)
{
	if (!nsubsystems)
		return; // silent

	// release subsystems in reverse order

	while (--nsubsystems >= 0)
		if (module_subsystem_arr[nsubsystems].release)
			module_subsystem_arr[nsubsystems].release();

	nsubsystems = 0;
}

static void __exit module_stop(void)
{
	cleanup();
}
