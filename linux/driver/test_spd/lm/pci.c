/*
 *	file:		pci.c
 *	date:		28.08.2007
 *	authors:	Topolsky
 *	format:		tab4
 */

#include "pci.h"

#include <asm/atomic.h>
#include <linux/module.h>
#include <linux/pci_regs.h>
#include <linux/version.h>

#include "config.h"
#include "retcode.h"

// local types -----------------------------------------------------------------

typedef struct
{
	/** Subsystem "ready" flag: all "public" calls must take into it's value
	  * (if no <LM_NDEBUG> defined) */

	atomic_t		init;

	/** Service PCI structure */

	struct pci_driver driver;

	/** Probing variable (device counter, now only 0 or 1) */

	size_t			probe;

} local_data_t;

// local functions -------------------------------------------------------------

static int pci_probe(struct pci_dev *, const struct pci_device_id *);
static void pci_remove(struct pci_dev *);

// local variables -------------------------------------------------------------

static local_data_t l;

static const struct pci_device_id pci_device_arr[] =
{	{ PCI_DEVICE(LM_PCI_VENDOR_ID, LM_PCI_DEVICE_ID) }
,	{ 0, }
};

// kernel routine (bind device) ------------------------------------------------

MODULE_DEVICE_TABLE(pci, pci_device_arr);

// implementation --------------------------------------------------------------

int pci_init(void)
{
	#ifndef LM_NDEBUG
	if (atomic_read(&l.init))
		return -EPERM;
	#endif

	l.driver.name = LM_NAME;
	l.driver.id_table = pci_device_arr;
	l.driver.probe = pci_probe;
	l.driver.remove = pci_remove;

	l.probe = 0;

	int retcode;

	// <pci_probe> function will be called during driver registering if matched
	// device found. There isn't available <pci_register_driver> function
	// return code description (it's "1" if one device is successfully probed
	// and "0" if no devices, but no more info), so <l.probe> is used as
	// additional retcode (modified in <pci_probe>).

	if (is_error(retcode = pci_register_driver(&l.driver)))
		return retcode;

	if (!l.probe)
		return pci_unregister_driver(&l.driver), -ENODEV;

	atomic_set(&l.init, 1);

	return 0;
}

static int pci_probe(struct pci_dev * dev, const struct pci_device_id * _)
{
	if (l.probe)
		return -EACCES; // only one device supported

	int retcode;

	if (is_error(retcode = pci_enable_device(dev)))
		return retcode;

	#ifdef LM_PCI_ENABLE_MSI
	#	if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
	if (pci_msi_enabled())
	#	endif
		if (pci_find_capability(dev, PCI_CAP_ID_MSI))
			if (is_error(retcode = pci_enable_msi(dev)))
				print_error(retcode, "pci_enable_msi");
	#endif

	if (pci_attach)
		if (is_error(retcode = pci_attach(dev)))
			return print_error(retcode, "pci_attach"), pci_disable_device(dev), retcode;

	++l.probe;

	return 0;
}

static void pci_remove(struct pci_dev * dev)
{
	if (pci_detach)
		pci_detach(dev);

	pci_disable_device(dev);

	#ifdef LM_PCI_ENABLE_MSI
	#	if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
	if (pci_msi_enabled())
	#	endif
		if (dev->msi_enabled)
			pci_disable_msi(dev);
	#endif
}

void pci_release(void)
{
	#ifndef LM_NDEBUG
	if (!atomic_read(&l.init))
		return print_error(-EPERM, __FUNCTION__);
	#endif

	pci_unregister_driver(&l.driver); // <pci_remove> will be executed during execution

	atomic_set(&l.init, 0);
}
