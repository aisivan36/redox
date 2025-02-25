# Configuration and variables
include mk/config.mk

# Dependencies
include mk/depends.mk

all: build/harddrive.img

live: build/livedisk.iso

rebuild:
	-$(FUMOUNT) build/filesystem/ || true
	-$(FUMOUNT) /tmp/redox_installer/ || true
	rm -rf build
	$(MAKE) all

clean:
	cd cookbook && ./clean.sh
	cargo clean --manifest-path cookbook/pkgutils/Cargo.toml
	cargo clean --manifest-path installer/Cargo.toml
	cargo clean --manifest-path redoxfs/Cargo.toml
	cargo clean --manifest-path relibc/Cargo.toml
	-$(FUMOUNT) build/filesystem/ || true
	-$(FUMOUNT) /tmp/redox_installer/ || true
	rm -rf build

distclean:
	$(MAKE) clean
	cd cookbook && ./unfetch.sh

pull:
	git pull --recurse-submodules
	git submodule sync --recursive
	git submodule update --recursive --init

fetch: build/fetch.tag

repo: build/repo.tag

# Cross compiler recipes
include mk/prefix.mk

# Repository maintenance
include mk/repo.mk

# Disk images
include mk/disk.mk

# Emulation recipes
include mk/qemu.mk
include mk/bochs.mk
include mk/virtualbox.mk

# CI
include mk/ci.mk

env: prefix FORCE
	export PATH="$(PREFIX_PATH):$$PATH" && \
	bash

gdb: FORCE
	gdb cookbook/recipes/kernel/build/kernel.sym --eval-command="target remote localhost:1234"

# An empty target
FORCE:

# Gzip any binary
%.gz: %
	gzip -k -f $<

# Wireshark
wireshark: FORCE
	wireshark build/network.pcap
