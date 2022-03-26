INITFS_RM_BINS=\
	alxd \
	bgad \
	e1000d \
	ihdad \
	ixgbed \
	pcspkrd \
	redoxfs-ar \
	redoxfs-mkfs \
	rtl8168d \
	usbctl \
	usbhidd \
	usbscsid \
	vboxd \
	xhcid

build/initfs.img: initfs.toml prefix
	cargo build --manifest-path cookbook/Cargo.toml --release
	cargo build --manifest-path installer/Cargo.toml --release
	rm -rf build/initfs
	mkdir -p build/initfs
	$(INSTALLER) -c $< build/initfs/
	#TODO: HACK FOR SMALLER INITFS, FIX IN PACKAGING
	rm -rf build/initfs/pkg
	for bin in $(INITFS_RM_BINS); do \
		rm -f build/initfs/bin/$$bin; \
	done
	cargo run --manifest-path redox-initfs/tools/Cargo.toml --bin redox-initfs-ar -- build/initfs -o $@
