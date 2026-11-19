TYPE ?= $(strip $(shell awk -F= '/^SELINUXTYPE/{ print $$2 }' /etc/selinux/config))
DEVEL := /usr/share/selinux/$(TYPE)/include/Makefile
SEMODULE = semodule

OUT = out
SRC_DIR = src

PP_FILES=$(patsubst $(SRC_DIR)/%.te,%.pp,$(wildcard $(SRC_DIR)/*.te))

%.pp: $(SRC_DIR)/%.te
	@mkdir -p $(OUT)
	@$(MAKE) -f $(DEVEL) $@
	@mv -f *.pp $(OUT)

.PHONY: all help install remove clean

all: $(PP_FILES)

help:
	@echo "make <name>                            build policy pp to out/<name>.pp"
	@echo "install MODULE=<name without .pp>      load the targeted policy"
	@echo "remove  MODULE=<name without .pp>      unload the targeted policy"
	@echo "clean                                  clean artifacts"

install: $(if $(MODULE),$(OUT)/$(MODULE).pp,$(addprefix $(OUT)/,$(PP_FILES)))
	$(SEMODULE) -i $^

remove:
	$(SEMODULE) -r $(MODULE)

clean:
	rm -rf tmp $(OUT)