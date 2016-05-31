/*
 *	file:		retcode.c
 *	date:		14.10.2011
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "retcode.h"

#include <linux/kernel.h>

#include "config.h"

int is_error(int retcode)
{
	return retcode < 0 ? 1 : 0;
}

int is_ok(int retcode)
{
	return retcode >= 0 ? 1 : 0;
}

void print_error(int retcode, const char * func_name)
{
	#ifndef LM_NO_PRINT_ERROR
	if (is_error(retcode))
		printk(KERN_DEBUG "%s: %s retcode is %d\n", LM_NAME, func_name, retcode);
	#endif
}

void print_error_i(int retcode, const char * func_name, int func_index)
{
	#ifndef LM_NO_PRINT_ERROR
	if (is_error(retcode))
		printk(KERN_DEBUG "%s: %s[%d] retcode is %d\n", LM_NAME, func_name, func_index, retcode);
	#endif
}
