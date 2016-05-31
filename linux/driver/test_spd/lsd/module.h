/*
 *	file:		module.h
 *	date:		18.05.2010
 *	authors:	Topolsky
 *	company:	Linkos
 *	format:		tab4
 *	descript.:	Common module types, functions, variables & defines
 */

#ifndef __LSD_MODULE_H
#define __LSD_MODULE_H

#include <linux/types.h>
#include <linux/version.h>

#include "config.h"

#ifndef LSD_ENABLE_MEMIO_BAR
#	if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18)
	typedef unsigned long reg_addr_t;
#	else
	typedef resource_size_t reg_addr_t;
#	endif
#else
typedef void * reg_addr_t;
#endif

typedef struct
{	struct
	{	void *			mmem;
		struct
		{	reg_addr_t		fwid;
			reg_addr_t		ctrl;
			struct
			{	reg_addr_t		addr, size;
			}				dma;
			struct
			{	reg_addr_t		ctrl, status, data;
			}				dev;
			reg_addr_t		irq_ctrl;
			struct
			{	reg_addr_t		ctrl, addr;
			}				mem;
			struct
			{	reg_addr_t		timestamp, nlost_frames;
			}				fg;
			reg_addr_t		pcie_ctrl;
			reg_addr_t		timestamp;
			reg_addr_t		fiber_data_head;
			struct
			{	reg_addr_t		func, opt;
			}				hw;
			struct
			{	reg_addr_t		ctrl, data;
			}				cfg;
			#ifdef LSD_ENABLE_HWDBG
			reg_addr_t		x1C, x1D, x1E;
			#endif
		}				reg;
	}				pci;
	u32				fwid;
} module_data_t;

extern module_data_t m;

/** Registers access functions */

void reg_lock(void);
u32 reg_get(reg_addr_t);
void reg_set(reg_addr_t, u32);
void reg_unlock(void);

u32 reg_locked_get(reg_addr_t);
void reg_locked_set(reg_addr_t, u32);

/** Masked value helpers */

u32 mask_value(u32 value, u32 mask);
u32 unmask_value(u32 masked_value, u32 mask);

#endif // __LSD_MODULE_H
