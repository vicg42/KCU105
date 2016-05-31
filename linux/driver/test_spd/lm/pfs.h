/**
 *	file:		pfs.h
 *	date:		07.12.2009
 *	authors:	Topolsky
 *	format:		tab4
 *	descript.:	proc F/S wrapper. External definition of <pfs_root> is
 *				required. Use <pfs_make_dir> to create 1st level subfolders
 *				of (/proc/<pfs_root>/1st_level); use <pfs_make_rdentry> to
 *				create 1st or 2nd level readable nodes. Here is an structure
 *				example:
 *
 *				/proc/my_root/					module folder
 *					common_info					readable node
 *					/sub1/						subfolder
 *						info0					sub1 readable node
 *					/sub2/						subfolder
 *						info0					sub2 readable node
 *						info1					sub2 readable node
 *
 *				It can be constructed with next code:
 *
 *				<ccode>
 *					const char * pfs_root = "my_root";
 *					...
 *					pfs_make_rdentry("common_info", 0, ..., ...);
 *					pfs_make_dir("sub1");
 *					pfs_make_rdentry("info0", "sub1", ..., ...);
 *					pfs_make_dir("sub2");
 *					pfs_make_rdentry("info0", "sub2", ..., ...);
 *					pfs_make_rdentry("info1", "sub2", ..., ...);
 *				</ccode>
 */

#ifndef __LM_PFS_H
#define __LM_PFS_H

#include <linux/proc_fs.h>

/** <modinit> subsystem entries */

int pfs_init(void);
void pfs_release(void);

/** Control functions */

int pfs_make_dir(const char * dirname);
int pfs_make_rdentry(const char * entryname, const char * dirname, read_proc_t *, void * data);

/** External requirements */

extern const char * const pfs_root;

#endif // __LM_PFS_H
