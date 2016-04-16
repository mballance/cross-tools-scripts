
ifneq (true,$(RULES))

# Definitions for packages
GCC_OR1K_ELF_VERSION := 4.9.2
GCC_OR1K_ELF_PKGNAME := gcc-or1k-elf-$(GCC_OR1K_ELF_VERSION)-$(BUILD_ARCH)
GCC_OR1K_ELF_NEWLIB_SRC_URL:=$(SOURCEWARE_MIRROR_URL)/newlib/newlib-2.2.0.20150225.tar.gz

GCC_OR1K_ELF_BINUTILS_SRC_URL:=$(GNU_MIRROR_URL)/binutils/binutils-2.25.tar.bz2
GCC_OR1K_ELF_OR1K_SRC_URL:=https://github.com/openrisc/or1k-src/archive/or1k.zip 
GCC_OR1K_ELF_OR1K_GCC_URL:=https://github.com/openrisc/or1k-gcc/archive/or1k.zip

GCC_OR1K_ELF_OR1K_SRC_PKG := $(PKG_SRC_DIR)/or1k-src.zip
GCC_OR1K_ELF_OR1K_GCC_PKG := $(PKG_SRC_DIR)/or1k-gcc.zip
GCC_OR1K_ELF_NEWLIB_PKG:=$(PKG_SRC_DIR)/newlib-2.2.0.20150225.tar.gz

GCC_OR1K_ELF_BINUTILS_PKG:=$(PKG_SRC_DIR)/binutils-2.25.tar.bz2

GCC_OR1K_ELF_PKG := $(PKG_RESULT_DIR)/$(GCC_OR1K_ELF_PKGNAME).tar.bz2
GCC_OR1K_ELF_PKG_DIR := $(subst .tar.bz2,,$(GCC_OR1K_ELF_PKG))
GCC_OR1K_ELF_BUILDDIR := $(BUILD_DIR)/gcc-or1k-elf-$(GCC_OR1K_ELF_VERSION)
GCC_PACKAGE_RESULTS += $(GCC_OR1K_ELF_PKG)
GCC_PACKAGE_NAMES += gcc-or1k-elf

GCC_OR1K_ELF_TARGET:=or1k-elf

else

# Rules for packages
$(GCC_OR1K_ELF_OR1K_SRC_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(GCC_OR1K_ELF_OR1K_SRC_URL)"
	$(Q)$(WGET) -O $@ $(GCC_OR1K_ELF_OR1K_SRC_URL)
	
$(GCC_OR1K_ELF_OR1K_GCC_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(GCC_OR1K_ELF_OR1K_GCC_URL)"
	$(Q)$(WGET) -O $@ $(GCC_OR1K_ELF_OR1K_GCC_URL)
	
$(GCC_OR1K_ELF_NEWLIB_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(GCC_OR1K_ELF_NEWLIB_SRC_URL)"
	$(Q)$(WGET) -O $@ $(GCC_OR1K_ELF_NEWLIB_SRC_URL)
	

	
$(GCC_OR1K_ELF_BINUTILS_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(GCC_OR1K_ELF_BINUTILS_SRC_URL)"
	$(Q)$(WGET) -O $@ $(GCC_OR1K_ELF_BINUTILS_SRC_URL)

GCC_OR1K_ELF_PKG_DEPS := $(GCC_OR1K_ELF_OR1K_SRC_PKG) \
  $(GCC_OR1K_ELF_OR1K_GCC_PKG) \
  $(GCC_OR1K_ELF_NEWLIB_PKG)   \
  $(GCC_OR1K_ELF_BINUTILS_PKG)

$(GCC_OR1K_ELF_PKG) : $(BUILD_DIR)/gcc-or1k-elf.build
	$(Q)echo "Copying GCC or1k Result Files"
	$(Q)rm -rf $(GCC_OR1K_ELF_PKG_DIR)
	$(Q)mkdir -p $(GCC_OR1K_ELF_PKG_DIR)
	$(Q)mkdir -p $(GCC_OR1K_ELF_PKG_DIR)/gcc-or1k-elf-$(GCC_OR1K_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)cp -r $(BUILD_DIR)/gcc-or1k-elf/installdir/* \
		$(GCC_OR1K_ELF_PKG_DIR)/gcc-or1k-elf-$(GCC_OR1K_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)echo "Packing $@"
	$(Q)cd $(GCC_OR1K_ELF_PKG_DIR) ; \
		$(TARBZ) $@ gcc-or1k-elf-$(GCC_OR1K_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)rm -rf $(GCC_OR1K_ELF_PKG_DIR)
	

$(BUILD_DIR)/gcc-or1k-elf/binutils.build : $(GCC_OR1K_ELF_BINUTILS_PKG)
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-or1k-elf
	$(Q)echo "Unpacking binutils"
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/binutils-2.25
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf; $(UNTARBZ2) $^
	$(Q)echo "Configuring binutils"
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/binutils-2.25 ; \
	  ./configure --prefix=$(BUILD_DIR)/gcc-or1k-elf/installdir \
	    --target=$(GCC_OR1K_ELF_TARGET) --disable-tcl --disable-tk \
	    --disable-itcl --disable-gdbtk --disable-winsup --disable-libgui \
	    --disable-rda --disable-sid --disable-sim --with-sysroot 
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/binutils-2.25 ; $(MAKE) 
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/binutils-2.25 ; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/binutils-2.25
	$(Q)touch $@
	
$(BUILD_DIR)/gcc-or1k-elf/gcc_phase1.build : \
		$(GCC_DEPS) \
		$(BUILD_DIR)/gcc-or1k-elf/binutils.build \
		$(GCC_OR1K_ELF_OR1K_GCC_PKG)
	$(Q)$(MKDIRS)
	$(Q)echo "Unpacking or1k-gcc (gcc)"
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/or1k-gcc-or1k
	-$(Q)cd $(BUILD_DIR)/gcc-or1k-elf ; $(UNZIP) $(GCC_OR1K_ELF_OR1K_GCC_PKG)
	$(Q)if test ! -d $(BUILD_DIR)/gcc-or1k-elf/or1k-gcc-or1k; then \
		echo "Error: failed to unpack or1k-gcc-or1k"; \
		exit 1; \
	fi
	$(Q)echo "Configuring GCC"
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/gcc
	$(Q)mkdir $(BUILD_DIR)/gcc-or1k-elf/gcc
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; \
	    ../or1k-gcc-or1k/configure --target=$(GCC_OR1K_ELF_TARGET) \
	    --prefix=$(BUILD_DIR)/gcc-or1k-elf/installdir \
	    --enable-languages=c --disable-shared --disable-libssp \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpc=$(MPC_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; $(MAKE)
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/gcc
	$(Q)touch $@

$(BUILD_DIR)/gcc-or1k-elf/newlib.build : \
	$(BUILD_DIR)/gcc-or1k-elf/gcc_phase1.build \
	$(GCC_OR1K_ELF_NEWLIB_PKG)
	$(Q)echo "Unpacking newlib"
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/newlib-2.2.0.20150225
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf ; $(UNTARGZ) $(GCC_OR1K_ELF_NEWLIB_PKG)
	$(Q)echo "Configuring newlib"
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/newlib-2.2.0.20150225 ; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; \
	    ./configure --prefix=$(BUILD_DIR)/gcc-or1k-elf/installdir \
	      --target=$(GCC_OR1K_ELF_TARGET) 
	$(Q)echo "Building newlib"
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/newlib-2.2.0.20150225 ; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; $(MAKE) 
	$(Q)echo "Installing newlib"
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/newlib-2.2.0.20150225 ; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/newlib-2.2.0.20150225
	$(Q)touch $@
	
$(BUILD_DIR)/gcc-or1k-elf/gcc_phase2.build : \
	$(BUILD_DIR)/gcc-or1k-elf/newlib.build 
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/gcc-phase2
	$(Q)mkdir -p $(BUILD_DIR)/gcc-or1k-elf/gcc-phase2
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/gcc-phase2; \
	  ../or1k-gcc-or1k/configure --target=$(GCC_OR1K_ELF_TARGET) \
	    --prefix=$(BUILD_DIR)/gcc-or1k-elf/installdir \
	    --enable-languages=c,c++ --disable-shared --disable-libssp --with-newlib \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpc=$(MPC_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
	$(Q)echo "Building gcc phase2"
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/gcc-phase2; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; $(MAKE) 
	$(Q)echo "Installing gcc phase2"
	$(Q)cd $(BUILD_DIR)/gcc-or1k-elf/gcc-phase2; \
	    export PATH="$(BUILD_DIR)/gcc-or1k-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-or1k-elf/gcc-phase2
	$(Q)touch $@
	
$(BUILD_DIR)/gcc-or1k-elf.build : \
		$(BUILD_DIR)/gcc-or1k-elf/gcc_phase1.build \
		$(BUILD_DIR)/gcc-or1k-elf/newlib.build     \
		$(BUILD_DIR)/gcc-or1k-elf/gcc_phase2.build 
	$(Q)touch $@
	
gcc-or1k-elf : $(GCC_OR1K_ELF_PKG)

endif
