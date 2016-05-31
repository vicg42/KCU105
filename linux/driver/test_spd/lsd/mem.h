/*
 *	file:		mem.h
 *	date:		25.05.2010
 *	authors:	Topolsky
 *	company:	Linkos
 *	format:		tab4
 *	descript.:	"Memory" subsystem service interface
 */

#ifndef __LSD_MEM_H
#define __LSD_MEM_H

/** <modinit> subsystem entries */

int mem_init_(void); // so strange name to avoid kernel name collision
void mem_release(void);

/** <iosched> subsystem entries */

int mem_io_status(void);
void mem_approve_io(void);

#endif // __LSD_MEM_H
