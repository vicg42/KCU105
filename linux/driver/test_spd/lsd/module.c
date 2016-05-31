/*
 *	file:		module.c
 *	date:		18.05.2010
 *	authors:	Topolsky
 *	format:		tab4
 *	descript.:	Common module functional
 */

#include "module.h"

#include <asm/io.h>
#include <linux/delay.h>
#include <linux/ioport.h>
#include <linux/jiffies.h>
#include <linux/module.h>
#include <linux/pci_regs.h>
#include <linux/smp.h>
#include <linux/spinlock.h>
#include <linux/version.h>

#include "cdev.h"
#include "config.h"
#include "dma.h"
#include "hwi.h"
#include "iosched.h"
#include "irq.h"
#include "mem.h"
#include "modinit.h"
#include "pci.h"
#include "retcode.h"

#ifndef LSD_MEM_ONLY
#	include "fg.h"
#	include "fiber.h"
#	include "frr.h"
#	include "timer.h"
#endif
#	ifdef LSD_ENABLE_HWDBG
#		include "hwdbg.h"
#	endif

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Little Smart Device");

static int attach(struct pci_dev *);
static void detach(struct pci_dev *);

// functions traces module loading/unloading

static int hello(void);
static void bye(void);

// board setup/check function

static int setup(void);
static void check(void);

// functions makes extra init/release actions (the last init stage)

static int module_loaded(void);
static void unloading_module(void);

// board bugfix

static void fix_freezing(void);

// <modinit> subsystem requirements

const struct module_subsystem_t module_subsystem_arr[] =
{	{ hello, bye, "trace" }
,	{ pci_init, pci_release, "pci" }
,	{ setup, 0, "setup" }
,	{ irq_init, irq_release, "irq" }
,	{ dma_init, dma_release, "dma" }
,	{ mem_init_, mem_release, "mem" }
#ifndef LSD_MEM_ONLY
,	{ fg_init, fg_release, "fg" }
,	{ frr_init, frr_release, "frr" }
,	{ timer_init, timer_release, "timer" }
,	{ fiber_init, fiber_release, "fiber" }
#endif
#	ifdef LSD_ENABLE_HWDBG
,	{ hwdbg_init, hwdbg_release, "hwdbg" }
#	endif
,	{ iosched_init, iosched_release, "iosched" }
,	{ module_loaded, unloading_module, "module" }
,	{ 0, }
};

// <pci> subsystem requirements

const pci_attach_func_t pci_attach = attach;
const pci_detach_func_t pci_detach = detach;

// <irq> subsystem requirements

unsigned int irq_number = ~0;

const struct irq_subsystem_t irq_subsystem_arr[] =
{	{ dma_irq, "dma" }
#ifndef LSD_MEM_ONLY
,	{ fg_irq, "fg" }
,	{ fiber_irq, "fiber" }
#endif
,	{ 0, }
};

// <iosched> subsystem requirements

const struct iosched_subsystem_t iosched_subsystem_arr[] =
{	{ check, 0, 0, 0, "check" }
#ifndef LSD_MEM_ONLY
,	{ fg_idle_io, fg_io_status, fg_approve_io, 0, "fg" }
,	{ fiber_idle_io, fiber_io_status, fiber_approve_io, 0, "fiber" }
#endif
,	{ 0, mem_io_status, mem_approve_io, 0, "mem" }
,	{ 0, }
};

const iosched_service_func_t iosched_begin = 0;
const iosched_service_func_t iosched_frozen = fix_freezing;
const iosched_service_func_t iosched_end = 0;

// module shared data ----------------------------------------------------------

module_data_t m;

// local types -----------------------------------------------------------------

#if defined(LSD_SMP_IO_NDELAY) && !defined(CONFIG_SMP)
#	undef LSD_SMP_IO_NDELAY
#endif

typedef struct
{	struct
	{	spinlock_t		lock;
		unsigned long	irq_flags;
		#ifdef LSD_SMP_IO_NDELAY
		int				cpu;
		#endif
	}				io;
} local_data_t;

// local variables -------------------------------------------------------------

static local_data_t l;

// implementation --------------------------------------------------------------

int attach(struct pci_dev * dev)
{
	// check usable bar(s)

	#ifndef LSD_ENABLE_MEMIO_BAR
	if	(	!(dev->resource[LSD_IO_BAR_INDEX].flags & IORESOURCE_IO)
		||	((dev->resource[LSD_IO_BAR_INDEX].end - dev->resource[LSD_IO_BAR_INDEX].start + 1) != LSD_IO_BAR_SIZE)
		)
	#else
	if	(	!(dev->resource[LSD_MEMIO_BAR_INDEX].flags & IORESOURCE_MEM)
		||	((dev->resource[LSD_MEMIO_BAR_INDEX].end - dev->resource[LSD_MEMIO_BAR_INDEX].start + 1) != LSD_MEMIO_BAR_SIZE)
		)
	#endif
	{
		return -ENXIO;
	}

	// determine bar & their request function (use macros because region
	// requesting is a macros)

	#ifndef LSD_ENABLE_MEMIO_BAR
	const resource_size_t base = dev->resource[LSD_IO_BAR_INDEX].start;
	const size_t size = LSD_IO_BAR_SIZE;
	#define request_io_region request_region
	#else
	const resource_size_t base = dev->resource[LSD_MEMIO_BAR_INDEX].start;
	const size_t size = LSD_MEMIO_BAR_SIZE;
	#define request_io_region request_mem_region
	#endif

	// lock I/O bar

	if (!(request_io_region(base, size, LM_NAME)))
		return -EBUSY;

	#ifndef LSD_ENABLE_MEMIO_BAR
	m.pci.mmem = 0;
	const reg_addr_t reg_base = base;
	#else
	if (!(m.pci.mmem = ioremap_nocache(base, size)))
		return detach(dev), -ENXIO;
	const reg_addr_t reg_base = m.pci.mmem;
	#endif

	// obtain PCI registers (m.pci.reg.*)

	m.pci.reg.fwid = reg_base + LSD_RO_FIRMWARE;
	m.pci.reg.ctrl = reg_base + LSD_RO_CTRL;
	m.pci.reg.dma.addr = reg_base + LSD_RO_DMA_ADDR;
	m.pci.reg.dma.size = reg_base + LSD_RO_DMA_SIZE;
	m.pci.reg.dev.ctrl = reg_base + LSD_RO_DEV_CTRL;
	m.pci.reg.dev.status = reg_base + LSD_RO_DEV_STATUS;
	m.pci.reg.dev.data = reg_base + LSD_RO_DEV_DATA;
	m.pci.reg.irq_ctrl = reg_base + LSD_RO_IRQ_CTRL;
	m.pci.reg.mem.ctrl = reg_base + LSD_RO_MEM_CTRL;
	m.pci.reg.mem.addr = reg_base + LSD_RO_MEM_ADDR;
	m.pci.reg.fg.timestamp = reg_base + LSD_RO_FG_TIMESTAMP;
	m.pci.reg.fg.nlost_frames = reg_base + LSD_RO_FG_NLOST_FRAMES;
	m.pci.reg.pcie_ctrl = reg_base + LSD_RO_PCIE_CTRL;
	m.pci.reg.timestamp = reg_base + LSD_RO_TIMESTAMP;
	m.pci.reg.fiber_data_head = reg_base + LSD_RO_FIBER_DATA_HEAD;
	m.pci.reg.hw.func = reg_base + LSD_RO_HW_FUNC;
	m.pci.reg.hw.opt = reg_base + LSD_RO_HW_OPT;
	m.pci.reg.cfg.ctrl = reg_base + LSD_RO_CFG_CTRL;
	m.pci.reg.cfg.data = reg_base + LSD_RO_CFG_DATA;
	#ifdef LSD_ENABLE_HWDBG
	m.pci.reg.x1C = reg_base + LSD_RO_x1C;
	m.pci.reg.x1D = reg_base + LSD_RO_x1D;
	m.pci.reg.x1E = reg_base + LSD_RO_x1E;
	#endif

	m.fwid = reg_get(m.pci.reg.fwid); // lock-less (no ready locker)

	if (m.fwid == ~(u32)0)
		return detach(dev), -ENXIO;

	// obtain IRQ number

	if (dev->irq == -1)
		return detach(dev), -ENXIO;

	irq_number = dev->irq;

	// tune latency time if not yet

	pci_set_master(dev);

	// init private members

	spin_lock_init(&l.io.lock);

	#ifdef LSD_SMP_IO_NDELAY
	l.io.cpu = -1;
	#endif

	#ifdef LSD_VERBOSE
	printk
		(	KERN_DEBUG "%s: Firmware version: %08xh; Func: %08xh; PCIe x%d\n"
		,	LM_NAME, m.fwid
		,	reg_locked_get(m.pci.reg.hw.func)
		,	(reg_locked_get(m.pci.reg.pcie_ctrl) & LSD_RPCM_LINK) >> LSD_RPCMO_LINK
		);
	size_t not_default = 0;
	printk(KERN_DEBUG "%s: Config:", LM_NAME);
	#	ifdef LSD_ENABLE_MEMIO_BAR
		printk("%s memio_bar", not_default++ ? ";" : "");
	#	endif
	#	ifdef LSD_ENABLE_MSI
		printk("%s MSI", not_default++ ? ";" : "");
	#	endif
	#	ifdef LSD_SMP_IO_NDELAY
		printk("%s smp_io_ndelay=%d", not_default++ ? ";" : "", LSD_SMP_IO_NDELAY);
	#	endif
	#	ifdef LSD_MAX_DMA_TIME
		printk("%s max_dma_time=%d", not_default++ ? ";" : "", LSD_MAX_DMA_TIME);
	#	endif
	if (!not_default)
		printk(" default");
	printk("\n");
	#endif

	// prepare cdev subsystem

	cdev_set_parent(&dev->dev);

	return 0;
}

void detach(struct pci_dev * dev)
{
	#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
	pci_clear_master(dev);
	#endif

	#ifndef LSD_ENABLE_MEMIO_BAR
	release_region(dev->resource[LSD_IO_BAR_INDEX].start, LSD_IO_BAR_SIZE);
	#else
	if (m.pci.mmem) iounmap(m.pci.mmem);
	release_mem_region(dev->resource[LSD_MEMIO_BAR_INDEX].start, LSD_MEMIO_BAR_SIZE);
	#endif
}

void reg_lock(void)
{
	if (in_irq())
		spin_lock(&l.io.lock);
	else
		spin_lock_irqsave(&l.io.lock, l.io.irq_flags);

	#ifdef LSD_SMP_IO_NDELAY
	{
		const int cpu = smp_processor_id();

		if (cpu != l.io.cpu)
			ndelay(LSD_SMP_IO_NDELAY);

		l.io.cpu = cpu;
	}
	#endif
}

u32 reg_get(reg_addr_t addr)
{
	#ifndef LSD_ENABLE_MEMIO_BAR
	return inl(addr);
	#else
	return ioread32(addr);
	#endif
}

void reg_set(reg_addr_t addr, u32 value)
{
	#ifndef LSD_ENABLE_MEMIO_BAR
	outl(value, addr);
	#else
	iowrite32(value, addr);
	#endif
}

void reg_unlock(void)
{
	if (in_irq())
		spin_unlock(&l.io.lock);
	else
		spin_unlock_irqrestore(&l.io.lock, l.io.irq_flags);
}

u32 reg_locked_get(reg_addr_t addr)
{
	reg_lock();
	const u32 value = reg_get(addr);
	reg_unlock();

	return value;
}

void reg_locked_set(reg_addr_t addr, u32 value)
{
	reg_lock();
	reg_set(addr, value);
	reg_unlock();
}

u32 mask_value(u32 value, u32 mask)
{
	if (mask)
	{
		while (!(mask & 1U))
		{
			value <<= 1;
			mask >>= 1;
		}
	}

	return value & mask;
}

u32 unmask_value(u32 masked_value, u32 mask)
{
	masked_value &= mask;

	if (mask)
	{
		while (!(mask & 1U))
		{
			masked_value >>= 1;
			mask >>= 1;
		}
	}

	return masked_value;
}

int hello(void)
{
	#ifdef LSD_VERBOSE
	printk(KERN_DEBUG "%s: Welcome!\n", LM_NAME);
	#endif

	return 0;
}

void bye(void)
{
	#ifdef LSD_VERBOSE
	printk(KERN_DEBUG "%s: Bye-bye!\n", LM_NAME);
	#endif
}

int setup(void)
{
	reg_lock();
	{
		const u32 reg_ctrl = reg_get(m.pci.reg.ctrl);
		reg_set(m.pci.reg.ctrl, reg_ctrl | LSD_RCB_RESET);
		reg_set(m.pci.reg.ctrl, reg_ctrl & ~LSD_RCB_RESET);
	}
	reg_unlock();

	return 0;
}

void check(void)
{
	BUG_ON(reg_locked_get(m.pci.reg.fwid) == ~(u32)0);
}

int module_loaded(void)
{
	#ifdef LSD_MAX_DMA_TIME
	iosched_set_max_io_time(msecs_to_jiffies(LSD_MAX_DMA_TIME));
	#endif

	int retcode;

	if (is_error(retcode = iosched_start()))
		return print_error(retcode, "iosched_start"), retcode;

	#ifndef LSD_MEM_ONLY
	{
		if (is_error(retcode = frr_init2()))
			return print_error(retcode, "frr_init2"), iosched_stop(), retcode;

		if (is_error(retcode = fiber_init2()))
			return print_error(retcode, "fiber_init2"), iosched_stop(), retcode;

		if (is_error(retcode = fg_init2()))
			return print_error(retcode, "fg_init2"), iosched_stop(), retcode;

	}
	#endif

	return 0;
}

void unloading_module(void)
{
	iosched_stop();
}

void fix_freezing(void)
{
	if (reg_locked_get(m.pci.reg.irq_ctrl) & LSD_RICB_DMA_EVENT)
	{
		#ifdef LSD_VERBOSE
		printk(KERN_WARNING "%s/%s: Fix uncompleted DMA\n", LM_NAME, __FUNCTION__);
		#endif

		dma_irq();
	}
	else
	{
		#ifdef LSD_VERBOSE
		printk(KERN_WARNING "%s/%s: Unknown reason\n", LM_NAME, __FUNCTION__);
		#endif
	}
}
