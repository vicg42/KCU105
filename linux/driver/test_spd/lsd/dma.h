/*
 *	file:		dma.h
 *	date:		22.05.2010
 *	authors:	Topolsky
 *	company:	Linkos
 *	format:		tab4
 *	descript.:	DMA subsystem service and management interface
 */

#ifndef __LSD_DMA_H
#define __LSD_DMA_H

#include <linux/interrupt.h>
#include <linux/types.h>

/** <modinit> subsystem entries */

int dma_init(void);
void dma_release(void);

/** <irq> subsystem entry */

irqreturn_t dma_irq(void);

/** DMA buffer/pool creating/releasing requires board interaction. The best way
  * to keep their implementation simple is to follow next rules:
  * - Make allocations during module subsystems initialization (single execution
  *   thread - so accessing board is safe);
  * - Make normal module board interaction (e.g. using <iosched> or protecting
  *   transaction calls with spinlocks);
  * - Make deallocations during module subsystems releasing (when raced
  *   module board interaction stopped) */

/** Buffer/pool structures:
  *
  * <dma_chunk_t> is a minimum DMA data chunk (all transaction lengths are
  *   divisible by it);
  *
  * <dma_buffer_t> members description:
  *   <ptr> - pointer to allocated buffer;
  *   <nchunks> - number of buffer chunks (items);
  *   <pd> - private data
  *
  * <dma_pool_t> members descriptions:
  *   <arr> - pointer to (allocated) buffers array;
  *   <nbuffer> - number of array items (DMA buffers);
  *   <size> - total pool buffers size (bytes)
  *
  * Don't change any field of buffer/pool structures manually! (or take U.B)
  * Of course, you can change data referenced by corresponding pointers */

typedef u32 dma_chunk_t;

typedef struct
{	dma_chunk_t *	ptr;
	size_t			nchunks;
	void *			pd;
}				dma_buffer_t;

typedef struct
{	dma_buffer_t ** arr;
	size_t			nbuffers;
	size_t			size;
}				dma_pool_t;

/** Function returns maximum allowed buffer size (in bytes) */

size_t dma_buffer_size_lim(void);

/** Buffer creating/releasing functions:
  * <dma_create_buffer> expects a required buffer size (bytes) and pointer
  *   to pointer (pointee value must be zero) that will be initialized
  *   if function succeeds (zero result);
  * <dma_release_buffer> expects pointer to pointer that is previosly
  *   initialized by <dma_create_buffer> function, if succeeds (zero result)
  *   pointee value is reseted to zero; it also succeeds if pointee value is
  *   zero (does nothing);
  * Both returns zero on succeess or negative error code;
  * Both functions aren't reentrable and aren't atomic */

int dma_create_buffer(size_t, dma_buffer_t **);
int dma_release_buffer(dma_buffer_t **);

/** Pool creating/releasing functions: behavour is similar with single buffer
  * creating/releasing functions */

int dma_create_pool(size_t, dma_pool_t **);
int dma_release_pool(dma_pool_t **);

/** Simple helpers (pool data access) */

int reset_dma_pool(dma_pool_t *, u8);
int set_dma_pool(dma_pool_t *, const dma_chunk_t *, size_t nchunks);
int get_dma_pool(dma_pool_t *, dma_chunk_t *, size_t nchunks);
int set_dma_pool_u(dma_pool_t *, const dma_chunk_t __user *, size_t nchunks);
int get_dma_pool_u(dma_pool_t *, dma_chunk_t __user *, size_t nchunks);

/** Transaction management types & functions */

typedef enum
{	DMA_FIBER
,	DMA_MEM
,	DMA_FG
} TDMATarget;

typedef enum { DMA_RECV, DMA_SEND } TDMADir;

/** Buffer/pool transaction request functions:
  * - Reentrable & not atomic;
  * - The "size_t" argument (if not zero) owerrides DMA transaction number of
  *   DMA data chunks;
  * - The last argument is a "transaction complete" callback, it will be called
  *   in interrupt content (usually, but no guarantees because b258!);
  * - Both returns zero on success or error code (negative) */

int dma_request(TDMATarget, TDMADir, dma_buffer_t *, size_t, void (*)(void));
int dma_pool_request(TDMATarget, TDMADir, dma_pool_t *, size_t, void (*)(void));

#endif // __LSD_DMA_H
