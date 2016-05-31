/*
 *	file:		mem.c
 *	date:		25.05.2010
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "mem.h"

#include <asm/atomic.h>
#include <linux/delay.h>
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/types.h>
#include <linux/version.h>
#include <linux/wait.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27)
#	include <asm/semaphore.h>
#else
#	include <linux/semaphore.h>
#endif

#include "cdev.h"
#include "config.h"
#include "dma.h"
#include "hwi.h"
#include "iosched.h"
#include "module.h"
#include "retcode.h"

// subsystem options -----------------------------------------------------------

#if defined(LSD_MEM_ONLY) || defined(LSD_FORCE_MEM_CDEV) || defined(LSD_ENABLE_DADBG)
#	define ENABLE_CDEV
#endif

// local types -----------------------------------------------------------------

typedef enum { IOS_IDLE, IOS_WR, IOS_RD } TIOStatus;
typedef enum { IOR_IDLE, IOR_WR, IOR_RD } TIORequest;

typedef struct
{
	/** Subsystem "ready" flag/value: must be checked in all functions that are
	  * available by external callers (if no <LM_NDEBUG> defined). "0" value
	  * means "subsystem isn't initialized", "1" - "initialized but disabled"
	  * (PROM isn't supported by hardware), "2" - fully initialized */

	atomic_t		init;

	#ifdef ENABLE_CDEV

	/** Memory size (in bytes) */

	struct
	{	loff_t			size;
	}				param;

	/** I/O data:
	  * <status> - current I/O status (one of <TIOStatus>);
	  * <dma_pool> - shared DMA pool (both for writings & readings);
	  * <request> - I/O request;
	  *   <flag> - request state, one of <TIORequest>;
	  *   <arg> - request arguments (set it before flag);
	  *   <done> - raised each time request completed (flag = <IOR_IDLE>) */

	struct
	{	atomic_t		status;
		dma_pool_t *	dma_pool;
		struct
		{	atomic_t		flag;
			struct
			{	u32				addr;
				size_t			nchunks;
			}				arg;
			wait_queue_head_t done;
		}				request;
	}				io;

	/** Character device (user I/O) data:
	  * <fo> and <major> has an ordinary sense;
	  * <lk> - separate seek/read/write operations */

	struct
	{	struct file_operations * fo;
		int				major;
		struct semaphore lk;
	}				uio;

	#endif

} local_data_t;

// local functions -------------------------------------------------------------

static int cleanup(int, int);

static int setup(void); // setup board memory (0th bank)

#ifdef ENABLE_CDEV
static void io_complete(void);

static int cdev_open(struct inode *, struct file *);
static int cdev_close(struct inode *, struct file *);
static loff_t cdev_seek(struct file *, loff_t, int);
static ssize_t cdev_write(struct file *, const char __user *, size_t, loff_t *);
static ssize_t cdev_read(struct file *, char __user *, size_t, loff_t *);
#endif

// local constants -------------------------------------------------------------

#define LSD_SUBSYSTEM_NAME "mem"

static const size_t MA = 4; // memory I/O address alignment

// local variables -------------------------------------------------------------

static local_data_t l;

// implementation --------------------------------------------------------------

int mem_init_(void)
{
	#ifndef LM_NDEBUG
	if (atomic_read(&l.init))
		return -EPERM;
	#endif

	atomic_set(&l.init, 1);

	if (reg_locked_get(m.pci.reg.hw.func) & LSD_RHFB_MEM)
	{
		atomic_set(&l.init, 2);

		int retcode;

		if (is_error(retcode = setup()))
			return retcode;

		#ifdef ENABLE_CDEV
		{
			int ccode = 0;

			l.param.size = (1048576 * 8) << unmask_value(reg_locked_get(m.pci.reg.hw.opt), LSD_RHOM_MEM_SIZE);

			// check value and board compatibility

			if (l.param.size > ((LSD_RMAM_ADDR >> LSD_RMAMO_ADDR) + 1))
				return cleanup(ccode, -EINVAL);

			atomic_set(&l.io.status, IOS_IDLE);

			// allocate 256Kb pool (built-in value)

			if ((retcode = dma_create_pool(1024 * 256, &l.io.dma_pool)) != 0)
				return cleanup(ccode, retcode);

			ccode = 1;

			atomic_set(&l.io.request.flag, IOR_IDLE);

			init_waitqueue_head(&l.io.request.done);

			if (!(l.uio.fo = kzalloc(sizeof(struct file_operations), GFP_KERNEL)))
				return cleanup(ccode, -ENOMEM);

			ccode = 2;

			l.uio.fo->open = cdev_open;
			l.uio.fo->release = cdev_close;
			l.uio.fo->llseek = cdev_seek;
			l.uio.fo->write = cdev_write;
			l.uio.fo->read = cdev_read;

			sema_init(&l.uio.lk, 1); // init mutex

			if (is_error(l.uio.major = cdev_create_single(LSD_SUBSYSTEM_NAME, 0, l.uio.fo)))
				return cleanup(ccode, l.uio.major);

			ccode = 3;
		}
		#endif
	}

	return 0;
}

void mem_release(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init)) return;
	#endif

	cleanup(-1, 0);
}

int cleanup(int ccode, int retcode)
{
	if (atomic_read(&l.init) == 2)
	{
		switch (ccode)
		{
		case -1:;
			// unbreaked
		#ifdef ENABLE_CDEV
		case 3:
			cdev_release(l.uio.major);
			// unbreaked
		case 2:
			kfree(l.uio.fo);
			// unbreaked
		case 1:
			dma_release_pool(&l.io.dma_pool);
			// unbreaked
		#endif
		}
	}

	atomic_set(&l.init, 0);

	return retcode;
}

int setup(void)
{
	// reset and wait "ready" mark

if (!(reg_locked_get(m.pci.reg.dev.status) & LSD_RDSB_MEM_READY))
{
	reg_lock();
	reg_set(m.pci.reg.ctrl, reg_get(m.pci.reg.ctrl) | LSD_RCB_MEM_RESET);
	reg_unlock();

	msleep(1);

	reg_lock();
	reg_set(m.pci.reg.ctrl, reg_get(m.pci.reg.ctrl) & ~LSD_RCB_MEM_RESET);
	reg_unlock();

  msleep(1);

	const unsigned long j0 = jiffies;

	while (1)
	{
		if (reg_locked_get(m.pci.reg.dev.status) & LSD_RDSB_MEM_READY)
			break;

		if (jiffies_to_msecs(jiffies - j0) > 10000)
			return -EIO;

		if (msleep_interruptible(1))
			return -ERESTARTSYS;
	}
}
	// setup mem.ctrl

	reg_lock();
	{
		u32 reg = reg_get(m.pci.reg.mem.ctrl);

		reg &= ~(LSD_RMC_WR_SIZE | LSD_RMC_RD_SIZE);
		reg |= (LSD_MEM_TRANS_WR << LSD_RMCO_WR_SIZE) & LSD_RMC_WR_SIZE;
		reg |= (LSD_MEM_TRANS_RD << LSD_RMCO_RD_SIZE) & LSD_RMC_RD_SIZE;

		reg_set(m.pci.reg.mem.ctrl, reg);
	}
	reg_unlock();

	return 0;
}

int mem_io_status(void)
{
	#ifdef ENABLE_CDEV
	#	ifndef LM_NDEBUG
		if (!atomic_read(&l.init))
			return print_error(-EPERM, __FUNCTION__), IOSCHED_IDLE;
	#	endif

	if (atomic_read(&l.io.status) != IOS_IDLE)
		return IOSCHED_PENDING;

	switch (atomic_read(&l.io.request.flag))
	{
	case IOR_WR: case IOR_RD:
		return IOSCHED_REQUEST;
	}
	#endif

	return IOSCHED_IDLE;
}

void mem_approve_io(void)
{
	#ifdef ENABLE_CDEV
	#	ifndef LM_NDEBUG
		if (!atomic_read(&l.init))
			return print_error(-EPERM, __FUNCTION__);
		if (atomic_read(&l.io.status) != IOS_IDLE)
			return print_error(-EINVAL, __FUNCTION__);
	#	endif

	int retcode = 0;

	switch (atomic_read(&l.io.request.flag))
	{
	case IOR_WR:
		atomic_set(&l.io.status, IOS_WR);
		reg_locked_set(m.pci.reg.mem.addr, l.io.request.arg.addr);
		retcode = dma_pool_request(DMA_MEM, DMA_SEND, l.io.dma_pool, l.io.request.arg.nchunks, io_complete);
		break;
	case IOR_RD:
		atomic_set(&l.io.status, IOS_RD);
		reg_locked_set(m.pci.reg.mem.addr, l.io.request.arg.addr);
		retcode = dma_pool_request(DMA_MEM, DMA_RECV, l.io.dma_pool, l.io.request.arg.nchunks, io_complete);
		break;
	default:
		retcode = -EPIPE;
		break;
	}

	if (is_error(retcode))
	{
		atomic_set(&l.io.status, IOS_IDLE);
		print_error(retcode, __FUNCTION__);
	}
	#endif
}

#ifdef ENABLE_CDEV

void io_complete(void)
{
	#ifndef LM_NDEBUG
	if (atomic_read(&l.io.status) == IOS_IDLE)
		return print_error(-EPERM, LSD_SUBSYSTEM_NAME"/io_complete");
	#endif

	atomic_set(&l.io.request.flag, IOR_IDLE);
	atomic_set(&l.io.status, IOS_IDLE);

	iosched_wakeup();
	wake_up(&l.io.request.done);
}

int cdev_open(struct inode * _1, struct file * _2)
{
	return 0;
}

int cdev_close(struct inode * _1, struct file * _2)
{
	return 0;
}

loff_t cdev_seek(struct file * pfile, loff_t off, int whence)
{
	if (down_interruptible(&l.uio.lk))
		return -ERESTARTSYS;

	// usual seeking

	loff_t new_off;

	switch (whence)
	{
	case 0: // SEEK_SET
		new_off = off;
		break;
	case 1:	// SEEK_CUR
		new_off = pfile->f_pos + off;
		break;
	case 2:	// SEEK_END
		new_off = l.param.size + off;
		break;
	default:
		new_off = -1;
	}

	if ((new_off < 0) || (new_off > l.param.size) || (new_off % MA))
		new_off = -EINVAL;

	if (new_off >= 0)
		pfile->f_pos = new_off;

	return up(&l.uio.lk), new_off;
}

ssize_t cdev_write(struct file * _, const char __user * data, size_t size, loff_t * poff)
{
	if (!data || !size)
		return -EINVAL;

	if (down_interruptible(&l.uio.lk))
		return -ERESTARTSYS;

	if (*poff >= l.param.size)
		return up(&l.uio.lk), -EFBIG;

	if (*poff % MA)
		return up(&l.uio.lk), -ENOMSG; // logic error

	// make some <size> corrections if improper

	if ((*poff + size) > l.param.size)
		size = l.param.size - *poff;

	if (size % sizeof(dma_chunk_t))
		size = sizeof(dma_chunk_t) * (size / sizeof(dma_chunk_t));

	if (!size)
		return up(&l.uio.lk), -EINVAL;

	// make I/O

	const size_t nchunks = (size + l.io.dma_pool->size - 1) / l.io.dma_pool->size;

	ssize_t written = 0, i;
	int retcode;

	for (i = 0; i < nchunks; ++i)
	{
		const size_t io_size = min(l.io.dma_pool->size, size - written);
		const size_t io_nchunks = io_size / sizeof(dma_chunk_t);

		if (is_error(retcode = set_dma_pool_u(l.io.dma_pool, (const dma_chunk_t __user *)(data + written), io_nchunks)))
			return up(&l.uio.lk), written ? written : retcode;

		l.io.request.arg.addr = (*poff << LSD_RMAMO_ADDR) & LSD_RMAM_ADDR;
		l.io.request.arg.nchunks = io_nchunks;

		atomic_set(&l.io.request.flag, IOR_WR);

		iosched_wakeup();

		if	(	!wait_event_timeout
				(	l.io.request.done
				,	atomic_read(&l.io.request.flag) == IOR_IDLE
				,	HZ
				)
			)
		{
			atomic_set(&l.io.request.flag, IOR_IDLE);
			return up(&l.uio.lk), written ? written : -EIO;
		}

		*poff += io_size;
		written += io_size;
	}

	return up(&l.uio.lk), written;
}

ssize_t cdev_read(struct file * _, char __user * buffer, size_t size, loff_t * poff)
{
	if (!buffer || !size)
		return -EINVAL;

	if (down_interruptible(&l.uio.lk))
		return -ERESTARTSYS;

	if (*poff >= l.param.size)
		return up(&l.uio.lk), -ESPIPE;

	if (*poff % MA)
		return up(&l.uio.lk), -ENOMSG; // logic error

	// make some <size> corrections if improper

	if ((*poff + size) > l.param.size)
		size = l.param.size - *poff;

	if (size % sizeof(dma_chunk_t))
		size = sizeof(dma_chunk_t) * (size /sizeof(dma_chunk_t));

	if (!size)
		return up(&l.uio.lk), -EINVAL;

	// make I/O

	const size_t nchunks = (size + l.io.dma_pool->size - 1) / l.io.dma_pool->size;

	ssize_t readed = 0, i;
	int retcode;

	for (i = 0; i < nchunks; ++i)
	{
		const size_t io_size = min(l.io.dma_pool->size, size - readed);
		const size_t io_nchunks = io_size / sizeof(dma_chunk_t);

		l.io.request.arg.addr = (*poff << LSD_RMAMO_ADDR) & LSD_RMAM_ADDR;
		l.io.request.arg.nchunks = io_nchunks;

		atomic_set(&l.io.request.flag, IOR_RD);

		iosched_wakeup();

		if	(	!wait_event_timeout
				(	l.io.request.done
				,	atomic_read(&l.io.request.flag) == IOR_IDLE
				,	HZ
				)
			)
		{
			atomic_set(&l.io.request.flag, IOR_IDLE);
			return up(&l.uio.lk), readed ? readed : -EIO;
		}

		if (is_error(retcode = get_dma_pool_u(l.io.dma_pool, (dma_chunk_t __user *)(buffer + readed), io_nchunks)))
			return up(&l.uio.lk), readed ? readed : retcode;

		*poff += io_size;
		readed += io_size;
	}

	return up(&l.uio.lk), readed;
}

#endif
