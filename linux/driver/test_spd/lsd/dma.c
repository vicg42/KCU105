/*
 *	file:		dma.cpp
 *	date:		22.05.2010
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "dma.h"

#include <asm/atomic.h>
#include <asm/bitops.h>
#include <asm/uaccess.h>
#include <linux/gfp.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/version.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27)
#	include <asm/semaphore.h>
#else
#	include <linux/semaphore.h>
#endif

#include "config.h"
#include "hwi.h"
#include "module.h"
#include "retcode.h"

// local types -----------------------------------------------------------------

/** Private structure holds hardware (board) buffer index, it has an "u32" type
  * to make clear-type board interaction */

typedef struct
{	u32				index;
} dma_buffer_private_t;

typedef struct
{
	/** Subsystem "ready" flag: all "public" calls must take into it's value
	  * (if no LM_NDEBUG defined) */

	atomic_t		init;

	/** Members of <param> are determined during initialization and never
	  * changed later:
	  * <nbuffers_lim> - maximum number of buffers that board can hold ("u32"
	  *   type for clear operations with "u32:index" values);
	  * <buffer_size_lim> - maximum size of buffer that can be allocated */

	struct
	{	u32				nbuffers_lim;
		size_t			buffer_size_lim;
	}				param;

	/** Allocation table:
	  * <arr> buffer allocation table bit-array: "1" value of n-th bit is a mark
	  *   that n-th buffer is allocated - board holds it);
	  * <free> - number of unused buffers (can be determined by summation of
	  *   <arr> zero-bits) */

	struct
	{	void *			arr;
		size_t			free;
	}				at;

	/** I/O data:
	  * <lk> - makes <request> function reentrable;
	  * <complete> - active transaction completion callback; it becomes non-zero
	  *   in <request> function only and reseted in completion interrupt;
	  * <last_buffer> - stores the parameters of last buffer that takes part
	  *   in current transaction;
	  *   <index> - buffer index;
	  *   <size> - if not zero - a flag that H/W buffer size isn't matched
	  *     to really allocated - must be restored when transaction completes
	  *     ("u32" type to match exactly to H/W) */

	struct
	{	struct semaphore lk;
		void (* complete)(void);
		struct
		{	u32				index;
			u32				size;
		}				last_buffer;
	}				io;

} local_data_t;

// local functions -------------------------------------------------------------

static int cleanup(int, int);

// function finds first index that can be used to allocate continuous set of
// DMA buffers (argument is a number of required buffers)

static int get_first_index(size_t nbuffer, u32 * p_index);

// function allocates new buffer and makes it H/W registration

static int setup_buffer(u32 index, size_t size, dma_buffer_t **);

// function cancels H/W registration of buffer and released memory

static int release_buffer(dma_buffer_t **);

// generic DMA request function. expects DMA operation target, direction, first
// and last buffers of transaction, last buffer number of data chunks and
// completion callback

static int request(
	TDMATarget, TDMADir
,	dma_buffer_t * first
,	dma_buffer_t * last, size_t last_nchunks
,	void (* complete)(void)
);

// local constants -------------------------------------------------------------

#define LSD_SUBSYSTEM_NAME "dma"

static const u32 IRQ_SRC_DMA = (LSD_RICV_SRC_DMA << LSD_RICMO_SRC) & LSD_RICM_SRC;

// local variables -------------------------------------------------------------

static local_data_t l;

// implementation --------------------------------------------------------------

int dma_init(void)
{
	#ifndef LM_NDEBUG
	if (atomic_read(&l.init))
		return -EPERM;
	#endif

	int ccode = 0;

	l.param.nbuffers_lim = (LSD_RDCM_DMA_BUFFER >> LSD_RDCMO_DMA_BUFFER) + 1;
	l.param.buffer_size_lim = LSD_MAX_DMA_BUFFER_SIZE * 1024;

	const size_t at_arr_size = (l.param.nbuffers_lim + 7) / 8;

	if (!(l.at.arr = kzalloc(at_arr_size, GFP_KERNEL)))
		return cleanup(ccode, -ENOMEM);

	ccode = 1;

	l.at.free = l.param.nbuffers_lim;

	sema_init(&l.io.lk, 1); // init mutex
	l.io.complete = 0;

	reg_locked_set(m.pci.reg.irq_ctrl, IRQ_SRC_DMA | LSD_RICB_ENABLE);

	ccode = 2;

	#ifdef LSD_VERBOSE
	printk
		(	KERN_DEBUG "%s/%s: Up to %d buffers supported, each up to %d bytes\n"
		,	LM_NAME, LSD_SUBSYSTEM_NAME
		,	l.param.nbuffers_lim, (int)l.param.buffer_size_lim
		);
	#endif

	atomic_set(&l.init, 1);

	return 0;
}

void dma_release(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init)) return;
	#endif

	if (l.at.free != l.param.nbuffers_lim)
	{
		printk
			(	KERN_WARNING "%s/%s: %d unreleased buffers on exit\n"
			,	LM_NAME, LSD_SUBSYSTEM_NAME, (int)(l.param.nbuffers_lim - l.at.free)
			);
	}

	cleanup(-1, 0);
}

int cleanup(int ccode, int retcode)
{
	switch (ccode)
	{
	case -1:;
		// unbreaked
	case 2:
		reg_locked_set(m.pci.reg.irq_ctrl, IRQ_SRC_DMA);
		// unbreaked
	case 1:
		kfree(l.at.arr);
		// unbreaked
	default:
		atomic_set(&l.init, 0);
		// unbreaked
	}

	return retcode;
}

irqreturn_t dma_irq(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return print_error(-EPERM, __FUNCTION__), IRQ_NONE;
	#endif

	irqreturn_t retcode = IRQ_NONE;

	reg_lock();
	{
		// reset IRQ requests

		if (reg_get(m.pci.reg.irq_ctrl) & LSD_RICB_DMA_EVENT)
		{
			reg_set(m.pci.reg.irq_ctrl, IRQ_SRC_DMA | LSD_RICB_RESET);
			retcode = IRQ_HANDLED;
		}

		// restore buffer size (if need)

		if ((retcode == IRQ_HANDLED) && l.io.last_buffer.size)
		{
			u32 reg = reg_get(m.pci.reg.dev.ctrl);

			reg &= ~LSD_RDCM_DMA_BUFFER;
			reg |= ((l.io.last_buffer.index << LSD_RDCMO_DMA_BUFFER) & LSD_RDCM_DMA_BUFFER);

			reg_set(m.pci.reg.dev.ctrl, reg);
			reg_set(m.pci.reg.dma.size, l.io.last_buffer.size);
		}
	}
	reg_unlock();

	if ((retcode == IRQ_HANDLED) && l.io.complete)
	{
		// notify caller (release callback before executing: to avoid "busy"
		// state if next DMA request arrives shortly (e.g. from another CPU content)

		void (* complete)(void) = l.io.complete;
		l.io.complete = 0;

		(complete)();
	}

	return retcode;
}

size_t dma_buffer_size_lim(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return print_error(-EPERM, __FUNCTION__), 0;
	#endif

	return l.param.buffer_size_lim;
}

int dma_create_buffer(size_t size, dma_buffer_t ** pp)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	if (!size || !pp || *pp || (size > l.param.buffer_size_lim) || (size % sizeof(dma_chunk_t)))
		return -EINVAL;

	u32 index;
	const int retcode = get_first_index(1, &index);

	if (is_error(retcode))
		return retcode;

	return setup_buffer(index, size, pp);
}

int dma_release_buffer(dma_buffer_t ** pp)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	if (!pp || !*pp) // silent
		return 0;

	return release_buffer(pp);
}

int dma_create_pool(size_t size, dma_pool_t ** pp)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	if (!size || !pp || *pp || (size % sizeof(dma_chunk_t)))
		return -EINVAL;

	const size_t nbuffers = (size + l.param.buffer_size_lim - 1) / l.param.buffer_size_lim;

	if (!nbuffers)
		return -ENOMSG; // logic error

	u32 index;
	int retcode = get_first_index(nbuffers, &index);

	if (is_error(retcode))
		return retcode;

	// allocate memory

	dma_pool_t * pool = kmalloc(sizeof(dma_pool_t), GFP_KERNEL);

	if	(	!pool
		||	!(pool->arr = kzalloc(nbuffers * sizeof(dma_buffer_t *), GFP_KERNEL))
		)
	{
		if (pool)
			kfree(pool);

		return -ENOMEM;
	}

	// setup buffers

	size_t i, j;
	for (i = 0; i < nbuffers; ++i)
	{
		size_t cur_size = 0;

		if (i != (nbuffers - 1))
			cur_size = l.param.buffer_size_lim;
		else
			cur_size = size - l.param.buffer_size_lim * i;

		if (is_ok(retcode = setup_buffer(index + i, cur_size, &pool->arr[i])))
			continue;

		// something wrong: make rollback and exit

		for (j = 0; j < i; ++j)
			release_buffer(&pool->arr[j]);

		kfree(pool->arr);
		kfree(pool);

		return retcode;
	}

	// setup pool members

	pool->nbuffers = nbuffers;
	pool->size = size;

	// store result

	*pp = pool;

	return 0;
}

int dma_release_pool(dma_pool_t ** pp)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	if (!pp || !*pp) // silent
		return 0;

	dma_pool_t * pool = *pp;

	size_t i;
	for (i = 0; i < pool->nbuffers; ++i)
		release_buffer(&pool->arr[i]);

	kfree(pool->arr);
	kfree(pool);

	*pp = 0;

	return 0;
}

int get_first_index(size_t nbuffers, u32 * p_index)
{
	// reject immediately if not enough free indecies

	if (nbuffers > l.at.free)
		return -ENOMEM;

	// find inquired indecies set

	u32 index;

	size_t i, ilim, j, jlim;
	for (i = 0, ilim = (l.param.nbuffers_lim - nbuffers + 1); i < ilim; ++i)
	{
		index = i;

		for (j = i, jlim = (i + nbuffers); j < jlim; ++j)
		{
			if (test_bit(j, l.at.arr) != 0)
			{
				index = l.param.nbuffers_lim;
				break;
			}
		}

		if (index == i)
		{
			if (p_index)
				*p_index = index;

			return 0;
		}
	}

	return -ENOMEM;
}

int setup_buffer(u32 index, size_t size, dma_buffer_t ** pp)
{
	#ifndef LM_NDEBUG
	{
		// check arguments

		if (index >= l.param.nbuffers_lim)
			return -EINVAL;

		if (!size || !pp || *pp || (size % sizeof(dma_chunk_t)))
			return -EINVAL;

		// check that selected buffer (by index) is not used

		if (test_bit(index, l.at.arr))
			return -EBUSY;
	}
	#endif

	// allocate memory

	dma_buffer_t * buffer = kzalloc(sizeof(dma_buffer_t), GFP_KERNEL);

	if	(	!buffer
		||	!(buffer->ptr = kmalloc(size, GFP_DMA32))
		||	!(buffer->pd = kmalloc(sizeof(dma_buffer_private_t), GFP_KERNEL))
		)
	{
		if (buffer && buffer->ptr)
			kfree(buffer->ptr);

		if (buffer)
			kfree(buffer);

		return -ENOMEM;
	}

	// setup other dma_buffer_t members

	buffer->nchunks = size / sizeof(dma_chunk_t);
	((dma_buffer_private_t *)buffer->pd)->index = index;

	// make H/W registration

	const u32 addr = __pa(buffer->ptr);

	reg_lock();
	{
		u32 reg = reg_get(m.pci.reg.dev.ctrl);

		reg &= ~LSD_RDCM_DMA_BUFFER;
		reg |= ((index << LSD_RDCMO_DMA_BUFFER) & LSD_RDCM_DMA_BUFFER);

		reg_set(m.pci.reg.dev.ctrl, reg);
		reg_set(m.pci.reg.dma.addr, addr);
		reg_set(m.pci.reg.dma.size, size);
	}
	reg_unlock();

	// modify allocation table

	set_bit(index, l.at.arr);
	--l.at.free;

	// store result

	*pp = buffer;

	return 0;
}

int release_buffer(dma_buffer_t ** pp)
{
	#ifndef LM_NDEBUG
	{
		// check arguments

		if (!pp || !*pp)
			return -EINVAL;

		const dma_buffer_private_t * pd = (*pp)->pd;

		if (pd->index >= l.param.nbuffers_lim)
			return -EINVAL;

		if (!test_bit(pd->index, l.at.arr))
			return -EINVAL;
	}
	#endif

	const dma_buffer_private_t * pd = (*pp)->pd;

	// modify allocation table

    clear_bit(pd->index, l.at.arr);
    ++l.at.free;

	// make H/W registration cancelling

	reg_lock();
	{
		u32 reg = reg_get(m.pci.reg.dev.ctrl);

		reg &= ~LSD_RDCM_DMA_BUFFER;
		reg |= ((pd->index << LSD_RDCMO_DMA_BUFFER) & LSD_RDCM_DMA_BUFFER);

		reg_set(m.pci.reg.dev.ctrl, reg);
		reg_set(m.pci.reg.dma.addr, 0);
		reg_set(m.pci.reg.dma.size, 0);
	}
	reg_unlock();

    // release memory

	kfree(pd);
	kfree((*pp)->ptr);
	kfree(*pp);

	*pp = 0;

	return 0;
}

int dma_request(
	TDMATarget target
,	TDMADir direction
,	dma_buffer_t * buffer
,	size_t nchunks
,	void (* complete)(void)
)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	return request(target, direction, buffer, buffer, nchunks, complete);
}

int dma_pool_request(
	TDMATarget target
,	TDMADir direction
,	dma_pool_t * pool
,	size_t nchunks
,	void (* complete)(void)
)
{
	#ifndef LM_NDEBUG
	{
		if (!atomic_read(&l.init))
			return -EPERM;

		if (!pool || (nchunks > pool->size / sizeof(dma_chunk_t))) // basic pool checks
			return -EINVAL;
	}
	#endif

	if (!nchunks || (nchunks == (pool->size / sizeof(dma_chunk_t))))
	{
		return request
			(	target, direction
			,	pool->arr[0], pool->arr[pool->nbuffers - 1], 0
			,	complete
			);
	}

	// rule (see pool allocation): pool buffers has the same sizes (the only
	// exclusion is the last buffer - can be smaller then other), so number
	// of DMA buffers for DMA transaction

	const size_t nbuffers = (nchunks + pool->arr[0]->nchunks - 1) / pool->arr[0]->nchunks;

	#ifndef LM_NDEBUG
	if (!nbuffers || (nbuffers > pool->nbuffers))
		return -ENOSYS; // logic error
	#endif

	// then calculate last buffer number of data chunks

	const size_t last_nchunks = nchunks - pool->arr[0]->nchunks * (nbuffers - 1);

	#ifndef LM_NDEBUG
	if (!last_nchunks || (last_nchunks > pool->arr[nbuffers - 1]->nchunks))
		return -ENOSYS; // logic error
	#endif

	return request
		(	target, direction
		,	pool->arr[0], pool->arr[nbuffers - 1], last_nchunks
		,	complete
		);
}

int request(
	TDMATarget target
,	TDMADir direction
,	dma_buffer_t * first
,	dma_buffer_t * last
,	size_t last_nchunks
,	void (* complete)(void)
)
{
	#ifndef LM_NDEBUG
	{
		// simple buffers checks (their content is "trusted")

		if (!first || !last)
			return -EINVAL;

		if (((dma_buffer_private_t *)last->pd)->index < ((dma_buffer_private_t *)first->pd)->index)
			return -EINVAL;

		// size can be zero or value less-or-equal to buffer size

		if (last_nchunks > last->nchunks)
			return -EINVAL;
	}
	#endif

	// determine destination & direction H/W codes (check argument)

	u32 targ_code = 0, dir_code = 0;

	switch (target)
	{
	case DMA_FIBER:
		targ_code = LSD_RDCV_IO_TARGET_FIBER;
		break;
	case DMA_MEM:
		targ_code = LSD_RDCV_IO_TARGET_MEM;
		break;
	case DMA_FG:
		targ_code = LSD_RDCV_IO_TARGET_FG;
		break;
	default:
		return -EINVAL;
	}

	switch (direction)
	{
	case DMA_RECV:
		dir_code = LSD_RDCV_DMA_DIRECTION_IN;
		break;
	case DMA_SEND:
		dir_code = LSD_RDCV_DMA_DIRECTION_OUT;
		break;
	default:
		return -EINVAL;
	}

	if (down_interruptible(&l.io.lk))
		return -ERESTARTSYS;

	// check that no active transaction

	if ((reg_locked_get(m.pci.reg.dev.status) & LSD_RDSB_DMA_BUSY) || l.io.complete)
		return up(&l.io.lk), -EBUSY;

	l.io.complete = complete;

	// setup last buffer (if it have not original size)

	const dma_buffer_private_t * last_pd = last->pd;

	l.io.last_buffer.index = last_pd->index;
	l.io.last_buffer.size = 0;

	if (last_nchunks && (last_nchunks != last->nchunks))
	{
		reg_lock();
		{
			u32 reg = reg_get(m.pci.reg.dev.ctrl);

			reg &= ~LSD_RDCM_DMA_BUFFER;
			reg |= ((last_pd->index << LSD_RDCMO_DMA_BUFFER) & LSD_RDCM_DMA_BUFFER);

			reg_set(m.pci.reg.dev.ctrl, reg);
			reg_set(m.pci.reg.dma.size, last_nchunks * sizeof(dma_chunk_t));
		}
		reg_unlock();

		l.io.last_buffer.size = last->nchunks * sizeof(dma_chunk_t);
	}

	// start transaction

	const dma_buffer_private_t * first_pd = first->pd;

	reg_lock();
	{
		u32 reg = reg_get(m.pci.reg.dev.ctrl);

		// set target

		reg &= ~LSD_RDCM_IO_TARGET;
		reg |= (targ_code << LSD_RDCMO_IO_TARGET) & LSD_RDCM_IO_TARGET;

		// set direction

		reg &= ~LSD_RDCM_DMA_DIRECTION;
		reg |= (dir_code << LSD_RDCMO_DMA_DIRECTION) & LSD_RDCM_DMA_DIRECTION;

		// set first buffer

		reg &= ~LSD_RDCM_DMA_BUFFER;
		reg |= ((first_pd->index << LSD_RDCMO_DMA_BUFFER) & LSD_RDCM_DMA_BUFFER);

		// set number of buffers (pass "nbuffers - 1" value to board)

		const u32 nbuffers = last_pd->index - first_pd->index;

		reg &= ~LSD_RDCM_DMA_NBUFFERS;
		reg |= (nbuffers << LSD_RDCMO_DMA_NBUFFERS) & LSD_RDCM_DMA_NBUFFERS;

		// the final countdown..

		reg |= LSD_RDCB_DMA_REQUEST;

		// BANG!!

		reg_set(m.pci.reg.dev.ctrl, reg);
	}
	reg_unlock();

	return up(&l.io.lk), 0;
}

int reset_dma_pool(dma_pool_t * pp, u8 value)
{
	#ifndef LM_NDEBUG
	if (!pp)
		return -EINVAL;
	#endif

	size_t i;
	for (i = 0; i < pp->nbuffers; ++i)
		memset(pp->arr[i]->ptr, value, pp->arr[i]->nchunks * sizeof(dma_chunk_t));

	return 0;
}

int set_dma_pool(dma_pool_t * pool, const dma_chunk_t * data, size_t nchunks)
{
	#ifndef LM_NDEBUG
	if (!pool || !data || (nchunks * sizeof(dma_chunk_t) > pool->size))
		return -EINVAL;
	#endif

	size_t i, offset = 0;
	for (i = 0; (i < pool->nbuffers) && (offset < nchunks); ++i)
	{
		const size_t cur = min(pool->arr[i]->nchunks, nchunks - offset);
		memcpy(pool->arr[i]->ptr, data + offset, cur * sizeof(dma_chunk_t));
		offset += cur;
	}

	return 0;
}

int get_dma_pool(dma_pool_t * pool, dma_chunk_t * buffer, size_t nchunks)
{
	#ifndef LM_NDEBUG
	if (!pool || !buffer || (nchunks * sizeof(dma_chunk_t) > pool->size))
		return -EINVAL;
	#endif

	size_t i, offset = 0;
	for (i = 0; (i < pool->nbuffers) && (offset < nchunks); ++i)
	{
		const size_t cur = min(pool->arr[i]->nchunks, nchunks - offset);
		memcpy(buffer + offset, pool->arr[i]->ptr, cur * sizeof(dma_chunk_t));
		offset += cur;
	}

	return 0;
}

int set_dma_pool_u(dma_pool_t * pool, const dma_chunk_t __user * data, size_t nchunks)
{
	#ifndef LM_NDEBUG
	if (!pool || !data || (nchunks * sizeof(dma_chunk_t) > pool->size))
		return -EINVAL;
	#endif

	size_t i, offset = 0;
	for (i = 0; (i < pool->nbuffers) && (offset < nchunks); ++i)
	{
		const size_t cur = min(pool->arr[i]->nchunks, nchunks - offset);

		if (copy_from_user(pool->arr[i]->ptr, data + offset, cur * sizeof(dma_chunk_t)))
			return -EFAULT;

		offset += cur;
	}

	return 0;
}

int get_dma_pool_u(dma_pool_t * pool, dma_chunk_t __user * buffer, size_t nchunks)
{
	#ifndef LM_NDEBUG
	if (!pool || !buffer || (nchunks * sizeof(dma_chunk_t) > pool->size))
		return -EINVAL;
	#endif

	size_t i, offset = 0;
	for (i = 0; (i < pool->nbuffers) && (offset < nchunks); ++i)
	{
		const size_t cur = min(pool->arr[i]->nchunks, nchunks - offset);

		if (copy_to_user(buffer + offset, pool->arr[i]->ptr, cur * sizeof(dma_chunk_t)))
			return -EFAULT;

		offset += cur;
	}

	return 0;
}
