
ifneq (true,$(RULES))

# Definitions for packages
GCC_RISCV32_ELF_VERSION := 4.9.2
GCC_RISCV32_PKGNAME := gcc-riscv32-elf
GCC_RISCV32_ELF_PKGNAME := $(GCC_RISCV32_PKGNAME)-$(GCC_RISCV32_ELF_VERSION)-$(BUILD_ARCH)
RISCV_GNU_TOOLCHAIN_URL:=https://github.com/riscv/riscv-gnu-toolchain
RISCV_GNU_TOOLCHAIN_SRC:=$(PKG_SRC_DIR)/riscv-gnu-toolchain.tar.gz

GCC_RISCV32_ELF_PKG := $(PKG_RESULT_DIR)/$(GCC_RISCV32_ELF_PKGNAME).tar.bz2
GCC_RISCV32_ELF_PKG_DIR := $(subst .tar.bz2,,$(GCC_RISCV32_ELF_PKG))
GCC_RISCV32_ELF_BUILDDIR := $(BUILD_DIR)/gcc-riscv32-elf-$(GCC_RISCV32_ELF_VERSION)
GCC_PACKAGE_RESULTS += $(GCC_RISCV32_ELF_PKG)
GCC_PACKAGE_NAMES += $(GCC_RISCV32_PKGNAME)

GCC_RISCV32_ELF_TARGET:=riscv32-elf

PATH:=$(TEXINFO_INSTDIR)/bin:$(PATH)
export PATH

else

# Rules for packages
$(RISCV_GNU_TOOLCHAIN_SRC) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(RISCV_GNU_TOOLCHAIN_SRC)"
	$(Q)cd $(PKG_SRC_DIR) ; git clone --recursive $(RISCV_GNU_TOOLCHAIN_URL)
	$(Q)cd $(PKG_SRC_DIR)/`basename $(RISCV_GNU_TOOLCHAIN_URL)` ; \
		git submodule update --init --recursive
	$(Q)cd $(PKG_SRC_DIR) ; tar czf \
      `basename $(RISCV_GNU_TOOLCHAIN_URL)`.tar.gz \
      `basename $(RISCV_GNU_TOOLCHAIN_URL)`
	
GCC_RISCV32_ELF_PKG_DEPS := $(RISCV_GNU_TOOLCHAIN_SRC) \
  $(GCC_RISCV32_ELF_OR1K_GCC_PKG) \
  $(GCC_RISCV32_ELF_NEWLIB_PKG)   \
  $(GCC_RISCV32_ELF_BINUTILS_PKG)

$(GCC_RISCV32_ELF_PKG) : \
  $(BUILD_DIR)/gcc-riscv32-elf.build
	$(Q)echo "Copying GCC riscv Result Files"
	$(Q)rm -rf $(GCC_RISCV32_ELF_PKG_DIR)
	$(Q)mkdir -p $(GCC_RISCV32_ELF_PKG_DIR)
	$(Q)mkdir -p $(GCC_RISCV32_ELF_PKG_DIR)/gcc-riscv32-elf-$(GCC_RISCV32_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)cp -r $(BUILD_DIR)/gcc-riscv32-elf/installdir/* \
		$(GCC_RISCV32_ELF_PKG_DIR)/gcc-riscv32-elf-$(GCC_RISCV32_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)echo "Packing $@"
	$(Q)cd $(GCC_RISCV32_ELF_PKG_DIR) ; \
		$(TARBZ) $@ gcc-riscv32-elf-$(GCC_RISCV32_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)rm -rf $(GCC_RISCV32_ELF_PKG_DIR)


#$(BUILD_DIR)/gdb-riscv.build : $(OR1K_GDB_PKG)
#	$(Q)$(MKDIRS)
#	$(Q)mkdir -p $(BUILD_DIR)/gdb-or1k
#	$(Q)rm -rf $(BUILD_DIR)/gdb-or1k/binutils-gdb-or1k
#	$(Q)cd $(BUILD_DIR)/gdb-or1k ; unzip $^
#	$(Q)cd $(BUILD_DIR)/gdb-or1k/binutils-gdb-or1k; \
#		./configure --prefix=$(BUILD_DIR)/gdb-or1k/installdir \
#        --disable-itcl --disable-tk --disable-tcl --disable-winsup \
#        --disable-gdbtk --disable-libgui --disable-rda --disable-sid \
#        --with-sysroot --disable-newlib --disable-libgloss --disable-gas \
#        --disable-ld --disable-binutils --disable-gprof --with-system-zlib
#	$(Q)cd $(BUILD_DIR)/gdb-or1k/binutils-gdb-or1k; $(MAKE)
#	$(Q)cd $(BUILD_DIR)/gdb-or1k/binutils-gdb-or1k; $(MAKE) install
#	$(Q)touch $@

$(BUILD_DIR)/gcc-riscv32-elf/binutils.build : \
		$(BUILD_DIR)/gcc-riscv32-elf/riscv-gnu-toolchain.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring binutils"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/binutils 
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf/binutils 
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/binutils; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	  ../riscv-gnu-toolchain/riscv-binutils-gdb/configure \
		--prefix=$(BUILD_DIR)/gcc-riscv32-elf/installdir \
	    --target=$(GCC_RISCV32_ELF_TARGET) --disable-tcl --disable-tk \
	    --disable-itcl --disable-gdbtk --disable-winsup --disable-libgui \
	    --disable-rda --disable-sid --disable-sim --with-sysroot 
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/binutils ; $(MAKE) 
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/binutils ; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/binutils
	$(Q)touch $@

$(BUILD_DIR)/gcc-riscv32-elf/riscv-gnu-toolchain.unpack : \
	$(RISCV_GNU_TOOLCHAIN_SRC)
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf
	$(Q)echo "Unpacking riscv-gnu-toolchain"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/riscv-gnu-toolchain
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf ; $(UNTARGZ) $(RISCV_GNU_TOOLCHAIN_SRC)
	$(Q)touch $@
	
$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase1.build : \
		$(GCC_DEPS) \
		$(BUILD_DIR)/gcc-riscv32-elf/binutils.build \
		$(BUILD_DIR)/gcc-riscv32-elf/riscv-gnu-toolchain.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring GCC"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/gcc
	$(Q)mkdir $(BUILD_DIR)/gcc-riscv32-elf/gcc
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	    ../riscv-gnu-toolchain/riscv-gcc/configure \
		--target=$(GCC_RISCV32_ELF_TARGET) \
	    --prefix=$(BUILD_DIR)/gcc-riscv32-elf/installdir \
	    --enable-languages=c --disable-shared --disable-libssp \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpc=$(MPC_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; $(MAKE)
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/gcc
	$(Q)touch $@

$(BUILD_DIR)/gcc-riscv32-elf/newlib.build : \
	$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase1.build \
		$(BUILD_DIR)/gcc-riscv32-elf/riscv-gnu-toolchain.unpack
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/newlib
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf/newlib
	$(Q)echo "Configuring newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	    ../riscv-gnu-toolchain/riscv-newlib/configure \
			--prefix=$(BUILD_DIR)/gcc-riscv32-elf/installdir \
			--target=$(GCC_RISCV32_ELF_TARGET) 
	$(Q)echo "Building newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; \
		$(MAKE) 
	$(Q)echo "Installing newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; \
			$(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/newlib
	$(Q)touch $@
	
$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase2.build : \
	$(BUILD_DIR)/gcc-riscv32-elf/newlib.build 
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/gcc-phase2
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf/gcc-phase2
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc-phase2; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	  ../riscv-gnu-toolchain/riscv-gcc/configure \
		--target=$(GCC_RISCV32_ELF_TARGET) \
	    --prefix=$(BUILD_DIR)/gcc-riscv32-elf/installdir \
	    --enable-languages=c,c++ --disable-shared --disable-libssp \
		--with-newlib \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpc=$(MPC_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
	$(Q)echo "Building gcc phase2"
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc-phase2; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; $(MAKE) 
	$(Q)echo "Installing gcc phase2"
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc-phase2; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/gcc-phase2
	$(Q)touch $@
	
$(BUILD_DIR)/gcc-riscv32-elf.build : \
		$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase1.build \
		$(BUILD_DIR)/gcc-riscv32-elf/newlib.build     \
		$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase2.build 
	$(Q)touch $@
	
gcc-riscv32-elf : $(GCC_RISCV32_ELF_PKG)

endif
