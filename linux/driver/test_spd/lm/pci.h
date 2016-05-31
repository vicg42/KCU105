/**
 *	file:		pci.h
 *	date:		28.08.2007
 *	authors:	Topolsky
 *	format:		tab4
 *	descipt.:	PCI device (finding) helper. External definition of <pci_attach>
 *				and <pci_dettach> functions is required (will be called when
 *				device found and before unregistering driver). Device must be
 *				defined by vendor & device ID in "config.h". Only one (1st of
 *				found) device is supported.
 */

#ifndef __LM_PCI_H
#define __LM_PCI_H

#include <linux/pci.h>

/** <modinit> subsystem entries */

int pci_init(void);
void pci_release(void);

/** External requirements */

typedef int (* pci_attach_func_t)(struct pci_dev *);
extern const pci_attach_func_t pci_attach;

typedef void (* pci_detach_func_t)(struct pci_dev *);
extern const pci_detach_func_t pci_detach;

#endif // __LM_PCI_H
