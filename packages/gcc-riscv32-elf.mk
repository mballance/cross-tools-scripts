
ifneq (true,$(RULES))

# Definitions for packages
GCC_RISCV32_ELF_VERSION := 7.1.1
GCC_RISCV32_PKGNAME := gcc-riscv32-elf
GCC_RISCV32_ELF_PKGNAME := $(GCC_RISCV32_PKGNAME)-$(GCC_RISCV32_ELF_VERSION)-$(BUILD_ARCH)

RISCV_BINUTILS_URL:=https://github.com/riscv/riscv-binutils-gdb/archive/riscv-binutils-2.29.zip
RISCV_BINUTILS_DIR:=riscv-binutils-gdb-riscv-binutils-2.29
RISCV_BINUTILS_SRC:=$(PKG_SRC_DIR)/$(RISCV_BINUTILS_DIR).zip

RISCV_GCC_URL:=https://github.com/riscv/riscv-gcc/archive/riscv-gcc-7.zip
RISCV_GCC_DIR:=riscv-gcc-riscv-gcc-7
RISCV_GCC_ZIP:=$(PKG_SRC_DIR)/$(RISCV_GCC_DIR).zip

RISCV_NEWLIB_URL:=https://github.com/riscv/riscv-newlib/archive/riscv-newlib-2.5.0.zip
RISCV_NEWLIB_DIR:=riscv-newlib-riscv-newlib-2.5.0
RISCV_NEWLIB_ZIP:=$(PKG_SRC_DIR)/$(RISCV_NEWLIB_DIR).zip

GCC_RISCV32_ELF_PKG := $(PKG_RESULT_DIR)/$(GCC_RISCV32_ELF_PKGNAME).tar.bz2
GCC_RISCV32_ELF_PKG_DIR := $(subst .tar.bz2,,$(GCC_RISCV32_ELF_PKG))
GCC_RISCV32_ELF_BUILDDIR := $(BUILD_DIR)/gcc-riscv32-elf-$(GCC_RISCV32_ELF_VERSION)
GCC_PACKAGE_RESULTS += $(GCC_RISCV32_ELF_PKG)
GCC_PACKAGE_NAMES += $(GCC_RISCV32_PKGNAME)

GCC_RISCV32_ELF_TARGET:=riscv32-unknown-elf

PATH:=$(TEXINFO_INSTDIR)/bin:$(PATH)
export PATH

else

# Rules for packages

$(RISCV_BINUTILS_SRC) :
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(RISCV_BINUTILS_SRC)"
	$(Q)$(WGET) -O $@ $(RISCV_BINUTILS_URL)

GCC_RISCV32_ELF_PKG_DEPS := \
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


$(BUILD_DIR)/gcc-riscv32-elf/binutils.build : \
		$(BUILD_DIR)/gcc-riscv32-elf/binutils.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring binutils"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/binutils 
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf/binutils 
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/binutils; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	  ../$(RISCV_BINUTILS_DIR)/configure \
		--prefix=$(BUILD_DIR)/gcc-riscv32-elf/installdir \
	    --target=$(GCC_RISCV32_ELF_TARGET) --disable-tcl --disable-tk \
	    --disable-itcl --disable-gdbtk --disable-winsup --disable-libgui \
	    --disable-rda --disable-sid --disable-sim --with-sysroot
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/binutils ; $(MAKE) 
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/binutils ; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/binutils
	$(Q)touch $@

$(BUILD_DIR)/gcc-riscv32-elf/binutils.unpack : $(RISCV_BINUTILS_SRC)
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf ; unzip -o $(RISCV_BINUTILS_SRC)
	$(Q)touch $@

$(RISCV_GCC_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(RISCV_GCC_URL)

$(BUILD_DIR)/gcc-riscv32-elf/riscv-gcc.unpack : $(RISCV_GCC_ZIP)
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf
	$(Q)echo "Unpacking riscv-gcc"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/$(RISCV_GCC_DIR)
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf ; unzip -o $^
	$(Q)touch $@

	
$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase1.build : \
		$(GCC_DEPS) \
		$(BUILD_DIR)/gcc-riscv32-elf/binutils.build \
		$(BUILD_DIR)/gcc-riscv32-elf/riscv-gcc.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring GCC"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/gcc
	$(Q)mkdir $(BUILD_DIR)/gcc-riscv32-elf/gcc
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	    ../$(RISCV_GCC_DIR)/configure \
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

$(RISCV_NEWLIB_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(RISCV_NEWLIB_URL)

$(BUILD_DIR)/gcc-riscv32-elf/riscv-newlib.unpack : $(RISCV_NEWLIB_ZIP)
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/$(RISCV_NEWLIB_DIR)
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf ; unzip -o $^

$(BUILD_DIR)/gcc-riscv32-elf/newlib.build : \
	$(BUILD_DIR)/gcc-riscv32-elf/gcc_phase1.build \
	$(BUILD_DIR)/gcc-riscv32-elf/riscv-newlib.unpack
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv32-elf/newlib
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv32-elf/newlib
	$(Q)echo "Configuring newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv32-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv32-elf/installdir/bin:$(PATH)"; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	    ../$(RISCV_NEWLIB_DIR)/configure \
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
	  ../$(RISCV_GCC_DIR)/configure \
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
