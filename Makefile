
include common/rules_defs.mk
include common/common_gcc_deps.mk
include packages/*.mk


RULES:=true

all : 
	@echo "Available targets:"
	@echo "gcc-pkgs: build all cross compilers"
	@for pkg in $(GCC_PACKAGE_NAMES); do \
		echo "  $$pkg"; \
	done
	@echo "  clean-all   - remove everything"
	@echo "  clean-pkg   - remove result packages"
	@echo "  clean-build - remove package builds"

gcc-pkgs : $(GCC_PACKAGE_RESULTS)

include common/common_gcc_deps.mk
include packages/*.mk
include common/rules_defs.mk


clean-all : clean-pkg clean-build clean-src

clean-src : 
	$(Q)rm -rf $(PKG_SRC_DIR)
	
clean-build :
	$(Q)rm -rf $(BUILD_DIR)
	
clean-pkg :
	$(Q)rm -rf $(PKG_RESULT_DIR)
