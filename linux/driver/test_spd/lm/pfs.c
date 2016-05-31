/*
 *	file:		pfs.cpp
 *	date:		07.12.2009
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "pfs.h"

#include <asm/atomic.h>
#include <linux/list.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/version.h>

#include "config.h"
#include "retcode.h"

// local types -----------------------------------------------------------------

struct subdir_t
{	struct list_head list;
	struct proc_dir_entry * pde;
	char *			name;
};

struct rdentry_t
{	struct list_head list;
	struct subdir_t * parent;			// if 0 parent is a root folder
	char *			name;
};

typedef struct
{
	/** Subsystem "ready" flag: all "public" calls must take into it's value
	  * (if no <LM_NDEBUG> defined) */

	atomic_t		init;

	/** Module <proc_dir_entry> (root filder) */

	struct proc_dir_entry * pde;

	/** A lists of <subdir_t> & <rdentry_t> items */

	struct list_head subdir_list;
	struct list_head rdentry_list;

} local_data_t;

// local functions -------------------------------------------------------------

static int cleanup(int, int);
static void cleanup_subdir_list(void);
static void cleanup_rdentry_list(void);

// local constants -------------------------------------------------------------

#define LM_SUBSYSTEM_NAME "pfs"

// local variables -------------------------------------------------------------

static local_data_t l;

// implementation --------------------------------------------------------------

int pfs_init(void)
{
	#ifndef LM_NDEBUG
	if (atomic_read(&l.init))
		return -EPERM;
	#endif

	int ccode = 0;

	if (!pfs_root || !strlen(pfs_root))
		return cleanup(ccode, -EINVAL);

	if (!(l.pde = proc_mkdir(pfs_root, 0)))
		return cleanup(ccode, -ENOMEM);

	ccode = 1;

	#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,30)
	l.pde->owner = THIS_MODULE;
	#endif

	INIT_LIST_HEAD(&l.subdir_list);
	INIT_LIST_HEAD(&l.rdentry_list);

	atomic_set(&l.init, 1);

	return 0;
}

void pfs_release(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return print_error(-EPERM, __FUNCTION__);
	#endif

	cleanup(-1, 0);
}

static int cleanup(int ccode, int retcode)
{
	switch (ccode)
	{
	case -1:
		cleanup_rdentry_list();
		cleanup_subdir_list();
		// unbreaked
	case 1:
		remove_proc_entry(pfs_root, 0);
		// unbreaked
	default:
		atomic_set(&l.init, 0);
		// unbreaked
	}

	return retcode;
}

static void cleanup_subdir_list(void)
{
	while (!list_empty(&l.subdir_list))
	{
		struct subdir_t * subdir = list_entry(l.subdir_list.next, struct subdir_t, list);

		remove_proc_entry(subdir->name, l.pde);
		kfree(subdir->name);
		list_del(&subdir->list);
		kfree(subdir);
	}
}

static void cleanup_rdentry_list(void)
{
	while (!list_empty(&l.rdentry_list))
	{
		struct rdentry_t * rdentry = list_entry(l.rdentry_list.next, struct rdentry_t, list);

		remove_proc_entry(rdentry->name, rdentry->parent ? rdentry->parent->pde : l.pde);
		kfree(rdentry->name);
		list_del(&rdentry->list);
		kfree(rdentry);
	}
}

int pfs_make_dir(const char * dirname)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	// check argument

	if (!dirname || !strlen(dirname))
		return -EINVAL;

	// block name dumplicates

	struct list_head * lh;

	list_for_each(lh, &l.subdir_list)
	{
		struct subdir_t * subdir = list_entry(lh, struct subdir_t, list);

		if (!strcmp(subdir->name, dirname))
			return -EEXIST;
	}

	// block <node> name dumplicates

	list_for_each(lh, &l.rdentry_list)
	{
		struct rdentry_t * rdendtry = list_entry(lh, struct rdentry_t, list);

		if	(	!rdendtry->parent
			&&	!strcmp(rdendtry->name, dirname)
			)
		{
			return -EINVAL;
		}
	}

	// allocate/initialize list node & fields

	struct subdir_t * subdir = kmalloc(sizeof(struct subdir_t), GFP_KERNEL);

	if (!subdir)
		return -ENOMEM;

	if (!(subdir->name = kmalloc(strlen(dirname) + 1, GFP_KERNEL)))
	{
		kfree(subdir);
		return -ENOMEM;
	}

	strcpy(subdir->name, dirname);

	if (!(subdir->pde = proc_mkdir(dirname, l.pde)))
	{
		kfree(subdir->name);
		kfree(subdir);
		return -ENOMEM;
	}

	#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,30)
	subdir->pde->owner = THIS_MODULE;
	#endif

	// insert node to list

	list_add(&subdir->list, &l.subdir_list);

	return 0;
}

int pfs_make_rdentry(
	const char * entryname
,	const char * dirname
,	read_proc_t * prp
,	void * data
)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return -EPERM;
	#endif

	// check arguments

	if (!entryname || !strlen(entryname) || !prp)
		return -EINVAL;

	// find parent

	struct subdir_t * parent = 0;
	struct list_head * lh;

	if (dirname)
	{
		list_for_each(lh, &l.subdir_list)
		{
			struct subdir_t * subdir = list_entry(lh, struct subdir_t, list);

			if (!strcmp(subdir->name, dirname))
			{
				parent = subdir;
				break;
			}
		}

		if (!parent)
			return -EINVAL;
	}

	// block name duplicates (of same parents)

	list_for_each(lh, &l.rdentry_list)
	{
		struct rdentry_t * rdendtry = list_entry(lh, struct rdentry_t, list);

		if	(	(rdendtry->parent == parent)
			&&	!strcmp(rdendtry->name, entryname)
			)
		{
			return -EEXIST;
		}
	}

	// block <dir> name dumplicates

	if (!dirname)
	{
		list_for_each(lh, &l.subdir_list)
		{
			struct subdir_t * subdir = list_entry(lh, struct subdir_t, list);

			if (!strcmp(subdir->name, entryname))
				return -EINVAL;
		}
	}

	// allocate/initialize list node & fields

	struct rdentry_t * rdentry = kmalloc(sizeof(struct rdentry_t), GFP_KERNEL);

	if (!rdentry)
		return -ENOMEM;

	if (!(rdentry->name = kmalloc(strlen(entryname) + 1, GFP_KERNEL)))
	{
		kfree(rdentry);
		return -ENOMEM;
	}

	strcpy(rdentry->name, entryname);

	rdentry->parent = parent;

	struct proc_dir_entry * pde = create_proc_read_entry
		(	entryname
		,	0444
		,	parent ? parent->pde : l.pde
		,	prp, data
		);

	if (!pde)
	{
		kfree(rdentry->name);
		kfree(rdentry);
		return -ENOMEM;
	}

	#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,30)
	pde->owner = THIS_MODULE;
	#endif

	// insert node to list

	list_add(&rdentry->list, &l.rdentry_list);

	return 0;
}
