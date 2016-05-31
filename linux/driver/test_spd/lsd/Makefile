#   file:       Makefile
#   date:       18.05.2010
#   authors:    Topolsky
#   company:    Linkos
#   descript.:  LSD (Linkos Smart Device) project Makefile

MODULE :=       lsd

# uncomment next line to enable special (hardware developer) mode: only memory
# subsystem and required environment will be initialized
#EXTRA_CFLAGS += -DLSD_MEM_ONLY

# uncomment next 2 lines to enable <hwdbg> subsystem
$(MODULE)-objs += hwdbg.o
EXTRA_CFLAGS += -DLSD_ENABLE_HWDBG

# memory character device is enabled automatically if <LSD_MEM_ONLY> is chosen
# or <dadbg> subsystem is enabled, uncomment next line to enable it forcibly
EXTRA_CFLAGS += -DLSD_FORCE_MEM_CDEV

# <cdev> subsystem requirements

EXTRA_CFLAGS += -DLM_CDEV_NAME_PREFIX="\"lsd/\""
EXTRA_CFLAGS += -DLM_CDEV_CREATE_NODE

# module building rules

obj-m :=        $(MODULE).o

$(MODULE)-objs += cdev.o \
                iosched.o \
                irq.o \
                modinit.o \
                pci.o \
                retcode.o \
                cfg.o \
                dma.o \
                fg.o \
                fiber.o \
                frr.o \
                mem.o \
                module.o \
                timer.o

LMDIR :=        ../lm
LM :=           $(LMDIR)/cdev.h $(LMDIR)/cdev.c \
                $(LMDIR)/iosched.h $(LMDIR)/iosched.c \
                $(LMDIR)/irq.h $(LMDIR)/irq.c \
                $(LMDIR)/modinit.h $(LMDIR)/modinit.c \
                $(LMDIR)/pci.h $(LMDIR)/pci.c \
                $(LMDIR)/pci_ids.h \
                $(LMDIR)/retcode.h $(LMDIR)/retcode.c

KERNELDIR ?=    /lib/modules/$(shell uname -r)/build
INSTALLDIR :=   /lib/modules/$(shell uname -r)/kernel/drivers/addon
PWD :=          $(shell pwd)

EXTRA_CFLAGS += -Wno-declaration-after-statement

MODPROBEDIR :=  /etc/modprobe.d
BOOTLOCKER :=   block-$(MODULE).conf

INITDIR :=      /etc/rc.d
INITRUNNER :=   rc.local
INITSCRIPT :=   rc.$(MODULE)

UDEVRULESDIR := /etc/udev/rules.d

.init_script: $(LMDIR)/rc.module_alt
	cat $(LMDIR)/rc.module_alt | sed -e '/^##.*/d' \
		-e '1a#   file:       $(INITSCRIPT)' \
		-e '1a#   date:       $(shell date +%d.%m.%Y)' \
		-e '1a#   company:    Linkos' \
		-e '1a#   descript.:  Automatically generated init script' \
		-e 's/MODULE=/MODULE=".\/$(MODULE).ko"/' > $(INITSCRIPT)
	chmod +x $(INITSCRIPT)

all: .init_script
	ln -sf $(LM) $(PWD)
	$(MAKE) -C $(KERNELDIR) M=$(PWD)

clean:
	rm -f cdev.h cdev.c iosched.h iosched.c irq.h irq.c pci.h modinit.h modinit.c pci.c pci_ids.h retcode.h retcode.c
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions Module.* modules.order
	rm -f $(INITSCRIPT)

# install all external headers (including disabled subsystems) to make all
# external programs compilable regardless of module configuration

headers_install:
	test -n "$(LINKOSDIR)" # Looking for $LINKOSDIR
	mkdir -p $(LINKOSDIR)/include/$(MODULE)
	cp $(PWD)/*_io.h $(LINKOSDIR)/include/$(MODULE)

headers_uninstall:
	test -n "$(LINKOSDIR)" # Looking for $LINKOSDIR
	rm -fR $(LINKOSDIR)/include/$(MODULE)

headers_reinstall: headers_uninstall headers_install

# do not exec "all" target in the "install" target to avoid temporary files
# that can be removed with root permissions only

install:
	# install module
	test -e $(MODULE).ko
	install -m 755 -d $(INSTALLDIR)
	install -m 644 $(MODULE).ko $(INSTALLDIR)
	/sbin/depmod -A
	# install bootlocker
	test -d $(MODPROBEDIR)
	test -e $(MODPROBEDIR)/$(BOOTLOCKER) || \
	(	echo "# disable <$(MODULE)> on system boot (<ad5clocks> must be executed before)" > $(MODPROBEDIR)/$(BOOTLOCKER); \
		echo "blacklist $(MODULE)" >> $(MODPROBEDIR)/$(BOOTLOCKER) ; \
	)
	# install udev rules
	test -e $(LMDIR)/linkos.rules
	test -d $(UDEVRULESDIR)
	install -m 644 $(LMDIR)/linkos.rules $(UDEVRULESDIR)
	# install loader
	test -e $(INITSCRIPT)
	test -d $(INITDIR)
	test -e $(INITDIR)/$(INITRUNNER)
	cat $(INITSCRIPT) | sed 's/MODULE=.*/MODULE="$(MODULE)"/' > $(INITSCRIPT)_
	install -m 755 $(INITSCRIPT)_ $(INITDIR)/$(INITSCRIPT)
	rm $(INITSCRIPT)_
	cat $(INITDIR)/$(INITRUNNER) | grep $(INITSCRIPT) &> /dev/null || \
	(	echo >> $(INITDIR)/$(INITRUNNER); \
		echo "# load lsd" >> $(INITDIR)/$(INITRUNNER); \
		echo >> $(INITDIR)/$(INITRUNNER); \
		echo "lspci -d 0777:8005 -n | grep 0777 &> /dev/null &&" >> $(INITDIR)/$(INITRUNNER); \
		echo "	test -x $(INITDIR)/$(INITSCRIPT) &&" >> $(INITDIR)/$(INITRUNNER); \
		echo "	$(INITDIR)/$(INITSCRIPT) start" >> $(INITDIR)/$(INITRUNNER); \
	)

uninstall:
	rm -f $(INSTALLDIR)/$(MODULE).ko
	rmdir --ignore-fail-on-non-empty $(INSTALLDIR)
	/sbin/depmod -a
	rm -f $(MODPROBEDIR)/$(BOOTLOCKER)
	rm -f $(INITDIR)/$(INITSCRIPT)
	rm -f $(UDEVRULESDIR)/linkos.rules
