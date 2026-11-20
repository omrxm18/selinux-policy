TYPE ?= $(strip $(shell awk -F= '/^SELINUXTYPE/{ print $$2 }' /etc/selinux/config))
DEVEL := /usr/share/selinux/$(TYPE)/include/Makefile
SEMODULE = semodule

OUT = out
SRC_DIR = src

TE_FILES := $(shell find $(SRC_DIR) -type f -name '*.te')
MODULES  := $(basename $(notdir $(TE_FILES)))
PP_FILES := $(addsuffix .pp,$(MODULES))

vpath %.te $(sort $(dir $(TE_FILES)))

.PHONY: all help install remove clean

all: $(PP_FILES)

%.pp: %.te
	@mkdir -p $(OUT) tmp/$*
	@cp -f $(wildcard $(<D)/$*.te $(<D)/$*.if $(<D)/$*.fc) tmp/$*/
	@$(MAKE) -C tmp/$* -f $(DEVEL) $@
	@mv -f tmp/$*/$@ $(OUT)/$@

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