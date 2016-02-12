# CC ?= gcc

.PHONY: patches install clean

all: patches pxaregs

patches: i2c.patch munmap.patch serial.patch usb.patch
	-for p in $^; do \
	    patch --forward < $$p; \
	done 

$(DESTDIR)/usr/bin/pxaregs: pxaregs
	install -d $(@D)
	cp pxaregs $(@D)

install: $(DESTDIR)/usr/bin/pxaregs

clean: 
	rm -f *.o pxaregs *.rej *.orig
