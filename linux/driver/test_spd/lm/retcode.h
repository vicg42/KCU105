/*
 *	file:		retcode.h
 *	date:		14.10.2011
 *	authors:	Topolsky
 *	format:		tab4
 *	descript.:	Return code (retcode) processing helpers. Return code should
 *				satisfy the following conditions: negative value indicates an
 *				error (standard error code); zero indicates successful
 *				execution; positive value - other (not error) result.
 */

#ifndef __LM_RETCODE_H
#define __LM_RETCODE_H

/** Check <retcode>. The result can be used in boolean expressions */

int is_error(int retcode);
int is_ok(int retcode);

/** Print unified message if error <retcode>. <func_name> is a name of the
  * function result of which is processed */

void print_error(int retcode, const char * func_name);
void print_error_i(int retcode, const char * func_name, int func_index);

#endif // __LM_RETCODE_H
